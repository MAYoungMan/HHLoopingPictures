//
//  NextViewController.swift
//  LoopingPictures
//
//  Created by Sherlock on 2019/5/15.
//  Copyright © 2019 daHuiGe. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {

    var picLoop: HHLoopingPictures?
    let width = UIScreen.main.bounds.width
    let height = floor(UIScreen.main.bounds.width * 333 / 500)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        picLoop = HHLoopingPictures.init(superView: self.view, frame: CGRect.init(x: 0, y: 100, width: width, height: height), time: 1.0, images: [#imageLiteral(resourceName: "1"),#imageLiteral(resourceName: "2"),#imageLiteral(resourceName: "3"),#imageLiteral(resourceName: "4"),#imageLiteral(resourceName: "5")])
        picLoop?.delegate = self
        
        let gesLong = UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(ges:)))
        self.view.addGestureRecognizer(gesLong)
        
        let ges = UITapGestureRecognizer.init(target: self, action: #selector(back))
        ges.delegate = self
        self.view.addGestureRecognizer(ges)
    }
    
    @objc func back() {
        picLoop?.removeTimer()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func longPress(ges: UILongPressGestureRecognizer) {
        if ges.state == .ended {
            picLoop?.resizeViewFrame(frame: CGRect.init(x: 0, y: (UIScreen.main.bounds.height-height)/2, width: width, height: height))
        }
    }
    
    deinit {
        print("NextViewController deinit")
    }
}
extension NextViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != self.view {
            return false
        }else{
            return true
        }
    }
}

extension NextViewController: PicturesClickDelegate {
    func clickAtIndex(index: Int) {
        print(index)
    }
}
