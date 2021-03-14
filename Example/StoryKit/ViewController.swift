//
//  ViewController.swift
//  StoryKit
//
//  Created by 2jeje on 03/14/2021.
//  Copyright (c) 2021 2jeje. All rights reserved.
//

import UIKit
import StoryKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let v = EditableView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        view.addSubview(v)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

