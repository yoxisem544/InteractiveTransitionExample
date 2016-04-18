//
//  MainViewController.swift
//  InteractiveTransitionExample
//
//  Created by David on 2016/4/18.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
	
	let manager = TransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		manager.mainViewController = self
    }

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let vc = segue.destinationViewController as! MenuViewController
		vc.transitioningDelegate = manager
		manager.menuViewController = vc
	}
}
