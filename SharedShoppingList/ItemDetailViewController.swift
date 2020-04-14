//
//  ItemDetailViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 29.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

func combinedUnit(_ unit: Unit?)->String{
      if let unit = unit {
          return String(format: "%d", unit.number) + " " + unit.name!
      }
      else {
          return "unit not set"
      }
  }

class ItemDetailViewController: UIViewController {
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!

    var item:Item?
    
    @IBOutlet var multiplierLabel: UILabel!
    @IBOutlet var multiplierStepper: UIStepper!
    @IBOutlet var name: UILabel!
    @IBOutlet var unitPicker: UIButton!
    @IBOutlet var shopPicker: UIButton!
    
    @IBAction func changeNumber(_ sender: UIStepper) {
        setMultiplierTo(value: Int16(sender.value))
    }
    
    
    fileprivate func setMultiplierTo(value:Int16){
        multiplierLabel.text = String(format: "%d", value)
        item?.multiplier = value

        appDelegate.saveContext()

    }

  
    
    @IBAction func unitPickerAction(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Select unit size", comment: ""), message: NSLocalizedString("This list can be edited in the product details.", comment: ""), preferredStyle: .actionSheet)
        
        //  sub class alert action to be able to pass on the unit property
        class UnitAction:UIAlertAction{
            var unit: Unit?
            convenience init(unit: Unit, title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil){
                self.init(title: title, style: style, handler: handler) // call standard designated initializer
                self.unit = unit // assign extra property
            }
        }
        
        
        let selectAction: (UIAlertAction)->(Void) = { (action) in
            print (action.title!)
            // assign selected unit to item
            self.item?.unit = (action as! UnitAction).unit
            self.unitPicker.setTitle(combinedUnit((action as! UnitAction).unit!), for: .normal)
            self.appDelegate.saveContext()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel) { _ in  }
        
        alert.addAction(cancelAction)
        
        if let titles = item?.product?.hasUnits {
            for title in titles {
                let action = UnitAction(unit: title as! Unit, title: combinedUnit((title as! Unit)), style: .default, handler: selectAction)
                alert.addAction(action)
            }
        }
        
        self.present(alert, animated: true, completion: nil)
        
        // special code for iPad:
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = [UIPopoverArrowDirection.any]
        }
        
    }
    
    
    @IBAction func shopPickerAction(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Select shop", comment: ""), message: NSLocalizedString("This list can be edited in the shops tab.", comment: ""), preferredStyle: .actionSheet)
        
        //  sub class alert action to be able to pass on the shop property
        class ShopAction:UIAlertAction{
            var shop: Shop?
            convenience init(shop: Shop, title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil){
                self.init(title: title, style: style, handler: handler) // call standard designated initializer
                self.shop = shop // assign extra property
            }
        }
        
        
        let selectAction: (UIAlertAction)->(Void) = { (action) in
            print (action.title!)
            // assign selected shop to item
            self.item?.isAssignedToShop = (action as! ShopAction).shop
            self.shopPicker.setTitle((action as! ShopAction).shop?.name!, for: .normal)
            self.appDelegate.saveContext()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel) { _ in  }
        
        alert.addAction(cancelAction)
        
        if let titles = item?.product?.belongsToCategory?.isAvailableInShops {
            for title in titles {
                let action = ShopAction(shop: title as! Shop, title: (title as! Shop).name, style: .default, handler: selectAction)
                alert.addAction(action)
            }
        }
        
        self.present(alert, animated: true, completion: nil)
        
        // special code for iPad:
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = [UIPopoverArrowDirection.any]
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
        
        unitPicker.setTitle(combinedUnit(item?.unit), for: .normal)
        shopPicker.setTitle(item?.isAssignedToShop?.name ?? "not set", for: .normal)
        
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
