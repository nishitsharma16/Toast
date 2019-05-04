//
//  ViewController.swift
//  ToastExample
//
//  Created by Nishit Sharma on 04/05/19.
//  Copyright © 2019 None. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func showToast(_ sender: Any) {
        Toast.shared().showToastMessage("This is my message.")
    }
    
}

