//
//  ContainerViewController.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 25/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ContainerViewController : UIViewController {
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var listContainerView: UIView!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var mapTabBarItem: UITabBarItem!
    @IBOutlet weak var listTabBarItem: UITabBarItem!
    
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet var loadingViewConstraints: [NSLayoutConstraint]!
    
    
    
    let apiClient = APIClient()
    
    weak var listTabDelegate: ContainerViewDelegate?
    weak var mapTabDelegate: ContainerViewDelegate?
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.selectedItem = mapTabBarItem
        loadingView.loadingLabel.text = Constants.Strings.fetchingLocations
        setViewVisibility(view: loadingView, hidden: true)
        getStudentLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    
    // Adjusts the navigation bar height based on the orientation (as status bar is hidden in landscape mode on phone)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.navigationController?.navigationBar.frame.size.height = 44
        } else {
            self.navigationController?.navigationBar.frame.size.height = 64
        }
    }
    
    
    // MARK: - Actions -
    
    @IBAction func logout() {
        apiClient.deleteSession({
            (success, error) in
            if success {
                let loginManager = self.apiClient.loginManager
                loginManager.logOut()
                if let token = FBSDKAccessToken.current() {
                    print("Still got a token : \(token)")
                } else {
                    performUIUpdatesOnMain {
                        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
                        self.present(loginVC!, animated: true, completion: {
                        })
                    }
                }
            }
        })
    }
    
    @IBAction func presentPostInformationViewController() {
        let postInformationVC = self.storyboard?.instantiateViewController(withIdentifier: "PostInformationViewController")
        self.present(postInformationVC!, animated: true, completion: nil)
    }
    
    @IBAction func refreshStudentLocations() {
        self.getStudentLocations()
    }
    
    // MARK: - Helper -
    
    // wrapper for the getStudentLocations convenience function
    private func getStudentLocations() {
        setViewVisibility(view: loadingView, hidden: false)
        self.apiClient.getStudentLocations({
            (results, error) in
            guard error == nil else {
                presentCustomAlertForError(errorCode: (error! as NSError).code, presentor: self)
                setViewVisibility(view: self.loadingView, hidden: true)
                return
            }
            
            guard let results = results else {
                presentCustomAlertForError(errorCode: 404, presentor: self)
                setViewVisibility(view: self.loadingView, hidden: true)
                return
            }
            
            for location in results {
                guard let student = StudentInformation(dict: location) else {
                    debugPrint("StudentInformation initializer failed for location:\(location)")
                    continue
                }
                APIClient.studentLocations.append(student)
            }
            
            // all UI updates performed on main
            setViewVisibility(view: self.loadingView, hidden: true)
            self.listTabDelegate?.refreshStudentLocations()
            self.mapTabDelegate?.refreshStudentLocations()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "mapTabSegue":
            guard let mapTabVC = segue.destination as? MapTabViewController else {
                return
            }
            mapTabVC.containerViewController = self
        case "listTabSegue":
            guard let listTabVC = segue.destination as? ListTabTableViewController else {
                return
            }
            listTabVC.containerViewController = self
        default:
            debugPrint("Unknown segue identifier. What's going on here Chief?")
        }
    }
    
    /*
        // Figure out the math of this
     
        private func makeCircularView(_ view: UIView) {
            let frame = view.frame
            print("Frame: \(String(describing:frame))")
            let centerPoint = view.center
    
            let width = Double(frame.width)
            let height = Double(frame.height)
            let diagonal = sqrt((width * width) + (height  * height))
            print("Diagonal: \(diagonal)")
    
            let newX = Double(frame.minX) - (diagonal/2)
            print("New X : \(newX)")
            let newY = Double(frame.minY) - (diagonal/2)
            print("New Y : \(newY)")
            let squareFrame = CGRect(x: newX, y: newY, width: diagonal, height: diagonal)
            print("Square Frame: \(squareFrame)")
            view.removeConstraints(loadingViewConstraints)
            view.frame = squareFrame
            view.layer.cornerRadius = min(view.frame.height, view.frame.width) / 2.0
            print("Corner Radius: \(view.layer.cornerRadius)")
            view.center = centerPoint
            view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
     */
    
}

// MARK: - Extension : UITabBarDelegate -

extension ContainerViewController : UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        toggleViewControllers(selectedTab: item)
    }
    
    func toggleViewControllers(selectedTab: UITabBarItem) {
        swap(&self.listContainerView.alpha, &self.mapContainerView.alpha)
    }
}

// MARK: - Protocol : ContainerViewDelegate -

protocol ContainerViewDelegate : class {
    func refreshStudentLocations()
}
