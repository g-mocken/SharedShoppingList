//
//  ProductDetailViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 21.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit
import CoreData

protocol ProductDetailViewControllerDelegate: AnyObject {

}

class FixedUnitTableViewCell: UITableViewCell{
    
    @IBOutlet var unitLabel: UILabel!
}
class ProductDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet var tableView: UITableView!
    

    @IBOutlet var name: UITextField!
    var product:Product?
    weak var delegate:ProductDetailViewControllerDelegate?
    
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Unit>!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        initializeFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.setEditing(true, animated: true)

        name.text = product?.name
    }
    

    fileprivate func initializeFetchedResultsController() {
        
        let fetchRequest = NSFetchRequest<Unit>(entityName: "Unit")
        // Configure the request's entity, and optionally its predicate
        
        fetchRequest.predicate = NSPredicate(format: "isUnitOfProduct CONTAINS %@", product!)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath:  nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Available units:", comment:"")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections
        let sectionInfo = sections![section]
        print ("#units = \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects+1 // one extra for inserting new at the end
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "unitCell", for: indexPath) as! FixedUnitTableViewCell

        if (indexPath.row < tableView.numberOfRows(inSection: indexPath.section)-1){
            let unit = fetchedResultsController.object(at: indexPath)
            cell.unitLabel.text = combinedUnit(unit)
        } else {
            cell.unitLabel.text = NSLocalizedString("More …", comment: "")
        }
        return cell
    }
    
    
    
    func unitPickerAction(_ sender: UITableViewCell) {
           let alert = UIAlertController(title: NSLocalizedString("Select unit size", comment: ""), message: NSLocalizedString("This list can be edited in the units tabs.", comment: ""), preferredStyle: .actionSheet)
           
           //  sub class alert action to be able to pass on the unit property
           class UnitAction:UIAlertAction{
               var unit: Unit?
               convenience init(unit: Unit, title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil){
                   self.init(title: title, style: style, handler: handler) // call standard designated initializer
                   self.unit = unit // assign extra property
               }
           }
           
           
        let fetchRequest = NSFetchRequest<Unit>(entityName: "Unit")
        let units = try? managedContext.fetch(fetchRequest)

        for u in units ?? [] {
            print("\(u.number) \(u.name!)")
        }
        
        let selectAction: (UIAlertAction)->(Void) = { (action) in
            print (action.title!)
            // assign selected unit to item
            self.product!.addToHasUnits(((action as! UnitAction).unit!))
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel) { _ in  }
        
        alert.addAction(cancelAction)
        if let titles = units {
            for title in titles {
                let action = UnitAction(unit: title, title: combinedUnit((title)), style: .default, handler: selectAction)
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
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let unitToDelete = fetchedResultsController.object(at: indexPath)
            managedContext.delete(unitToDelete)
            appDelegate.saveContext()
            
        } else if editingStyle == .insert {
 
            
            unitPickerAction(tableView.cellForRow(at: indexPath)!)
            
            
            
            
            appDelegate.saveContext()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
            return .insert;
        } else {
            return .delete;
        }
    }
    

    var pathsToUpdate:[IndexPath]?
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        pathsToUpdate = Array()
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
            pathsToUpdate?.append(newIndexPath!) // save destination index path for deferred update
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        // perform deferred update
        if let indexPaths = pathsToUpdate {
            tableView.reloadRows(at: indexPaths, with: .fade)
        }
        pathsToUpdate=nil
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
