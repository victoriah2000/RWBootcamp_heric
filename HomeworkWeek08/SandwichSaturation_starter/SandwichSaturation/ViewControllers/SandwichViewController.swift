//
//  SandwichViewController.swift
//  SandwichSaturation
//
//  Created by Jeff Rames on 7/3/20.
//  Copyright © 2020 Jeff Rames. All rights reserved.
//

import UIKit
import CoreData

protocol SandwichDataSource {
  func saveSandwich(_: SandwichData)
}

class SandwichViewController: UITableViewController, SandwichDataSource {
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  let searchController = UISearchController(searchResultsController: nil)
  var sandwiches = [Sandwich]()
  var filteredSandwiches = [Sandwich]()
  let  selectedIndexKeyName = "selectedIndex"

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    refresh()    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
        
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddView(_:)))
    navigationItem.rightBarButtonItem = addButton
    
    // Setup Search Controller
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Filter Sandwiches"
    searchController.searchBar.scopeButtonTitles = SauceAmount.allCases.map { $0.rawValue }
    searchController.searchBar.delegate = self
    searchController.searchBar.selectedScopeButtonIndex = UserDefaults.standard.integer(forKey: selectedIndexKeyName)
  
    navigationItem.searchController = searchController
    
    // More configuration
    definesPresentationContext = true
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  func refresh() {
    let request = Sandwich.fetchRequest() as NSFetchRequest<Sandwich>

    let sort = NSSortDescriptor(key: #keyPath(Sandwich.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
    request.sortDescriptors = [sort]
    do {
      sandwiches = try context.fetch(request)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    tableView?.reloadData()
  }
  
  func saveSandwich(_ sandwich: SandwichData) {
    let new = Sandwich(entity: Sandwich.entity(), insertInto: context)
    new.name = sandwich.name
    new.sauceAmount = fetchSauceModel(sandwich.sauceAmount.rawValue)
    new.imageName = sandwich.imageName
    appDelegate.saveContext()
    refresh()
  }

  @objc
  func presentAddView(_ sender: Any) {
    performSegue(withIdentifier: "AddSandwichSegue", sender: self)
  }
  
  // MARK: - Search Controller
  var isSearchBarEmpty: Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  func filterContentForSearchText(_ searchText: String,
                                  sauceAmount: SauceAmount? = nil) {
//    filteredSandwiches = sandwiches.filter { (sandwich: SandwichData) -> Bool in
//      let doesSauceAmountMatch = sauceAmount == .any || sandwich.sauceAmount == sauceAmount
//
//      if isSearchBarEmpty {
//        return doesSauceAmountMatch
//      } else {
//        return doesSauceAmountMatch && sandwich.name.lowercased()
//          .contains(searchText.lowercased())
//      }
//    }
    
    tableView.reloadData()
  }
  
  var isFiltering: Bool {
    let searchBarScopeIsFiltering =
      searchController.searchBar.selectedScopeButtonIndex != 0
    return searchController.isActive &&
      (!isSearchBarEmpty || searchBarScopeIsFiltering)
  }
  
  // MARK: - Table View
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isFiltering ? filteredSandwiches.count : sandwiches.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "sandwichCell", for: indexPath) as? SandwichCell
      else { return UITableViewCell() }
    
    let sandwich = isFiltering ?
      filteredSandwiches[indexPath.row] :
      sandwiches[indexPath.row]

    cell.thumbnail.image = UIImage.init(imageLiteralResourceName: sandwich.imageName!)
    cell.nameLabel.text = sandwich.name
    cell.sauceLabel.text = sandwich.sauceAmount!.description

    return cell
  }
}

// MARK: - UISearchResultsUpdating
extension SandwichViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    let sauceAmount = SauceAmount(rawValue:
      searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])

    filterContentForSearchText(searchBar.text!, sauceAmount: sauceAmount)
  }
}

// MARK: - UISearchBarDelegate
extension SandwichViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar,
      selectedScopeButtonIndexDidChange selectedScope: Int) {
    let sauceAmount = SauceAmount(rawValue:
      searchBar.scopeButtonTitles![selectedScope])
    filterContentForSearchText(searchBar.text!, sauceAmount: sauceAmount)
    UserDefaults.standard.set(selectedScope, forKey: selectedIndexKeyName) }
}
