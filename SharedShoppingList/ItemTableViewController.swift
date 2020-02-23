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

    var list: ShoppingList?
    
 /** See: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html#//apple_ref/doc/uid/TP40001075-CH8-SW1
 */
    var fetchedResultsController: NSFetchedResultsController<Item>!
   

    
    fileprivate func initializeFetchedResultsController() {
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        // Configure the request's entity, and optionally its predicate
        
        fetchRequest.predicate = NSPredicate(format: "isItemOfList == %@", list!)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "product.name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    

    fileprivate func save() {
        // save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //print ("\(fetchedResultsController.sections!.count) sections")
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sections = fetchedResultsController.sections
        let sectionInfo = sections![section]
        //print ("\(sectionInfo.numberOfObjects) objects in section \(section)")
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell

        let item = fetchedResultsController.object(at: indexPath)

        cell.title.text =  item.product!.name
        cell.amount.text =  String(format: "%d", item.multiplier)
        cell.unit.text =  "unit"

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
                save()
            
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


    
    @IBAction func unwindToItemScene(segue: UIStoryboardSegue) {
        
        switch (segue.identifier ?? ""){
        case "returnFromProductSelection":
            print("returnFromProductSelection")
            
            if let selectedProduct = (segue.source as! ProductSelectionTableViewController).selectedProduct {
                                
                let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as! Item
                newItem.product = selectedProduct
                newItem.multiplier = 1
                list?.addToHasItems(newItem )
                save()
            }
        default:
            ()
        }
    }

}
