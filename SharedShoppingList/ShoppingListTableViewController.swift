//
//  ShoppingListTableTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 22.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewCell: UITableViewCell{
    @IBOutlet var title: UILabel!
    
}


class ShoppingListTableViewController: UITableViewController,ShoppingListDetailViewControllerDelegate, NSFetchedResultsControllerDelegate {

    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<ShoppingList>!

    var selectedList: ShoppingList?
    

     fileprivate func initializeFetchedResultsController() {
         
         let fetchRequest = NSFetchRequest<ShoppingList>(entityName: "ShoppingList")
         // Configure the request's entity, and optionally its predicate
         
         //fetchRequest.predicate = NSPredicate(format: "isItemOfList == %@", list!)
         
         fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
         fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath:  nil, cacheName: nil)
         
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ShoppingListTableViewCell

        let list = fetchedResultsController.object(at: indexPath)
        
        cell.title.text = list.name
        
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

    
    fileprivate func getName(title: String, body: String, cancelButton: String, cancelCallback:@escaping () -> Void, confirmButton: String, confirmCallback:@escaping (String) -> Void) {
           
           let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
           
           let cancelAction = UIAlertAction(title: cancelButton,
                                            style: .cancel) { (action) in
                                               cancelCallback()
           }
           let confirmAction = UIAlertAction(title: confirmButton,
                                             style: .default) { (action) in
                                               let name = (alert.textFields!.first! as UITextField).text
                                               confirmCallback(name!)
           }
           
           alert.addAction(cancelAction)
           alert.addAction(confirmAction)
           alert.addTextField(configurationHandler: {textField in
               textField.text = ""
               textField.clearButtonMode = .always
               textField.clearsOnBeginEditing = false
               textField.autocorrectionType = .yes
           })

           self.present(alert, animated: true, completion: nil)
       }
       
     
    
    
    
    
    @IBAction func addList(_ sender: Any) {
        getName(title: "New list definition", body: "Enter name:", cancelButton: "Cancel", cancelCallback: {}, confirmButton: "Okay"){ name in
                        
            let list = NSEntityDescription.insertNewObject(forEntityName: "ShoppingList", into: self.managedContext) as! ShoppingList
            list.name = name // no need to use KVC! class is auto-generated
            print ("New = \(name)")
            
            self.appDelegate.saveContext()
        }
}

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue triggered")
        if let cell = (sender as? UITableViewCell){
            if let indexPath = tableView.indexPath(for: cell) {
                selectedList = fetchedResultsController.object(at: indexPath)
                
                switch (segue.identifier ?? ""){
                case "goToItem":
                    let vc = segue.destination as! ItemTableViewController
                    vc.list = selectedList
                    
                case "goToShoppingListDetail":
                    let vc = segue.destination as! ShoppingListDetailViewController
                    vc.delegate = self
                    vc.list = selectedList
                    
                default:
                    ()
                }
            }
        }
    }
    
    
    
    /** See here ho to define unwind segue for auto-going back: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/UsingSegues.html
     */
    @IBAction func unwindToShoppingListScene(segue: UIStoryboardSegue) {
        
        switch (segue.identifier ?? ""){
        case "returnFromShoppingListDetail":
            print("returnFromShoppingListDetail")
            if let list = selectedList {
                list.name = (segue.source as! ShoppingListDetailViewController).name.text
            }
        default:
            ()
        }
        
        if self.viewIfLoaded?.window != nil { // if viewController is visible
            appDelegate.saveContext() // called for "returnFromShoppingListDetail"
        }
    
    }
}
