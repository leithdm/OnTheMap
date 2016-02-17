//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
	
	var students: [Student]?
	var sharedSession: ParseClient?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sharedSession = ParseClient.sharedInstance
		students = sharedSession?.students
	}
	
	@IBAction func reloadData(sender: UIBarButtonItem) {
		tableView.reloadData()
	}
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let count = students?.count {
			return count
		} else {
			return 0
		}
	}
	
	//cell for row at index path
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		if let students = students {
			let student = students[indexPath.row]
			if let firstName = student.firstName, lastName = student.lastName, mapString = student.mapString, mediaURL = student.mediaURL {
				cell.textLabel!.text = "\(firstName) \(lastName)"
				cell.detailTextLabel!.text = "\(mapString) | \(mediaURL)"
				cell.imageView?.image = UIImage(named: "user")
			}
		}
		return cell
	}
	
	//did select row
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
	
	//show an AlertViewController
	func showAlertViewController(title: String? , message: String?) {
		
		performUIUpdatesOnMain {
			//self.activityIndicator.stopAnimating()
			if title != nil && message != nil {
				let errorAlert =
				UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
				errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(errorAlert, animated: true, completion: nil)
			}
		}
	}
	
	//run on main thread
	func performUIUpdatesOnMain(updates: () -> Void) {
		dispatch_async(dispatch_get_main_queue()) {
			updates()
		}
	}
	
}

