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


class ShoppingListTableViewController: UITableViewController {

    var shoppingLists: [ShoppingList] = []
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
        buildArrays()
        tableView.reloadData()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingLists.count
    }

    
    fileprivate func buildArrays() {
        
        let fetchRequest =
            NSFetchRequest<ShoppingList>(entityName: "ShoppingList")
        
        do {
            shoppingLists = try managedContext.fetch(fetchRequest)
            // products.sort(by: {a,b in return a.name! < b.name!}) // wrong sorting of umlauts etc.
            shoppingLists.sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ShoppingListTableViewCell

       
        let  list = shoppingLists[indexPath.row]
        
        cell.title.text = list.name
        
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
            let listToDelete = shoppingLists[indexPath.row]

            managedContext.delete(listToDelete)
            
            // save
            do {
                try managedContext.save()
                shoppingLists.remove(at: indexPath.row)
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
            
            // save
            do {
                try self.managedContext.save()
                self.shoppingLists.append(list)
                self.shoppingLists.sort { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }

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
