//
//  ListTabTableViewController.swift
//  OnTheMap
//
//  Created by Ahsas Sharma on 27/07/17.
//  Copyright © 2017 Ahsas Sharma. All rights reserved.
//

import UIKit

class ListTabTableViewController: UITableViewController {
    
    var containerViewController: ContainerViewController!
    
    // MARK: - View Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        containerViewController.listTabDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: - TableView Delegate -
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return APIClient.studentLocations.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "studentInformationCell", for: indexPath) as? StudentInformationTableViewCell else {
            debugPrint("Guard failed")
            return StudentInformationTableViewCell()
        }
        
        // set the studentInformation object for the cell
        cell.studentInformation = APIClient.studentLocations[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? StudentInformationTableViewCell
        let app = UIApplication.shared
        if let urlString = cell?.studentInformation.mediaURL {
            guard let url = URL(string:urlString) else {
                return
            }
            app.open(url, options: [:], completionHandler: { (success) in
                // nothing really to do out here
            })
        }
    }
    
}

// MARK: - Extension : ContainerViewDelegate
extension ListTabTableViewController : ContainerViewDelegate {
    func refreshStudentLocations() {
        performUIUpdatesOnMain {
            self.tableView.reloadData()
        }
    }
    
}
