//
//  NetworkingHandler.swift
//  jQuiz
//
//  Created by Jay Strawn on 7/17/20.
//  Copyright © 2020 Jay Strawn. All rights reserved.
//

import Foundation

class Networking {
  
  static let sharedInstance = Networking()
  
  func getRandomCategory(completion: @escaping (Category) -> Void ) {
    let request = URLRequest(url: URL(string: "http://www.jservice.io/api/random")!)
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print(error)
        return
      }
      if let data = data {
        let decoder = JSONDecoder()
        do {
          let clues = try decoder.decode([Clue].self, from: data)
          if let clue = clues.first {
            completion(clue.category)
          }
        } catch {
          print("Decode Error", error)
        }        
      }
    }
    task.resume()
  }
  
  func getCluesInCategory(_ category: Category, completion: @escaping ([Clue]) -> Void) {
    let request = URLRequest(url: URL(string: "http://www.jservice.io/api/clues?category=\(category.id)")!)
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print(error)
        return
      }
      if let data = data {
        let decoder = JSONDecoder()
        do {
          let clues = try decoder.decode([Clue].self, from: data)
            completion(clues)
        } catch {
          print("Decode Error", error)
        }
      }
    }
    task.resume()
  }
}
