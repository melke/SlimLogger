//
//  ViewController.swift
//  SlimLoggerExampleProject
//
//  Created by Mats Melke on 05/06/15.
//  Copyright (c) 2015 Baresi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(sender: AnyObject) {
        Slim.info("Simple string message \(NSDate())")
        Slim.info(["Dictionary key": "Date: \(NSDate())","Another key":"Forza Bajen"])
    }

}

