//
//  MainPageViewControllre.swift
//  kiwiApp
//
//  Created by Tom Odler on 07.06.18.
//  Copyright © 2018 Tom Odler. All rights reserved.
//

import UIKit
import CoreData

class MainPageViewControllre: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var currentIndex : Int = 0
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex == 0 {
            return nil
        }
        
        let pendingIndex = currentIndex - 1
        return self.viewControllerForIndex(index: pendingIndex)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if(currentIndex == 4) {
            return nil
        }
        let pendingIndex = currentIndex + 1
        return self.viewControllerForIndex(index: pendingIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let controller = pageViewController.viewControllers?.last as! SubViewController
            currentIndex = controller.index
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        let startingController = self.viewControllerForIndex(index: 0)
        if let controller = startingController {
            self.setViewControllers([controller], direction: .forward, animated: false) { (completion) in
                
            }
        }
    }

    private func viewControllerForIndex(index : Int ) -> UIViewController? {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "subVC") as? SubViewController
        if let controller = viewController {
            controller.index = index
            return viewController
        }
       return UIViewController()
    }
}
