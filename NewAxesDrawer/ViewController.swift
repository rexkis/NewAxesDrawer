//
//  ViewController.swift
//  NewAxesDrawer
//
//  Created by Igor Kutovoy on 18.11.2019.
//  Copyright © 2019 Igor Kutovoy. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var seg: NSSegmentedControl!
    @IBAction func segTapped(_ sender: NSSegmentedControl) {
        let selected = sender.indexOfSelectedItem
        print(selected)
        graphView.lineTip = selected
    }
    

    @IBOutlet weak var graphView: GraphView!
    
    override func viewWillAppear() {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
          
    }

}

