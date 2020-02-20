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
    func selected(item:Int)->Void
}



    
class CategoryTableViewController: UITableViewController {

    weak var delegate:CategoryTableViewControllerDelegate?
    var selectedIndexPath: IndexPath?

    
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
          
          
          let fetchRequest =
              NSFetchRequest<ProductCategory>(entityName: "ProductCategory")
          
          do {
              categories = try managedContext.fetch(fetchRequest)
              // products.sort(by: {a,b in return a.name! < b.name!}) // wrong sorting of umlauts etc.
              categories.sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }

          } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
          }
        
        if (selectedIndexPath != nil){
            let cell = self.tableView(tableView, cellForRowAt: selectedIndexPath!)
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
      }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell

        let category = categories[indexPath.row]
        
           // Configure the cell...
        cell.title.text = category.name
        // Configure the cell...
        
        if  selectedIndexPath?.row == indexPath.row {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none

        }

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let categoryToDelete = categories[indexPath.row]

            managedContext.delete(categoryToDelete)
            
            // save
            do {
                try managedContext.save()
                categories.remove(at: indexPath.row)
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

        selectedIndexPath = indexPath

        tableView.reloadData()
        delegate?.selected(item:selectedIndexPath!.row)
        
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
