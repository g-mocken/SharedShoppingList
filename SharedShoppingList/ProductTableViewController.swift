//
//  ProductTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 16.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

let uncategorized = NSLocalizedString("No Category", comment: "")

/// Extension to catch uncategorized products and give them a reasonable name
extension Product {
    @objc var computedName:String { // @objc is crucial for making it KVC compliant!
        get {
            if belongsToCategory != nil {
                return belongsToCategory!.name!
            } else {
                return uncategorized
            }
        }
        set(name) {
            if belongsToCategory != nil {
                belongsToCategory!.name = name
            }
        }
    }
}


class ProductTableViewCell: UITableViewCell{
    @IBOutlet var title: UILabel!
}

class ProductTableViewController: UITableViewController, CategoryTableViewControllerDelegate, ProductDetailViewControllerDelegate, NSFetchedResultsControllerDelegate {
  
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
   
    /** See: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html#//apple_ref/doc/uid/TP40001075-CH8-SW1
    */
    var fetchedResultsController: NSFetchedResultsController<Product>!

    
    var selectedProduct: Product?
      
    
    fileprivate func save() {
        // save
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    fileprivate func initializeFetchedResultsController() {
        
        let fetchRequest = NSFetchRequest<Product>(entityName: "Product")
        // Configure the request's entity, and optionally its predicate
        
        //fetchRequest.predicate = NSPredicate(format: "isItemOfList == %@", list!)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "belongsToCategory.name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare)), NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath:  "computedName", cacheName: nil)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        save() // must be deferred until the view is visible, because it triggers table updates
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        if !tableView.hasUncommittedUpdates { tableView.reloadData() }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let product = fetchedResultsController.object(at: indexPath)
        // Configure the cell...
        cell.title.text = product.name
        print ("updating \(indexPath)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = fetchedResultsController.sections
        let sectionInfo = sections![section]
        print ("Header = \(sectionInfo.name)")
        return sectionInfo.name
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
        if !tableView.hasUncommittedUpdates { tableView.reloadData() }
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            let productToDelete = fetchedResultsController.object(at: indexPath)
            managedContext.delete(productToDelete)
            save()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        // segues (show, show detail) connected to the cell run before this code
        print("Selected: row =\(indexPath.row), section=\(indexPath.section)\n")
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue triggered")
        
        if let cell = (sender as? UITableViewCell){
            if let indexPath = tableView.indexPath(for: cell) {
                selectedProduct = fetchedResultsController.object(at: indexPath)
                switch (segue.identifier ?? ""){
                case "goToCategory":
                    print("goToCategory")
                    let vc = segue.destination as! CategoryTableViewController
                    vc.delegate = self
                    vc.selectedCategory = selectedProduct?.belongsToCategory
                    
                case "goToProductDetail":
                    print("goToProductDetail")

                    let vc = segue.destination as! ProductDetailViewController
                    vc.delegate = self
                    vc.product = selectedProduct
                    
                default:
                    ()
                }
            }
        }
    }

    
    
    /** See here ho to define unwind segue for auto-going back: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/UsingSegues.html
     */
    @IBAction func unwindToProductScene(segue: UIStoryboardSegue) {
            
            switch (segue.identifier ?? ""){
            case "returnFromProductDetail":
                print("returnFromProductDetail")
                selectedProduct!.name = (segue.source as! ProductDetailViewController).name.text
                print ("setting to \(selectedProduct!.name!)")
                
            case "returnFromProductCategory":
                print("returnFromProductCategory")
                // If the unwind segue is connected to the category cell, it is triggered before the category cell "didSelect" code is run
                let category = (segue.source as! CategoryTableViewController).selectedCategory
                selectedProduct!.belongsToCategory = category
                //print("Assigning category \(category?.name ?? "nil") to the selected product \(product.name ?? "nil")")
            
            default:
                ()
            }
            if self.viewIfLoaded?.window != nil {
                // viewController is visible
                save()
                tableView.reloadData()
            }
        
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
        
        getName(title: "New product definition", body: "Enter name:", cancelButton: "Cancel", cancelCallback: {}, confirmButton: "Okay"){ name in
                        
            let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: self.managedContext) as! Product
            product.name = name // no need to use KVC! class is auto-generated
            product.belongsToCategory = nil //self.categories[0] // for testing, assign fixed category
            print ("New = \(name)")
    
            self.save()
        }
    }
    
   
    
}
