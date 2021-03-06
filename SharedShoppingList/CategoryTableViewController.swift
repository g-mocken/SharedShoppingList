//
//  CategoryTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 18.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewCell: UITableViewCell{
    @IBOutlet var title: UILabel!
    
}

protocol CategoryTableViewControllerDelegate: AnyObject {

}



    
class CategoryTableViewController: UITableViewController, CategoryDetailViewControllerDelegate, ShopsForCategoriesTableViewControllerDelegate, NSFetchedResultsControllerDelegate {

    weak var delegate:CategoryTableViewControllerDelegate?

    var selectedCategory: ProductCategory? // for checkmark
    var currentCategory: ProductCategory? // the one being edited

    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!

    var fetchedResultsController: NSFetchedResultsController<ProductCategory>!

    
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
        // When selected via the "more" tab, the view controller starts with the toolbar hidden, so unhide it in this case.
        if (self.navigationController!.isToolbarHidden){
            self.navigationController!.setToolbarHidden(false, animated: false)
        }
        super.viewWillAppear(animated)
        
        if (delegate != nil) {
            print("category VC for selection")
        } else {
            print("category VC for editing")
            selectedCategory = nil
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
  
    fileprivate func initializeFetchedResultsController() {
        
        let fetchRequest = NSFetchRequest<ProductCategory>(entityName: "ProductCategory")
        // Configure the request's entity, and optionally its predicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        print ("updating \(indexPath)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        
        let category = fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: indexPath.section))
        
        cell.title.text = category.name
        if (selectedCategory == category) && (delegate != nil) {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    
    
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
        
        var indexPathShifted : IndexPath?
        if (indexPath != nil){
            indexPathShifted = IndexPath(row: indexPath!.row, section: indexPath!.section)
        }
        
        var newIndexPathShifted : IndexPath?
        if (newIndexPath != nil){
            newIndexPathShifted = IndexPath(row: newIndexPath!.row, section: newIndexPath!.section)
        }
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPathShifted!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPathShifted!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPathShifted!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPathShifted!, to: newIndexPathShifted!)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        if !tableView.hasUncommittedUpdates { tableView.reloadData() }
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let categoryToDelete = fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: indexPath.section))
            if categoryToDelete == selectedCategory {
                selectedCategory = nil
            }
            managedContext.delete(categoryToDelete)
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("Selected: row =\(indexPath.row), section=\(indexPath.section)\n")
//        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    
    
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
    
    @IBAction func addListItem(_ sender: Any) {
        
        getName(title: "New category definition", body: "Enter name:", cancelButton: "Cancel", cancelCallback: {}, confirmButton: "Okay"){ name in
                        
            let category = NSEntityDescription.insertNewObject(forEntityName: "ProductCategory", into: self.managedContext) as! ProductCategory
            category.name = name // no need to use KVC! class is auto-generated
            
            print ("New = \(name)")
            
            self.appDelegate.saveContext()
        }
        
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue triggered")
       // print("sender: \(sender)") // cell for direct connection, or tableViewcontroller for manual performSegue

        switch (segue.identifier ?? ""){
            
        case "goToCategoryDetail":
            let vc = segue.destination as! CategoryDetailViewController
            vc.delegate = self
            if let indexPath = tableView.indexPath(for: (sender as? UITableViewCell)!) {
                currentCategory = fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: indexPath.section))
                vc.category = currentCategory
            }
            
        case "goToShops":
            let vc = segue.destination as! ShopsForCategoriesTableViewController
            vc.delegate = self
            if let indexPath = tableView.indexPath(for: (sender as? UITableViewCell)!) {
                currentCategory = fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: indexPath.section))
                vc.category = currentCategory
            }
            
        default:
            ()
        }
    }
    
    
    /** See here ho to define unwind segue for auto-going back: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/UsingSegues.html
     */
    @IBAction func unwindToCategoryEditorScene(segue: UIStoryboardSegue) {
        
        switch (segue.identifier ?? ""){
        case "returnFromCategoryDetailToEditor":
            print("returnFromCategoryDetailToEditor")
            print("from: \(segue.source)")
            print("to: \(segue.destination)")
            currentCategory?.name = (segue.source as! CategoryDetailViewController).name.text
            NotificationCenter.default.post(name: Notification.Name("categoriesUpdated"), object: nil)
            appDelegate.saveContext()
        default:
            ()
        }
    
    }
    
}
