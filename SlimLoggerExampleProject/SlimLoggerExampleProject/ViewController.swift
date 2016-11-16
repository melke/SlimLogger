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
        Slim.debug("Debug in viewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createLogentryButtonTapped(_ sender: AnyObject) {
        Slim.debug("Debug log message")
        Slim.info("Info log message")
        Slim.info(["Dictionary key": "Date: \(Date())","Another key":"Forza Bajen"])
    }

    @IBAction func traceLevelButtonTapped(_ sender: AnyObject) {
        SlimConfig.consoleLogLevel = LogLevel.trace
    }
    @IBAction func infoLevelButtonTapped(_ sender: AnyObject) {
        SlimConfig.consoleLogLevel = LogLevel.info
    }
}

