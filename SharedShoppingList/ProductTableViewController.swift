//
//  ProductTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 16.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData


class ProductTableViewCell: UITableViewCell{
    @IBOutlet var title: UILabel!
    
}
class ProductTableViewController: UITableViewController, CategoryTableViewControllerDelegate {
    func updateCategories() {
        buildArrays()
    }
    
    
    var categories: [ProductCategory] = []
    var productsInSections: [[Product]] = [[]]
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    
    var selectedProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext

    }
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildArrays()
        tableView.reloadData()
        print("reload")

    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categories.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return productsInSections[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        
        let  product = productsInSections[indexPath.section][indexPath.row]

        // Configure the cell...
        cell.title.text = product.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { // special "unknown category"
            return NSLocalizedString("Uncategorized", comment: "")
        } else {
            return categories[section-1].name
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            let productToDelete = productsInSections[indexPath.section][indexPath.row]

            managedContext.delete(productToDelete)
            
            // save
            do {
                try managedContext.save()
                productsInSections[indexPath.section].remove(at: indexPath.row)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }

            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
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

        if segue.identifier == "goToCategory"{
            let vc = segue.destination as! CategoryTableViewController
            vc.delegate = self
            if let indexPath = tableView.indexPathForSelectedRow {
                selectedProduct = productsInSections[indexPath.section][indexPath.row]
                vc.selectedCategory = selectedProduct?.belongsToCategory
            }
        }
    }
    
    
    
    /**
     Called by the sub-table on selecting a row
     */
    func selected(item:ProductCategory?)->Void {
        
        if let sp = selectedProduct
        {
            print("Assigning selected product #\(sp) to selected category #\(String(describing: item))")
            sp.belongsToCategory=item
            // save
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            buildArrays()
            
        }
        tableView.reloadData()
        print("reload")
    }
    
    /** See here ho to define unwind segue for auto-going back: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/UsingSegues.html
     */
    @IBAction func unwindToParent(segue: UIStoryboardSegue) {
        print("coming back from selection table after selection")
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
            
            // save
            do {
                try self.managedContext.save()
                self.productsInSections[0].append(product)
                self.productsInSections[0].sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }

            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            print("Did save")
            self.tableView.reloadData()
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
