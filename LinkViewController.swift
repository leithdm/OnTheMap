//
//  LinkViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import MapKit

class LinkViewController: UIViewController {
	
	//MARK: - outlets
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var linkTextField: UITextField!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	//MARK: - properties
	
	var currentStudent: StudentInformation?
	var ParseSharedInstance = ParseClient.sharedInstance
	
	//MARK: - lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		linkTextField.delegate = self
		currentStudent = ParseClient.sharedInstance.currentStudent
		activityIndicator.hidesWhenStopped = true
		setUpActivityIndicator()
		addAnnotationsToMap()
	}
	
	
	//MARK: - add annotations to the map
	
	func addAnnotationsToMap() {
		performUIUpdatesOnMain { () -> Void in
			if let student = self.currentStudent, lon = student.longitude, lat = student.latitude {
				let lat = CLLocationDegrees(Double((lat)))
				let long = CLLocationDegrees(Double((lon)))
				let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
				let annotation = MKPointAnnotation()
				annotation.coordinate = coordinate
				self.mapView.addAnnotation(annotation)
				let camera = MKMapCamera(lookingAtCenterCoordinate: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 10000.0)
				self.mapView.setCamera(camera, animated: true)
			} else {
				//cant get a reference to the student
				self.showAlert("Oops.!", message: "Unable to parse student data")
			}
		}
	}
	
	//MARK: - submit location and URL
	
	@IBAction func submitLocation(sender: AnyObject) {
		self.activityIndicator.startAnimating()
		if let urlString = linkTextField.text {
			if confirmURL(urlString) {
				ParseSharedInstance.currentStudent?.mediaURL = "\(urlString)"
				if let overwrite = ParseSharedInstance.studentAlreadyPosted { //has the student already posted
					if overwrite {
						self.overwriteLocation()
					} else if overwrite == false {
						self.submitNewLocation()
					}
				}
			} else {
				self.showAlert("Oops..!", message:"Thats not a valid https link")
			}
		} else {
			self.showAlert("Whoops!", message:"Please enter a link")
		}
	}
	
	//MARK: - submit a new location
	
	func submitNewLocation() {
		activityIndicator.startAnimating()
		ParseSharedInstance.postStudentLocation(ParseSharedInstance.currentStudent) { (completed, errorString) in
			if completed == true {
				self.activityIndicator.stopAnimating()
				self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
			} else {
				if let errorString = errorString {
					self.showAlert("Error", message: errorString)
				}else {
					self.showAlert("Error", message:"Unable to sumbit the location")
				}
			}
		}
	}
	
	//MARK: - overwrite location
	
	func overwriteLocation() {
		ParseSharedInstance.overwriteStudent(ParseSharedInstance.currentStudent) { (completed, errorString) in
			if completed == true {
				self.activityIndicator.stopAnimating()
				self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
			} else {
				if let errorString = errorString {
					self.showAlert("Error", message: errorString)
				}else {
					self.showAlert("Error", message:"Unable to sumbit student data")
				}
			}
		}
	}

	
	//MARK: - cancel 
	
	@IBAction func cancelButtonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	//MARK: - helper methods
	
	//verify that the URL is of the correct syntax
	func confirmURL(urlString: String?) ->Bool {
		if let urlString = urlString {
			let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
			if let _ = urlString.rangeOfString(pattern, options: .RegularExpressionSearch){
				if let url = NSURL(string: urlString) {
					if UIApplication.sharedApplication().canOpenURL(url) {
						return true
					}
				}
			}
		}
		return false
	}
	
	//show an alert controller
	func showAlert(title: String? , message: String?) {
		performUIUpdatesOnMain { () -> Void in
			self.activityIndicator.stopAnimating()
			if title != nil && message != nil {
				let errorAlert =
				UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
				errorAlert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
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
	
	//initialize the activity indicator
	func setUpActivityIndicator() {
		activityIndicator.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = .WhiteLarge
	}
	
}
//MARK: - Textfield delegate

extension LinkViewController: UITextFieldDelegate {
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if linkTextField.isFirstResponder() {
			linkTextField.resignFirstResponder()
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if linkTextField.isFirstResponder() && linkTextField.text!.isEmpty == false {
			linkTextField.resignFirstResponder()
		}
		return false
	}
}

// MARK: - MKMapViewDelegate

extension LinkViewController: MKMapViewDelegate {
	
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let reuseId = "pin"
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.pinTintColor = UIColor.redColor()
		}
		else { pinView!.annotation = annotation }
		
		return pinView
	}
}
