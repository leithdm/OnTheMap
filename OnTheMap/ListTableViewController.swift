//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ParseClient.sharedInstance.students!.count
	}
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		
		let student = ParseClient.sharedInstance.students![indexPath.row]
		cell.textLabel!.text = "\(student.firstName!) \(student.lastName!)"
		cell.detailTextLabel!.text = "\(student.mapString!) | \(student.mediaURL!)"
		cell.imageView?.image = UIImage(named: "user")
		
		return cell
	}
	
}

