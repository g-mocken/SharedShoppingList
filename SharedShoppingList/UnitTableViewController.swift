//
//  UnitTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 02.03.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

class UnitTableViewCell:UITableViewCell{
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
}


class UnitTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBAction func numberEditingDidEndAction(_ sender: UITextField) {
        if let text = sender.text {
            if let number = Int16(text){
                unitFor(sender: sender).number = number
                save()
            }
        }
    }
    
    @IBAction func nameEditingDidEndAction(_ sender: UITextField) {
        unitFor(sender: sender).name = sender.text
        save()
    }
    
    fileprivate func unitFor(sender: UITextField)->(Unit) {
        // Use trick from StackOverflow: convert origin to point, then point to indexPath
        let origin: CGPoint = sender.frame.origin
        let point: CGPoint? = sender.superview?.convert(origin, to: self.tableView)
        let indexPath: IndexPath? = self.tableView.indexPathForRow(at: point ?? CGPoint.zero)
        let unit = fetchedResultsController.object(at: indexPath!)
        return unit
    }
    
    var appDelegate: AppDelegate!
       var managedContext: NSManagedObjectContext!

       
    /** See: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html#//apple_ref/doc/uid/TP40001075-CH8-SW1
    */
       var fetchedResultsController: NSFetchedResultsController<Unit>!
      

       
       fileprivate func initializeFetchedResultsController() {
           
           let fetchRequest = NSFetchRequest<Unit>(entityName: "Unit")
           // Configure the request's entity, and optionally its predicate
           
          // fetchRequest.predicate = NSPredicate(format: "isItemOfList == %@", list!)

           fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare)), NSSortDescriptor(key: "number", ascending: true, selector: nil)]
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
        return sectionInfo.numberOfObjects + 1 // one extra for inserting new at the end
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "unitCell", for: indexPath) as! UnitTableViewCell
        if (indexPath.row < tableView.numberOfRows(inSection: indexPath.section)-1){
            let unit = fetchedResultsController.object(at: indexPath)
            cell.nameTextField.text = unit.name
            cell.numberTextField.text = String(unit.number)
            cell.isUserInteractionEnabled = tableView.isEditing
        } else {
            cell.nameTextField.text = NSLocalizedString("Select edit to add item...", comment: "")
            cell.numberTextField.text = ""
            cell.nameTextField.isUserInteractionEnabled = false
            cell.numberTextField.isUserInteractionEnabled = false
        }
        print("reloading cell at index path \(indexPath)")

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
            return .insert;
        } else {
            return .delete;
        }
    }
    


    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let unitToDelete = fetchedResultsController.object(at: indexPath)
            managedContext.delete(unitToDelete)
            save()
            
        } else if editingStyle == .insert {
            let unit = NSEntityDescription.insertNewObject(forEntityName: "Unit", into: self.managedContext) as! Unit
            unit.name = "unit"
            unit.number = 1            
            save()
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool){
        super.setEditing(editing,animated: animated)
       
        // enable/disable editing of textfields (in fact the whole cell) without interfering with the animation
        if (tableView.isEditing){
            print("switch edit mode on")
            for row in 0...tableView.numberOfRows(inSection: 0)-2{
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! UnitTableViewCell
                cell.isUserInteractionEnabled = true
            }
        }
        else {
            print("switch edit mode off")
            for row in 0...tableView.numberOfRows(inSection: 0)-2{
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! UnitTableViewCell
                cell.isUserInteractionEnabled = false
            }
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
    // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        // segues (show, show detail) connected to the cell run before this code
        print("Selected: row =\(indexPath.row), section=\(indexPath.section)\n")
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if tableView.isEditing {
            //let cell = tableView.cellForRow(at: indexPath) as! UnitTableViewCell
        }
    }
    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
