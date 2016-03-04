//
//  ViewController.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
	
	//MARK: - outlets
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var reload: UIBarButtonItem!
	
	//MARK: - properties
	var annotations = [MKPointAnnotation]()
	var activityIndicator = UIActivityIndicatorView()
	var uniqueKey: String?
	
	
	//MARK: - lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		setUpActivityIndicator()
		getStudentsFromServer()
		uniqueKey = ParseClient.sharedInstance.currentStudent?.uniqueKey
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	//MARK: - get students from server
	
	func getStudentsFromServer() {
		activityIndicator.startAnimating()
		ParseClient.sharedInstance.getStudentLocations { (result, error) -> Void in
			if let students = result as? [[String: AnyObject]] {
				var studentArray = [StudentInformation]()
				for studentData in students {
					studentArray.append(StudentInformation(dictionary: studentData))
				}
				if studentArray.count > 0 {
					dispatch_async(dispatch_get_main_queue()) {
						ParseClient.sharedInstance.students = studentArray
						if self.mapView.annotations.count > 0 {
							self.mapView.removeAnnotations(self.mapView.annotations)
							self.addAnnotationsToMap()
						} else {
							self.addAnnotationsToMap()
						}
					}
					self.stopActivityIndicator()
				}
			} else {
				dispatch_async(dispatch_get_main_queue()) {
					self.stopActivityIndicator()
				}
				if let errorString = error {
					print(errorString.localizedDescription)
					self.showAlertViewController("Oops!", message: "There was an error connecting to the internet")
				} else {
					self.showAlertViewController("Error", message: "Unable to retrieve data")
				}
			}
		}
	}
	
	//MARK: - add annotations to the map
	
	func addAnnotationsToMap() {
		
		performUIUpdatesOnMain {
			if let students = ParseClient.sharedInstance.students {
				var annotations = [MKAnnotation]()
				for student in students {
					if let lon = student.longitude,
						lat = student.latitude,
						first = student.firstName,
						last = student.lastName,
						media = student.mediaURL {
							let lat = CLLocationDegrees(Double((lat)))
							let long = CLLocationDegrees(Double((lon)))
							let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
							let annotation = MKPointAnnotation()
							annotation.coordinate = coordinate
							annotation.title = "\(first) \(last)"
							annotation.subtitle = media
							annotations.append(annotation)
					}
				}
				if annotations.count <= 0 {
					self.showAlertViewController("Alert", message: "There are no annotations at present")
				} else {
					self.mapView.addAnnotations(annotations)
				}
			} else {
				self.showAlertViewController("Error", message: "Unable to get student data")
			}
		}
	}
	
	//MARK: - delete the current pin location for logged-in student

	@IBAction func deleteAssignedPin(sender: AnyObject) {
		activityIndicator.startAnimating()
		let parseClient = ParseClient.sharedInstance
		parseClient.queryForStudent(uniqueKey!){
			(student, errorString) in
			if let student = student {
				if let objectId = student.objectId{
					parseClient.currentStudent!.objectId = objectId
					parseClient.deleteStudent(objectId){ completed, errorString in
						if completed == false {
							if let _ = errorString {
								self.showAlertViewController("Whoops!", message: "Could not delete the pin")
							} else {
								self.showAlertViewController("Whoops!", message: "Error while deleting")
							}
						} else {
							self.stopActivityIndicator()
							self.getStudentsFromServer()
						}
					}
				} else {
					self.showAlertViewController("Whoops!", message: "Error while retrieving your details")
				}
			} else {
				self.showAlertViewController("Oops!", message: "A pin has not been posted yet")
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

	//reload the page
	@IBAction func reloadPage(sender: UIBarButtonItem) {
		getStudentsFromServer()
	}
	
	//MARK: - helper methods
	
	//show an AlertViewController
	func showAlertViewController(title: String? , message: String?) {
		performUIUpdatesOnMain {
			self.stopActivityIndicator()
			if title != nil && message != nil {
				let errorAlert =
				UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
				errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(errorAlert, animated: true, completion: nil)
			}
		}
	}
	
	//initialize the activity indicator
	func setUpActivityIndicator() {
		activityIndicator.frame = CGRect(x: 0, y: -50, width: self.view.frame.width, height: self.view.frame.height)
		mapView.addSubview(activityIndicator)
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

//MARK: - MKMapView Delegate methods

extension MapViewController: MKMapViewDelegate {
	
	//view for animation
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		
		let reuseId = "pin"
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		if pinView == nil { //if it cant find a reusable one, make a new annotation view
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinTintColor = UIColor.redColor()
			pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
		}
		else {
			pinView!.annotation = annotation
		}
		return pinView
	}
	
	//call out accessory control tapped
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			let app = UIApplication.sharedApplication()
			
			if let urlString = view.annotation?.subtitle! {
				if let url = NSURL(string: urlString) {
					if app.canOpenURL(url) {
						app.openURL(url)
					} else {
						showAlertViewController("Whoops!", message: "Looks like this student put in an incorrect URL")
					}
				}
			}
		}
	}
}


