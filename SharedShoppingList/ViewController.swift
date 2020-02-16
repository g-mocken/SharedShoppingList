//
//  ViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 09.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var category:ProductCategory!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        
   

    
        
        
    }


    @IBAction func add() {
        let managedContext =
            appDelegate.persistentContainer.viewContext

        //        let entity =
        //          NSEntityDescription.entity(forEntityName: "Person",
        //                                     in: managedContext)!
        //        let person = NSManagedObject(entity: entity,
        //                                     insertInto: managedContext)
        
        
        // add three items
        
        let item1 = NSEntityDescription.insertNewObject(forEntityName: "Product", into: managedContext) as! Product
        item1.name = "eggs" // no need to use KVC! class is auto-generated
        
        let item2 = NSEntityDescription.insertNewObject(forEntityName: "Product", into: managedContext) as! Product
        item2.name = "milk"
        
        let item3 = NSEntityDescription.insertNewObject(forEntityName: "Product", into: managedContext) as! Product
        item3.name = "butter"
        
        
        
        // add one product category
        
        category = NSEntityDescription.insertNewObject(forEntityName: "ProductCategory", into: managedContext) as? ProductCategory
        category.name = "dairy"
        
        
        
        // link the thee items to the product category
        let itemSet:NSSet = [item1, item2, item3]
        category.addToIsCategoryOfProduct(itemSet)
        
        
        
        
        // save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        print("Did save")
        
        
        
    }
    @IBAction func fetch() {
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
           let fetchRequest =
             NSFetchRequest<ProductCategory>(entityName: "ProductCategory")
           
           let categoryRead:[ProductCategory]

           do {
               categoryRead = try managedContext.fetch(fetchRequest)
              
               for cat in categoryRead {
                print ( "Name: \(String(describing: cat.name))")
                print ("Children: \(String(describing: cat.isCategoryOfProduct))")
               }
            if (categoryRead.count>0) { category = categoryRead[0] }

           } catch let error as NSError {
               print("Could not fetch. \(error), \(error.userInfo)")
           }

    }
    @IBAction func delete() {
        let managedContext =
            appDelegate.persistentContainer.viewContext

        managedContext.delete(category)
        
        
        
        // save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        print("Did save")
        
        
        
        
    }
}

