//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func login(sender: UIButton) {
		
		if let emailTextField = emailTextField.text, passwordTextField = passwordTextField.text {
		
		UdacityClient.sharedInstance.getRequest(emailTextField, password: passwordTextField)
		
		}
	}

}
