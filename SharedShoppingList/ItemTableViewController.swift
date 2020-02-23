//
//  ItemTableViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 23.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData


class ItemTableViewCell: UITableViewCell{
    @IBOutlet var title: UILabel!
    @IBOutlet var unit: UILabel!
    @IBOutlet var amount: UILabel!
    
}

class ItemTableViewController: UITableViewController {

    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!

    var items: [Item] = []

    var list: ShoppingList?
    
     fileprivate func buildArrays() {
         
         let fetchRequest =
             NSFetchRequest<Item>(entityName: "Item")
         fetchRequest.predicate = NSPredicate(format: "isItemOfList == %@", list!)
         

        
         do {
             items = try managedContext.fetch(fetchRequest)
             // products.sort(by: {a,b in return a.name! < b.name!}) // wrong sorting of umlauts etc.
            items.sort { $0.product!.name!.localizedCaseInsensitiveCompare($1.product!.name!) == ComparisonResult.orderedAscending }
             
         } catch let error as NSError {
             print("Could not fetch. \(error), \(error.userInfo)")
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
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell

        let item = items[indexPath.row]

        cell.title.text =  item.product!.name
        cell.amount.text =  String(format: "%d", item.multiplier)
        cell.unit.text =  "unit"

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
                let itemToDelete = items[indexPath.row]
                managedContext.delete(itemToDelete)
                
                // save
                do {
                    try managedContext.save()
                    items.remove(at: indexPath.row)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindToItemScene(segue: UIStoryboardSegue) {
        
        switch (segue.identifier ?? ""){
        case "returnFromProductSelection":
            print("returnFromProductSelection")
            
            if let selectedProduct = (segue.source as! ProductSelectionTableViewController).selectedProduct {
                                
                let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as! Item
                newItem.product = selectedProduct
                newItem.multiplier = 1
                list?.addToHasItems(newItem )

                
                // save
                do {
                    try self.managedContext.save()
                    self.items.append(newItem)
                    self.items.sort { $0.product!.name!.localizedCaseInsensitiveCompare($1.product!.name!) == ComparisonResult.orderedAscending }
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                
                
                buildArrays()
                tableView.reloadData()
                
               
            }
        default:
            ()
        }
    }

}
