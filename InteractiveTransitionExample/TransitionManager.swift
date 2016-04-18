//
//  TransitionManager.swift
//  InteractiveTransitionExample
//
//  Created by David on 2016/4/18.
//  Copyright © 2016年 David. All rights reserved.
//

import Foundation
import UIKit

class TransitionManager: UIPercentDrivenInteractiveTransition {
	var isPresenting: Bool = false
	var isInteractive: Bool = false
	
	var mainPanGesture: UIPanGestureRecognizer!
	var mainViewController: MainViewController! {
		didSet {
			mainPanGesture = UIPanGestureRecognizer()
			mainPanGesture.addTarget(self, action: #selector(handleMainPanGesture))
			mainViewController.view.addGestureRecognizer(mainPanGesture)
		}
	}
	
	func handleMainPanGesture(gesture: UIPanGestureRecognizer) {
		
		let translation = gesture.translationInView(gesture.view!)
		
		let progress: CGFloat = translation.x / 350.0
		
		switch gesture.state {
		case .Began:
			isInteractive = true
			mainViewController.performSegueWithIdentifier("segue", sender: nil)
		case .Changed:
			updateInteractiveTransition(progress)
		default:
			isInteractive = false
			if progress >= 0.5 {
				finishInteractiveTransition()
			} else {
				cancelInteractiveTransition()
			}
		}
	}
	
	var menuPanGesture: UIPanGestureRecognizer!
	var menuViewController: MenuViewController! {
		didSet {
			menuPanGesture = UIPanGestureRecognizer()
			menuPanGesture.addTarget(self, action: #selector(handleMenuPanGesture))
			menuViewController.view.addGestureRecognizer(menuPanGesture)
		}
	}
	
	func handleMenuPanGesture(gesture: UIPanGestureRecognizer) {
		
		let translation = gesture.translationInView(gesture.view!)
		
		let progress: CGFloat = -translation.x / 350.0
		
		switch gesture.state {
		case .Began:
			isInteractive = true
			menuViewController.dismissViewControllerAnimated(true, completion: nil)
		case .Changed:
			updateInteractiveTransition(progress)
		default:
			isInteractive = false
			if progress >= 0.5 {
				finishInteractiveTransition()
			} else {
				cancelInteractiveTransition()
			}
		}
	}
	
	func offStage(amount: CGFloat) -> CGAffineTransform {
		return CGAffineTransformMakeTranslation(amount, 0)
	}
	
	func offStageMenuViewControllerTransition(menuVC: MenuViewController) {
		menuVC.view.alpha = 0.0
		menuVC.view.transform = CGAffineTransformScale(offStage(-50), 0.9, 0.9)
	}
	
	func onStageMenuViewControllerTransition(menuVC: MenuViewController) {
		menuVC.view.alpha = 1.0
		menuVC.view.transform = CGAffineTransformIdentity
	}
}

extension TransitionManager : UIViewControllerAnimatedTransitioning {
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.5
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		
		let container = transitionContext.containerView()!
		
		let screen: (from: UIViewController, to: UIViewController) = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!, transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
		
		let menuVC = !isPresenting ? screen.from as! MenuViewController : screen.to as! MenuViewController
		let mainVC = !isPresenting ? screen.to as! MainViewController : screen.from as! MainViewController
		
		let mainVCSnapshot = mainVC.view.resizableSnapshotViewFromRect(mainVC.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
		let menuVCSnapshot = menuVC.view.resizableSnapshotViewFromRect(menuVC.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
		
		container.addSubview(menuVC.view)
		container.addSubview(mainVC.view)
		
		let duration = transitionDuration(transitionContext)
		
		if isPresenting {
			offStageMenuViewControllerTransition(menuVC)
		}
		
		UIView.animateWithDuration(duration, animations: { 
			if self.isPresenting {
				mainVC.view.transform = self.offStage(350)
				self.onStageMenuViewControllerTransition(menuVC)
			} else {
				mainVC.view.transform = CGAffineTransformIdentity
				self.offStageMenuViewControllerTransition(menuVC)
			}
			}) { (finished) in
				
				if transitionContext.transitionWasCancelled() {
					transitionContext.completeTransition(false)
					UIApplication.sharedApplication().keyWindow?.addSubview(screen.from.view)
				} else {
					transitionContext.completeTransition(true)
					UIApplication.sharedApplication().keyWindow?.addSubview(screen.to.view)
					if self.isPresenting {
						mainVCSnapshot.transform = self.offStage(350)
						screen.to.view.addSubview(mainVCSnapshot)
					}
				}
		}
	}
}

extension TransitionManager : UIViewControllerTransitioningDelegate {
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		isPresenting = true
		return self
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		isPresenting = false
		return self
	}
	
	func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return isInteractive ? self : nil
	}
	
	func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return isInteractive ? self : nil
	}
}