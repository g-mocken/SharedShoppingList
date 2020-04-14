//
//  ItemTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 23.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData


class ItemTableViewCell: UITableViewCell{
    @IBOutlet var title: UILabel!
    @IBOutlet var unit: UILabel!
    @IBOutlet var amount: UILabel!
    
}

class ItemTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    var selectedItem: Item?

    var list: ShoppingList?
    
 /** See: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html#//apple_ref/doc/uid/TP40001075-CH8-SW1
 */
    var fetchedResultsController: NSFetchedResultsController<Item>!
   

    
    fileprivate func initializeFetchedResultsController() {
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        // Configure the request's entity, and optionally its predicate
        
        fetchRequest.predicate = NSPredicate(format: "isItemOfList == %@", list!)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "isAssignedToShop.name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare)), NSSortDescriptor(key: "product.name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]

        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: "isAssignedToShop.name", cacheName: nil)
        
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext

        initializeFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
                      
    }
    
    
    var saveNeeded:Bool = false
    var shopsUpdated:Bool = false



    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (saveNeeded){ // triggered after change of category in rewind segue
            appDelegate.saveContext() // saving after "returnFromProductCategory" must be deferred until the view is visible, because otherwise it causes problems
            saveNeeded = false
        }
        
            
        if (shopsUpdated){ // triggered by rename of category via explicit notification
            // fetch updated shops
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to fetch entities: \(error)")
            }
            
            // reload complete table
            if !tableView.hasUncommittedUpdates {
                tableView.reloadData()
            }
            shopsUpdated = false
        }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print ("\(fetchedResultsController.sections!.count) sections")
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sections = fetchedResultsController.sections
        let sectionInfo = sections![section]
        print ("\(sectionInfo.numberOfObjects) objects in section \(section)")
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = fetchedResultsController.sections
        let sectionInfo = sections![section]
        print ("Header = \(sectionInfo.name)")
        return sectionInfo.name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell

        let item = fetchedResultsController.object(at: indexPath)

        cell.title.text =  item.product!.name
        cell.amount.text =  String(format: "%d ×", item.multiplier)
        cell.unit.text = combinedUnit(item.unit)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                let itemToDelete = fetchedResultsController.object(at: indexPath)
                managedContext.delete(itemToDelete)
                appDelegate.saveContext()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError()
        }
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }
     
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !tableView.isEditing
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue triggered")
        if let cell = (sender as? UITableViewCell){
            if let indexPath = tableView.indexPath(for: cell) {
                selectedItem = fetchedResultsController.object(at: indexPath)
                
                switch (segue.identifier ?? ""){
                case "goToItemDetail":
                    let vc = segue.destination as! ItemDetailViewController
                    vc.item = selectedItem
                    
                    
                default:
                    ()
                }
            }
        }
    }
    
    

    
    @IBAction func unwindToItemScene(segue: UIStoryboardSegue) {
        
        switch (segue.identifier ?? ""){
        case "returnFromProductSelection":
            print("returnFromProductSelection")
            
            if let selectedProduct = (segue.source as! ProductSelectionTableViewController).selectedProduct {
                
                let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as! Item
                newItem.product = selectedProduct
                newItem.multiplier = 1
                newItem.unit = selectedProduct.hasUnits?.anyObject() as? Unit // initially pick arbitrary unit
                list?.addToHasItems(newItem )
                appDelegate.saveContext()
            }
        case "returnFromItemDetail":
            print("returnFromItemDetail")
            self.shopsUpdated = true
            // fetch updated shops
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to fetch entities: \(error)")
            }
            
            // reload complete table
            if !tableView.hasUncommittedUpdates {
                tableView.reloadData()
            }
        default:
            ()
        }
    }

}
