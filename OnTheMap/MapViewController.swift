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
	
	@IBOutlet weak var mapView: MKMapView!
	var annotations = [MKPointAnnotation]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func getStudentsFromServer() {
		//		activityIndicator.startAnimating()
		let parseClient = ParseClient.sharedInstance
		
		parseClient.getStudentLocations { (result, error) -> Void in
			if let students = result {
				if let applicationDelegate = self.applicationDelegate{
					var studentArray: [Student] = [Student]()
					for studentData in students {
						studentArray.append( Student(dictionary: studentData) )
					}
					if studentArray.count > 0 {
						dispatch_async(dispatch_get_main_queue()){
							applicationDelegate.students = studentArray
							if self.mapView.annotations.count > 0 {
								self.mapView.removeAnnotations(self.mapView.annotations)
								self.addAnnotationsToMap()
							} else {
								self.addAnnotationsToMap()
							}
						}
//						self.stopActivityIndicator()
					} else { self.stopActivityIndicator() }
				} else { self.showAlert("Error", message: "Unable to access App Delegate") }
			}else {
				if let errorString = error {
					self.showAlert("Error", message: errorString)
				} else {
					self.showAlert("Error", message: "Unable to retrieve data")
				}
			}
		}
	}
	
	
	
	
}

extension MapViewController: MKMapViewDelegate {
	// MARK: - MKMapViewDelegate
	
	// Here we create a view with a "right callout accessory view". You might choose to look into other
	// decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
	// method in TableViewDataSource.
	
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		
		let reuseId = "pin"
		
		//try to deque a reusable annotation view
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		
		if pinView == nil { //if it cant find a reusable one, make a new annotation view
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinTintColor = UIColor.purpleColor()
			pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			let app = UIApplication.sharedApplication()
			if let toOpen = view.annotation?.subtitle! {
				app.openURL(NSURL(string: toOpen)!)
			}
		}
	}
}


