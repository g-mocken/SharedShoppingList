//
//  ItemDetailViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 29.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailViewController: UIViewController {
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!

    var item:Item?
    
    @IBOutlet var multiplierLabel: UILabel!
    @IBOutlet var multiplierStepper: UIStepper!
    @IBOutlet var name: UILabel!
    
    @IBAction func changeNumber(_ sender: UIStepper) {
        setMultiplierTo(value: Int16(sender.value))
    }
    
    
    fileprivate func setMultiplierTo(value:Int16){
        multiplierLabel.text = String(format: "%d", value)
        item?.multiplier = value
        save()

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

        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        name.text = item?.product?.name
        setMultiplierTo(value: item?.multiplier ?? 0)
        multiplierStepper.value = Double(item?.multiplier ?? 0)
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
