//
//  ViewController.swift
//  LoopingPictures
//
//  Created by Sherlock on 2019/5/14.
//  Copyright © 2019 daHuiGe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
        
        let ges = UITapGestureRecognizer.init(target: self, action: #selector(gotoNext))
        self.view.addGestureRecognizer(ges)
        
    }
    
    @objc func gotoNext() {
        let vc = NextViewController.init()
        self.present(vc, animated: true, completion: nil)
    }
}



