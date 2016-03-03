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
	let udacityClient = UdacityClient()
	let parseClient = ParseClient.sharedInstance
	
	//MARK: - lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpActivityIndicator()
		emailTextField.delegate = self
		passwordTextField.delegate = self
	}
	
	
	//MARK: - login
	
	@IBAction func login(sender: UIButton) {
		//guard against blank username and passwords
		guard let email = emailTextField.text, password = passwordTextField.text where email != "" && password != "" else {
			showAlertViewController("Login Error", message: "Please enter both your email and password")
			return
		}
		
		activityIndicator.startAnimating()
		
		udacityClient.login(email, password: password, completionHandlerForLogin: { (result, error) -> Void in
			guard error == nil && result != nil else {
				self.showAlertViewController("Login error", message: error!)
				return
			}
			//assign the current student value
			self.parseClient.currentStudent = Student(dictionary: result)
			self.getPublicUserData()
			
			self.performUIUpdatesOnMain({ () -> Void in
				self.activityIndicator.stopAnimating()
				self.performSegueWithIdentifier("presentMapView", sender: self)
			})
			
		})
	}
	
	func getPublicUserData() {
		if let key = ParseClient.sharedInstance.currentStudent?.uniqueKey {
			udacityClient.getPublicUserData(key, completionHandler: { (result, error) -> Void in
				
				/* GUARD: Was there any data returned? */
				guard let result = result else {
					print("no data was received")
					return
				}
				
				self.parseClient.currentStudent!.firstName = result["firstName"] as? String
				self.parseClient.currentStudent!.lastName = result["lastName"] as? String
			})
		}
	}
	
	//MARK: - sign up
	
	@IBAction func signUp(sender: UIButton) {
		if let url = NSURL(string: UdacityClient.Methods.signUpURL) {
			let app = UIApplication.sharedApplication()
			if app.canOpenURL(url) {
				app.openURL(url)
			}
		}
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
		activityIndicator.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
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
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if passwordTextField.isFirstResponder() { passwordTextField.resignFirstResponder()}
		if emailTextField.isFirstResponder() { emailTextField.resignFirstResponder()}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField.isFirstResponder() && textField.text!.isEmpty == false{
			textField.resignFirstResponder()
		}
		return false
	}
	
}
