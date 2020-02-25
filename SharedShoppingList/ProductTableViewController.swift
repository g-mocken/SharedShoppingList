//
//  ProductTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 16.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

extension Product {
    @objc var computedName:String { // @objc is crucial for making it KVC compliant!
        get {
            if belongsToCategory != nil {
                return belongsToCategory!.name!
            } else {
                return "special"
            }
        }
    }
}


class ProductTableViewCell: UITableViewCell{
    @IBOutlet var title: UILabel!
}

class ProductTableViewController: UITableViewController, CategoryTableViewControllerDelegate, ProductDetailViewControllerDelegate, NSFetchedResultsControllerDelegate {
  
//    
//    func updateCategories() {
//        buildArrays()
//    }
//    
    
//    var categories: [ProductCategory] = []
//    var productsInSections: [[Product]] = [[]]
//
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
   
    /** See: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html#//apple_ref/doc/uid/TP40001075-CH8-SW1
    */
    var fetchedResultsController: NSFetchedResultsController<Product>!

    
    var selectedProduct: Product?
    
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
    
    
    fileprivate func save() {
        // save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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
    
    /*
    
    fileprivate func buildArrays() {
        let fetchRequest1 =
            NSFetchRequest<Product>(entityName: "Product")
        fetchRequest1.predicate = NSPredicate(format: "belongsToCategory == nil")
        
        var uncategorizedProducts: [Product] = []
        
        do {
            uncategorizedProducts = try managedContext.fetch(fetchRequest1)
            // products.sort(by: {a,b in return a.name! < b.name!}) // wrong sorting of umlauts etc.
            uncategorizedProducts.sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        let fetchRequest2 =
            NSFetchRequest<ProductCategory>(entityName: "ProductCategory")
        
        do {
            categories = try managedContext.fetch(fetchRequest2)
            // products.sort(by: {a,b in return a.name! < b.name!}) // wrong sorting of umlauts etc.
            categories.sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        productsInSections = [uncategorizedProducts] // put uncategorized products in first setion #0
        
        for c in categories {
            fetchRequest1.predicate = NSPredicate(format: "belongsToCategory == %@", c)
            fetchRequest1.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare))]
            do {
                productsInSections.append(try managedContext.fetch(fetchRequest1))
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        buildArrays()
//        tableView.reloadData()

    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return fetchedResultsController.sections!.count

//        return categories.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections
        let sectionInfo = sections![section]
        //print ("\(sectionInfo.numberOfObjects) objects in section \(section)")
        return sectionInfo.numberOfObjects
        
        //        return productsInSections[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let product = fetchedResultsController.object(at: indexPath)

       // let  product = productsInSections[indexPath.section][indexPath.row]

        // Configure the cell...
        cell.title.text = product.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = fetchedResultsController.sections
        let sectionInfo = sections![section]

        return sectionInfo.name != "" ? sectionInfo.name : "Uncategorized"
        
        //        if section == 0 { // special "unknown category"
//            return NSLocalizedString("Uncategorized", comment: "")
//        } else {
//            return categories[section-1].name
//        }
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

//            let productToDelete = productsInSections[indexPath.section][indexPath.row]
//
//            managedContext.delete(productToDelete)
//            
//            // save
//            do {
//                try managedContext.save()
//                productsInSections[indexPath.section].remove(at: indexPath.row)
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
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
        print("Selected: row =\(indexPath.row), section=\(indexPath.section)\n")
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        //selectedProduct = productsInSections[indexPath.section][indexPath.row] // too late! runs after segue.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue triggered")

        switch (segue.identifier ?? ""){
        case "goToCategory":
            let vc = segue.destination as! CategoryTableViewController
            vc.delegate = self
            if let indexPath = tableView.indexPathForSelectedRow {
                selectedProduct = fetchedResultsController.object(at: indexPath)
                //selectedProduct = productsInSections[indexPath.section][indexPath.row]
                vc.selectedCategory = selectedProduct?.belongsToCategory
            }
        case "goToProductDetail":
            let vc = segue.destination as! ProductDetailViewController
            vc.delegate = self
            if let indexPath = tableView.indexPath(for: (sender as? UITableViewCell)!) {
                selectedProduct = fetchedResultsController.object(at: indexPath)
                //selectedProduct = productsInSections[indexPath.section][indexPath.row]
                vc.product = selectedProduct
            }
        default:
            ()
        }
    }
    
    
    
    /**
     Called by the sub-table on selecting a row
     */
    func assignCategoryToSelectedProduct(category:ProductCategory?)->Void {
        
        if let product = selectedProduct
        {
            print("Assigning category \(category?.name ?? "nil") to the selected product \(product.name ?? "nil")")
            product.belongsToCategory=category
            // save
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
         //   buildArrays()
            
        }
       // tableView.reloadData()
    }
    
    
    
    /** See here ho to define unwind segue for auto-going back: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/UsingSegues.html
     */
    @IBAction func unwindToProductScene(segue: UIStoryboardSegue) {
        
        switch (segue.identifier ?? ""){
        case "returnFromProductDetail":
            print("returnFromProductDetail")
            if let product = selectedProduct
            {
                product.name = (segue.source as! ProductDetailViewController).name.text
               
                save()
                
                
            
                
//                // save
//                do {
//                    try managedContext.save()
//                } catch let error as NSError {
//                    print("Could not save. \(error), \(error.userInfo)")
//                }
//                buildArrays()
            }
        //    tableView.reloadData()

            
            
        case "returnFromProductCategory":
            print("returnFromProductCategory")
            // this is triggered before the selection is triggered
        default:
            ()
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
            
//            // save
//            do {
//                try self.managedContext.save()
//                self.productsInSections[0].append(product)
//                self.productsInSections[0].sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }
//
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//
//            print("Did save")
//            self.tableView.reloadData()
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
