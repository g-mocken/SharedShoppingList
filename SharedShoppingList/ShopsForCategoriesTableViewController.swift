//
//  ShopsForCategoriesTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 14.04.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

protocol ShopsForCategoriesTableViewControllerDelegate: AnyObject {

}


class ShopForCategoryTableViewCell: UITableViewCell{
    @IBOutlet var title: UILabel!
    
}

class ShopsForCategoriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var category:ProductCategory?
    
    weak var delegate:ShopsForCategoriesTableViewControllerDelegate?
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var fetchedResultsController: NSFetchedResultsController<Shop>!
    
    
    
    fileprivate func initializeFetchedResultsController() {
        
        let fetchRequest = NSFetchRequest<Shop>(entityName: "Shop")
        // Configure the request's entity, and optionally its predicate
        
        fetchRequest.predicate = NSPredicate(format: "hasCategories contains %@", category!)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
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
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        
        initializeFetchedResultsController()
        
        
    }

    // MARK: - Table view data source


   override func numberOfSections(in tableView: UITableView) -> Int {
       return fetchedResultsController.sections!.count
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       let sections = fetchedResultsController.sections
       let sectionInfo = sections![section]
       //print ("\(sectionInfo.numberOfObjects) objects in section \(section)")
       return sectionInfo.numberOfObjects
   }
   
   

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopCell", for: indexPath) as! ShopForCategoryTableViewCell
        
        let shop = fetchedResultsController.object(at: indexPath)
        
        cell.title.text = shop.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         let sections = fetchedResultsController.sections
         let sectionInfo = sections![section]
         print ("Header = \(sectionInfo.name)")
         return sectionInfo.name
     }
     
     var pathsToUpdate:[IndexPath]?
     
     func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         tableView.beginUpdates()
         pathsToUpdate = Array()
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
             pathsToUpdate?.append(newIndexPath!) // save destination index path for deferred update
             tableView.moveRow(at: indexPath!, to: newIndexPath!)
         @unknown default:
             fatalError()
         }
     }
     
     func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         tableView.endUpdates()
         
         // perform deferred update
         if let indexPaths = pathsToUpdate {
             tableView.reloadRows(at: indexPaths, with: .fade)
         }
         pathsToUpdate=nil
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
             let listToDelete = fetchedResultsController.object(at: indexPath)
             managedContext.delete(listToDelete)
             appDelegate.saveContext()
             
         } else if editingStyle == .insert {
             // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
         
         
     }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
      @IBAction func unwindToShopsForCategoriesScene(segue: UIStoryboardSegue) {
          
          switch (segue.identifier ?? ""){
          case "returnFromShopSelection":
              print("returnFromShopSelection")
              
              if let selectedShop = (segue.source as! ShopSelectionTableViewController).selectedShop {
                  category?.addToIsAvailableInShops(selectedShop)
                  appDelegate.saveContext()
            }
              
          default:
              ()
          }
      }

}
