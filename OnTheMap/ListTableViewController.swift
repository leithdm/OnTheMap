//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class ListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var tableView: UITableView!
	
	//MARK: - outlets
	
	@IBAction func reloadData(sender: UIBarButtonItem) {
		getStudentsFromServer()
	}
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var viewForActivityIndicator: UIView!
	
	//MARK: - properties
	
	var students: [Student]?
	var sharedSession: ParseClient?
	
	//MARK: - lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		sharedSession = ParseClient.sharedInstance
		students = sharedSession?.students
		setUpActivityIndicator()
		
	}
	
	// MARK: - Table view data source
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let count = students?.count {
			return count
		} else {
			return 0
		}
	}
	
	//cell for row at index path
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		if let students = students {
			let student = students[indexPath.row]
			if let firstName = student.firstName, lastName = student.lastName, mapString = student.mapString, mediaURL = student.mediaURL {
				cell.textLabel!.text = "\(firstName) \(lastName)"
				cell.detailTextLabel!.text = "\(mapString) | \(mediaURL)"
				cell.imageView?.image = UIImage(named: "user")
			}
		}
		activityIndicator.stopAnimating()
		return cell
	}
	
	//did select row
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let students = students {
			if let URL = students[indexPath.row].mediaURL {
				let app = UIApplication.sharedApplication()
				if let url = NSURL(string: URL) {
					if app.canOpenURL(url) {
						app.openURL(url)
					} else {
						showAlertViewController("Whoops!", message: "Looks like this student put in an incorrect URL")
					}
				}
			}
		}
	}
	
	//MARK: - reload student data from server
	
	func getStudentsFromServer() {
		setActivityViewHidden(false)
		activityIndicator.startAnimating()
		
		if let sharedSession = sharedSession {
			sharedSession.getStudentLocations { (result, error) -> Void in
				
				if let students = result as? [[String: AnyObject]] {
					var studentArray = [Student]()
					for studentData in students {
						studentArray.append(Student(dictionary: studentData))
					}
					
					if studentArray.count > 0 {
						dispatch_async(dispatch_get_main_queue()) {
							self.activityIndicator.stopAnimating()
							self.setActivityViewHidden(true)
							self.tableView.reloadData()
						}
					}
				} else {
					dispatch_async(dispatch_get_main_queue()) {
						self.activityIndicator.stopAnimating()
						self.setActivityViewHidden(true)
					}
					if let errorString = error {
						print(errorString.localizedDescription)
						self.showAlertViewController("Oops!", message: "There was an error connecting to the internet")
					} else {
						self.showAlertViewController("Error", message: "Unable to retrieve data")
					}
					self.setActivityViewHidden(true)
				}
			}
		}
	}
	
	//show an AlertViewController
	func showAlertViewController(title: String? , message: String?) {
		performUIUpdatesOnMain {
			self.activityIndicator.stopAnimating()
			if title != nil && message != nil {
				let errorAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
				errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(errorAlert, animated: true, completion: nil)
			}
		}
	}
	
	func setActivityViewHidden(isHidden: Bool) {
		viewForActivityIndicator.hidden = isHidden
	}
	
	
	//initialize the activity indicator
	func setUpActivityIndicator() {
		setActivityViewHidden(true)
		activityIndicator.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = .WhiteLarge
	}
	
	//run on main thread
	func performUIUpdatesOnMain(updates: () -> Void) {
		dispatch_async(dispatch_get_main_queue()) {
			updates()
		}
	}
}

