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
    func assignCategoryToSelectedProduct(category:ProductCategory?)->Void
  //  func updateCategories()
}



    
class CategoryTableViewController: UITableViewController, CategoryDetailViewControllerDelegate {

    weak var delegate:CategoryTableViewControllerDelegate?

    var selectedCategory: ProductCategory?
    
    
    var categories: [ProductCategory] = []
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext

    }

    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
      
        if (delegate != nil) {
            print("category VC for selection")
        } else {
            print("category VC for editing")
            selectedCategory = nil
            // TODO: cell selection -> edit name
        }
        
        buildArrays()
        tableView.reloadData()

      
        
    }
    
    
    fileprivate func buildArrays() {
        
        let fetchRequest =
            NSFetchRequest<ProductCategory>(entityName: "ProductCategory")
        
        do {
            categories = try managedContext.fetch(fetchRequest)
            // products.sort(by: {a,b in return a.name! < b.name!}) // wrong sorting of umlauts etc.
            categories.sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell

        if indexPath.row == 0 {
            cell.title.text = NSLocalizedString("Uncategorized", comment: "")

            if (selectedCategory == nil) && (delegate != nil){
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        } else {
            let category = categories[indexPath.row-1]
            cell.title.text = category.name
            if (selectedCategory == categories[indexPath.row-1]) && (delegate != nil) {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
        
    
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return indexPath.row != 0
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let categoryToDelete = categories[indexPath.row-1]

            managedContext.delete(categoryToDelete)
            
            // save
            do {
                try managedContext.save()
                categories.remove(at: indexPath.row-1)
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
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        if (delegate != nil) {
            performSegue(withIdentifier: "returnFromProductCategory", sender: self)
        } else {
            print("not returning")
        }

        tableView.reloadData()
        
        if indexPath.row == 0 {
            delegate?.assignCategoryToSelectedProduct(category:nil)
            selectedCategory = nil
        } else {
            selectedCategory = categories[indexPath.row-1]
            delegate?.assignCategoryToSelectedProduct(category:selectedCategory)
        }
        delegate = nil
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
            
            // save
            do {
                try self.managedContext.save()
                self.categories.append(category)
                self.categories.sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }

            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            print("Did save")
            self.tableView.reloadData()
           // self.delegate?.updateCategories()
        }
        
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue triggered")

              switch (segue.identifier ?? ""){
         
              case "goToCategoryDetail":
                  let vc = segue.destination as! CategoryDetailViewController
                  vc.delegate = self
                  if let indexPath = tableView.indexPath(for: (sender as? UITableViewCell)!) {
                      selectedCategory = categories[indexPath.row-1]
                      vc.category = selectedCategory
                  }
              default:
                  ()
              }    }


    
    
    /** See here ho to define unwind segue for auto-going back: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/UsingSegues.html
     */
    @IBAction func unwindToCategoryScene(segue: UIStoryboardSegue) {
        
        switch (segue.identifier ?? ""){
        case "returnFromCategoryDetail":
            print("returnFromCategoryDetail")
            if let category = selectedCategory
            {
                category.name = (segue.source as! CategoryDetailViewController).name.text
                // save
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                buildArrays()
            }
            tableView.reloadData()

            
            
        default:
            ()
        }
    
    }
    
    
}
