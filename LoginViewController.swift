//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	
	//MARK: - outlets
	
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	
	//MARK: - properties
	var activityIndicator = UIActivityIndicatorView()
	
	//MARK: - lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpActivityIndicator()
		emailTextField.delegate = self
		passwordTextField.delegate = self
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	//MARK: - login
	
	@IBAction func login(sender: UIButton) {
		
		activityIndicator.startAnimating()
		
		//validate against blank email and password fields
		guard (emailTextField.text != "") && (passwordTextField.text != "") else {
			showAlertViewController("Oops..!", message: "Please enter your email and password")
			return
		}
		
		if let email = emailTextField.text, password = passwordTextField.text {
			//call the login method
			UdacityClient.sharedInstance.login(email, password: password, completionHandlerForLogin: { (result, error) -> Void in
				
				guard result != nil else {
					self.showAlertViewController("Login error", message: error!)
					return
				}
				self.segueToMapView()
			})
		} else {
			showAlertViewController("Invalid login", message: "Please enter a valid username and password")
		}
	}
	
	//MARK: - segue to the mapView nav controller
	func segueToMapView() {
		let mapNavController = self.storyboard!.instantiateViewControllerWithIdentifier("mapNavController") as! UITabBarController
		presentViewController(mapNavController, animated: true, completion: nil)
	}
	
	//MARK: - helper methods
	
	//show an AlertViewController
	func showAlertViewController(title: String? , message: String?) {
		performUIUpdatesOnMain {
			self.stopActivityIndicator()
			if title != nil && message != nil {
				let errorAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
				errorAlert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(errorAlert, animated: true, completion: nil)
			}
		}
	}
	
	//initialize the activity indicator
	func setUpActivityIndicator() {
		activityIndicator.frame = CGRect(x: 0, y: -50, width: self.view.frame.width, height: self.view.frame.height)
		view.addSubview(activityIndicator)
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
	
	//run stopAnimating activity indicator on main thread
	func stopActivityIndicator() {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			self.activityIndicator.stopAnimating()
		}
	}
}

//MARK: - Text Field Delegate
extension LoginViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
}
