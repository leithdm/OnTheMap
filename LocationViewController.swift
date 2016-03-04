//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {
	
	//MARK: notifications enum
	
	enum Notifications {
		static let keyboardWillShow = "UIKeyboardWillShowNotification"
		static let keyboardWillHide = "UIKeyboardWillHideNotification"
	}
	
	//MARK: - outlets
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var locationTextField: UITextField!
	var ParseSharedInstance = ParseClient.sharedInstance
	var keyboardUp: Bool = false
	
	//MARK: - lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		locationTextField.delegate = self
		activityIndicator.hidesWhenStopped = true
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		//subscribe to keyboard notifications
		subscribeToKeyboardWillShowNotification()
		subscribeToKeyboardWillHideNotification()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		//unsubscribe to keyboard notifications
		unsubscribeFromKeyboardWillShowNotification()
		unsubscribeFromKeyboardWillHideNotification()
	}
	
	//MARK: - cancelled
	
	@IBAction func didCancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	//MARK: - submitted a location
	
	@IBAction func didSubmitLocation(sender: AnyObject) {
		
		//error validation: textfield is empty
		if locationTextField.text!.isEmpty {
			showAlert("Whoops!", message: "Please enter a location")
			return
		}
		
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(locationTextField.text!) {
			placemark, error in
			if let _ = error {
				self.showAlert("Error", message: "Could not find that location")
				return
			}
			
			self.activityIndicator.startAnimating()
			if let placemark = placemark{
				if placemark.count > 0 {
					let placemark = placemark.first!
					if let country = placemark.country, state = placemark.administrativeArea {
						if let city = placemark.locality {
							self.ParseSharedInstance.currentStudent?.mapString = "\(city), \(state), \(country)"
							self.ParseSharedInstance.currentStudent?.latitude = Float(placemark.location!.coordinate.latitude)
							self.ParseSharedInstance.currentStudent?.longitude = Float(placemark.location!.coordinate.longitude)
							self.presentViewWith(self.ParseSharedInstance.currentStudent?.mapString,lat: self.ParseSharedInstance.currentStudent?.latitude,lon: self.ParseSharedInstance.currentStudent?.longitude)
							self.stopActivityIndicator()
						} else {
							self.ParseSharedInstance.currentStudent?.mapString = "\(state), \(country)"
							self.ParseSharedInstance.currentStudent?.latitude = Float(placemark.location!.coordinate.latitude)
							self.ParseSharedInstance.currentStudent?.longitude = Float(placemark.location!.coordinate.longitude)
							self.presentViewWith(self.ParseSharedInstance.currentStudent?.mapString,lat: nil,lon: nil)
							self.stopActivityIndicator()
						}
					} else {
						self.showAlert("Whoops!", message:"Please choose a more specific location")
					}
				} else {
					self.showAlert("Whoops!", message:"Unable to find that location")
				}
			} else {
				self.showAlert("Whoops!", message: "Unable to find that location")
			}
		}
	}
	
	//MARK: - Helper Methods
	
	func stopActivityIndicator() {
		performUIUpdatesOnMain { () -> Void in
			self.activityIndicator.stopAnimating()
		}
	}
	

	//Shows an alert
	func showAlert(title: String? , message: String?) {
		performUIUpdatesOnMain { () -> Void in
			self.activityIndicator.stopAnimating()
			let errorAlert =
			UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
			errorAlert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(errorAlert, animated: true, completion: nil)
		}
	}
	
	//present LinkViewController
	func presentViewWith(mapString: String?, lat: Float?, lon: Float? ) {
		performUIUpdatesOnMain { () -> Void in
			if mapString != nil {
				self.performSegueWithIdentifier("presentLinkViewController", sender: self)
			}
		}
	}
	
	//MARK: - keyboard movements
	
	func keyboardWillAppear(notification: NSNotification){
		if !keyboardUp {
			view.frame.origin.y -= getKeyboardHeight(notification)
			keyboardUp = true
		}
	}
	
	
	func keyboardWillHide(notification: NSNotification){
		//Move view back into position
		view.frame.origin.y += getKeyboardHeight(notification)
		keyboardUp = false
	}
	
	
	//get half the keyboard height
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue //of CGRect
		return (keyboardSize.CGRectValue().height / 2)
	}
	
	//run on main thread
	func performUIUpdatesOnMain(updates: () -> Void) {
		dispatch_async(dispatch_get_main_queue()) {
			updates()
		}
	}
	
	//subscribe/unsubscribe to keyboard notifications
	
	func subscribeToKeyboardWillShowNotification() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: Notifications.keyboardWillShow, object: nil)
	}
	
	func subscribeToKeyboardWillHideNotification() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: Notifications.keyboardWillHide, object: nil)
	}
	
	func unsubscribeFromKeyboardWillShowNotification() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
	}
	
	func unsubscribeFromKeyboardWillHideNotification() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
}

//MARK: - text field delegate
extension LocationViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if locationTextField.isFirstResponder() && locationTextField.text!.isEmpty == false {
			locationTextField.resignFirstResponder()
		}
		return false
	}
}
