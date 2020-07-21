//
//  MigrateSandwiches.swift
//  SandwichSaturation
//
//  Created by Victoria Heric on 7/19/20.
//  Copyright © 2020 Jeff Rames. All rights reserved.
//

import CoreData
import UIKit

func loadSandwiches() -> [SandwichData] {
  let sandwichPath = Bundle.main.path(forResource: "sandwiches", ofType: "json")!
  let sandwichURL = URL(fileURLWithPath: sandwichPath)
  let data = try! Data(contentsOf: sandwichURL)
  
  let decoder = JSONDecoder()
  return try! decoder.decode([SandwichData].self, from: data)
}

func fetchSauceModel(_ name: String) -> SauceAmountModel {
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let context = appDelegate.persistentContainer.viewContext
  
  let request = SauceAmountModel.fetchRequest() as NSFetchRequest<SauceAmountModel>
  request.predicate = NSPredicate(format: "sauceAmountString == %@", name)
  let result = try! context.fetch(request).first!

  return result
}

func migrateSandwiches() throws {
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let context = appDelegate.persistentContainer.viewContext

  let request = SauceAmountModel.fetchRequest() as NSFetchRequest<SauceAmountModel>
  let count = try context.count(for: request)
  if count == 0 {
    
    for sauce in SauceAmount.allCases {
      let model = SauceAmountModel(entity: SauceAmountModel.entity(),
                                   insertInto: context)
      model.sauceAmountString = sauce.rawValue
    }
    appDelegate.saveContext()
    
    let sandwiches = loadSandwiches()
    for sandwich in sandwiches {
      let new = Sandwich(entity: Sandwich.entity(), insertInto: context)
      new.name = sandwich.name
      new.sauceAmount = fetchSauceModel(sandwich.sauceAmount.rawValue)
      new.imageName = sandwich.imageName
    }
    appDelegate.saveContext()

  }
}
