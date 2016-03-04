//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class ListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	//MARK: - outlets
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var viewForActivityIndicator: UIView!
	
	//MARK: - properties
	
	var arrayStudents: [StudentInformation]?
	var sharedSession: ParseClient?
	var uniqueKey: String?
	
	//MARK: - lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sharedSession = ParseClient.sharedInstance
		arrayStudents = sharedSession?.students
		setUpActivityIndicator()
		uniqueKey = ParseClient.sharedInstance.currentStudent?.uniqueKey
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		getStudentsFromServer()
	}
	
	
	// MARK: - Table view data source
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let count = arrayStudents?.count {
			return count
		} else {
			return 0
		}
	}
	
	//cell for row at index path
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		if let students = arrayStudents {
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
		if let students = arrayStudents {
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
	
	//MARK: - reload data using bar button
	
	@IBAction func reloadData(sender: UIBarButtonItem) {
		getStudentsFromServer()
	}
	
	//MARK: - reload student data from server
	
	func getStudentsFromServer() {
		
		setActivityViewHidden(false)
		activityIndicator.startAnimating()
		
		if let sharedSession = sharedSession {
			sharedSession.getStudentLocations { (result, error) -> Void in
				
				guard error == nil else {
					self.showAlertViewController("Oops!", message: "There was an error connecting to the internet")
					self.setActivityViewHidden(true)
					return
				}
				
				if let students = result as? [[String: AnyObject]] {
					self.arrayStudents?.removeAll(keepCapacity: true)
					for studentData in students {
						self.arrayStudents?.append(StudentInformation(dictionary: studentData))
					}
					
					if self.arrayStudents?.count > 0 {
						self.performUIUpdatesOnMain({ () -> Void in
							self.activityIndicator.stopAnimating()
							self.setActivityViewHidden(true)
							self.tableView.reloadData()
						})
					}
				}
			}
		}
	}
	
	//MARK: - logout
	
	@IBAction func logout(sender: AnyObject) {
		let logoutController = presentingViewController as? LoginViewController
		logoutController?.passwordTextField.text = ""
		ParseClient.sharedInstance.students = nil
		ParseClient.sharedInstance.currentStudent = nil
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil )
	}
	
	
	//MARK: - add a pin to the map
	
	@IBAction func addPinPressed(sender: AnyObject) {
		let parseClient = ParseClient.sharedInstance
		parseClient.queryForStudent(uniqueKey!) { student, errorString in
			if let student = student {
				parseClient.onTheMap = true
				parseClient.currentStudent = student
			} else {
				parseClient.onTheMap = false
			}
			if student == nil {
				let storyboard = UIStoryboard(name: "Main", bundle: nil)
				let locationViewController = storyboard.instantiateViewControllerWithIdentifier("LocationViewController") as? LocationViewController
				self.presentViewController(locationViewController!, animated: true, completion: nil)
			} else {
				self.showOverwriteMessage("Hi \(student!.firstName!). You have already posted a student location. Would you like to overwrite this location?", student: student)
			}
		}
	}
	
	//over write message
	func showOverwriteMessage( message: String?, student: StudentInformation?) {
		performUIUpdatesOnMain { () -> Void in
			self.activityIndicator.stopAnimating()
			let alert =
			UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: { alert -> Void in
				let storyboard = UIStoryboard(name: "Main", bundle: nil)
				let locationViewController = storyboard.instantiateViewControllerWithIdentifier("LocationViewController") as? LocationViewController
				self.presentViewController(locationViewController!, animated: true, completion: nil)
			}))
			alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	//MARK: - helper methods
	
	//show an alert view
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
	
	//hide the activity indicator
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

