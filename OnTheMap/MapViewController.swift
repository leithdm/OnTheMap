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
	
	
	//MARK: - lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		
	}
	
	override func viewDidAppear(animated: Bool) {
		getStudentsFromServer()
	}
	
	
	//MARK: - get students from server
	
	func getStudentsFromServer() {
		//activityIndicator.startAnimating()
		
		ParseClient.sharedInstance.getStudentLocations { (result, error) -> Void in
			
			if let students = result as? [[String: AnyObject]] {
				
				var studentArray = [Student]()
				
				for studentData in students {
					studentArray.append(Student(dictionary: studentData))
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
				}
			} else {
				if let errorString = error {
					self.showAlertViewController("Error", message: String(errorString.userInfo))
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
	
	//reload the page
	@IBAction func reloadPage(sender: UIBarButtonItem) {
		getStudentsFromServer()
	}
	
	//MARK: - helper methods
	
	//show an AlertViewController
	func showAlertViewController(title: String? , message: String?) {
		
		performUIUpdatesOnMain {
			//self.activityIndicator.stopAnimating()
			if title != nil && message != nil {
				let errorAlert =
				UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
				errorAlert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
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
			
			if let toOpen = view.annotation?.subtitle! {
				app.openURL(NSURL(string: toOpen)!)
			}
		}
	}
}


