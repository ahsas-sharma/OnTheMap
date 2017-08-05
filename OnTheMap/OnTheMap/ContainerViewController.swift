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
    
    var mapTabVC: MapTabViewController!
    var listTabVC: ListTabTableViewController!
    
    
    let apiClient = APIClient.sharedInstance()
    let studentLocations = StudentLocations.sharedInstance()
    
    weak var listTabDelegate: ContainerViewDelegate?
    weak var mapTabDelegate: ContainerViewDelegate?
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.selectedItem = mapTabBarItem
        loadingView.loadingLabel.text = Constants.Strings.fetchingLocations
        setViewVisibility(view: loadingView, hidden: true)
        loadingView.setBackground(withColor: loadingView.backgroundColor!, alpha: 0.85)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudentLocations()
    }
    
    
    // Adjusts the navigation bar height based on the orientation (as status bar is hidden in landscape mode on phone)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            navigationController?.navigationBar.frame.size.height = 44
        } else {
            navigationController?.navigationBar.frame.size.height = 64
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
                    debugPrint("Still got a token : \(token)")
                } else {
                    performUIUpdatesOnMain {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    @IBAction func presentPostInformationViewController() {
        let postInformationVC = self.storyboard?.instantiateViewController(withIdentifier: "PostInformationViewController") as? PostInformationViewController
        postInformationVC?.containerVC = self
        self.present(postInformationVC!, animated: true, completion: nil)
    }
    
    @IBAction func refreshStudentLocations() {
        self.studentLocations.array.removeAll()
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
                self.studentLocations.array.append(student)
            }
            
            // all UI updates performed on main
            setViewVisibility(view: self.loadingView, hidden: true)
            self.listTabDelegate?.refreshStudentLocations()
            self.mapTabDelegate?.refreshStudentLocations()
            
        })
    }

    // Store references to VC instances when segueing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "mapTabSegue":
            guard let mapTabVC = segue.destination as? MapTabViewController else {
                return
            }
            self.mapTabVC = mapTabVC
            mapTabVC.containerViewController = self
        case "listTabSegue":
            guard let listTabVC = segue.destination as? ListTabTableViewController else {
                return
            }
            self.listTabVC = listTabVC
            listTabVC.containerViewController = self
        default:
            debugPrint("Unknown segue identifier. What's going on here Chief?")
        }
    }
    
}

// MARK: - Extension : UITabBarDelegate -

extension ContainerViewController : UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        toggleViewControllers(selectedTab: item)
    }
    
    func toggleViewControllers(selectedTab: UITabBarItem) {
        if selectedTab == mapTabBarItem {
            mapContainerView.isHidden = false
            listContainerView.isHidden = true
        } else if selectedTab == listTabBarItem {
            mapContainerView.isHidden = true
            listContainerView.isHidden = false
        }
    }
}

// MARK: - Protocol : ContainerViewDelegate -

protocol ContainerViewDelegate : class {
    func refreshStudentLocations()
}
