//
//  HowToPageViewController.swift
//  Lists
//
//  Created by Shahar Melamed on 04/05/2019.
//  Copyright © 2019 Shahar Melamed. All rights reserved.
//

import UIKit

class HowToPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    fileprivate lazy var pages: [UIViewController] = {
        return [self.getViewController(withIdentifier: "page1"),
                self.getViewController(withIdentifier: "page2"),
                self.getViewController(withIdentifier: "page3"),
                self.getViewController(withIdentifier: "page4")]
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        dataSource = self
        
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        navigationItem.title = NSLocalizedString("how", comment: "how")
        
        configurePageControl()
    }
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.alpha = 0.5
        pageControl.tintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        view.addSubview(pageControl)
        pageControl.currentPage = 0
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        pageControl.currentPage = pages.firstIndex(of: pageContentViewController)!
    }

    //MARK: - UIPageViewController data source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        let prev = index - 1
        guard prev >= 0 && prev < pages.count else { return nil }
        
        return pages[prev]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        let next = index + 1
        guard next < pages.count else { return nil }
        
        return pages[next]
    }
}
