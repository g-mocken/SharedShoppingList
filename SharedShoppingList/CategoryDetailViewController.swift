//
//  CategoryDetailViewController.swift
//  SharedShoppingList
//
//  Created by Dr. Guido Mocken on 22.02.20.
//  Copyright © 2020 Guido R. Mocken. All rights reserved.
//

import UIKit


protocol CategoryDetailViewControllerDelegate: AnyObject {

}

class CategoryDetailViewController: UIViewController {
    @IBOutlet var name: UITextField!
    
    var category:ProductCategory?
    
    weak var delegate:CategoryDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        name.text = category?.name
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
