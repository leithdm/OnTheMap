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
	var currentStudent: Student?
	var ParseSharedInstance = ParseClient.sharedInstance
	
	//MARK: - lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		linkTextField.delegate = self
		currentStudent = ParseClient.sharedInstance.currentStudent
		activityIndicator.hidesWhenStopped = true
		addAnnotationsToMap()
		
		print(currentStudent)
	}
	
	
	//MARK: - add annotations to the map
	func addAnnotationsToMap() {
		print("here")
		dispatch_async(dispatch_get_main_queue()){
			if let student = self.currentStudent, lon = student.longitude, lat = student.latitude{
				let lat = CLLocationDegrees(Double((lat)))
				let long = CLLocationDegrees(Double((lon)))
				let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
				let annotation = MKPointAnnotation()
				annotation.coordinate = coordinate
				self.mapView.addAnnotation(annotation)
				let cammera = MKMapCamera(lookingAtCenterCoordinate: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 10000.0)
				self.mapView.setCamera(cammera, animated: true)
			} else {
				self.showAlert("Error", message: "Unable to parse student data")
			}
		}
	}
	
	//MARK: - submit location and URL
	
	@IBAction func submitButtonPressed(sender: AnyObject) {
		self.activityIndicator.startAnimating()
		if let urlString = linkTextField.text{
			if verifyUrl(urlString){
				ParseClient.sharedInstance.mediaURL = "\(urlString)"
				if let overwrite = ParseClient.sharedInstance.studentAlreadyPosted {
					if overwrite {
						//OVERWRITE
//						self.overwriteLocationObject()
					} else if overwrite == false{
						//ADD NEW LOCATION OBJECT
						self.addLocationObject()
					}
				}
			} else { self.showAlert("Error", message:"Invalid link") }
		} else { self.showAlert("Error", message:"TextField is empty") }
	}
	
	
	/*
	func overwriteLocationObject(){
		ParseSharedInstance.overwriteStudent(ParseSharedInstance.currentStudent) {
			(completed, errorString) in
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
*/
	
	func addLocationObject(){
		ParseSharedInstance.postStudentLocation(ParseSharedInstance.currentStudent) {
			(completed, errorString) in
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
	
	
	@IBAction func cancelButtonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	//MARK: - Helper Methods
	
	//verify that the URL is of the correct syntax
	func verifyUrl(urlString: String?) ->Bool {
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
		dispatch_async(dispatch_get_main_queue()){
			self.activityIndicator.stopAnimating()
			if title != nil && message != nil {
				let errorAlert =
				UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
				errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(errorAlert, animated: true, completion: nil)
			}
		}
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
		if linkTextField.isFirstResponder() && linkTextField.text!.isEmpty == false{
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
