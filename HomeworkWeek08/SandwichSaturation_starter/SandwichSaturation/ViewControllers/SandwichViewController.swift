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
  var sandwiches = [SandwichModel]()
  var filteredSandwiches = [SandwichModel]()
  let  selectedIndexKeyName = "selectedIndex"

  required init?(coder: NSCoder) {
    super.init(coder: coder)
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
    
    // Load the data
    refresh()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  func refresh() {
    let request = SandwichModel.fetchRequest() as NSFetchRequest<SandwichModel>

    let sort = NSSortDescriptor(key: #keyPath(SandwichModel.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
    request.sortDescriptors = [sort]
    do {
      sandwiches = try context.fetch(request)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    tableView?.reloadData()
  }
  
  func saveSandwich(_ sandwich: SandwichData) {
    let new = SandwichModel(entity: SandwichModel.entity(), insertInto: context)
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
    
    let request: NSFetchRequest<SandwichModel> = SandwichModel.fetchRequest()
    
    var predicates: [NSPredicate] = []
    
    if !searchText.isEmpty {
      let searchTextPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
      predicates.append(searchTextPredicate)
    }

    if let sauceAmount = sauceAmount, sauceAmount != .any {
      let sauceAmountPredicate = NSPredicate(format: "sauceAmount.sauceAmountString == %@", sauceAmount.rawValue)
      predicates.append(sauceAmountPredicate)
    }
    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    
    let sort = NSSortDescriptor(key: #keyPath(SandwichModel.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
    request.sortDescriptors = [sort]
    do {
      filteredSandwiches = try context.fetch(request)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    tableView?.reloadData()
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

    cell.thumbnail.image = sandwich.imageName.map(UIImage.init(imageLiteralResourceName:))
    cell.nameLabel.text = sandwich.name
    cell.sauceLabel.text = sandwich.sauceAmount.map { String.init(describing:$0.sauceAmount) } ?? "--"
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
