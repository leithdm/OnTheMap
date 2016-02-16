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
		
		parseData()
		
		
	}
	
	func parseData() {
		//create request
		let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
		request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
		
		//create session
		let session = NSURLSession.sharedSession()
		
		//create task
		let task = session.dataTaskWithRequest(request) { data, response, error in
			//error checking
			guard error == nil else {
				print("error: \(error)")
				return
			}
			
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				print("Error with status code")
				return
			}
			
			guard let data = data else {
				print("error parsing data")
				return
			}
			
			//parse the data
			let parsedData: AnyObject!
			
			do {
				parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
			} catch {
				parsedData = nil
				print("Error parsing the data")
				return
			}
			
			guard let dictionary = parsedData["results"] as? [[String: AnyObject]] else {
				print("Data not found")
				return
			}
			
			for dictionary in dictionary {
				
				// Notice that the float values are being used to create CLLocationDegree values.
				// This is a version of the Double type.
				let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
				let long = CLLocationDegrees(dictionary["longitude"] as! Double)
				
				// The lat and long are used to create a CLLocationCoordinates2D instance.
				let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
				
				let first = dictionary["firstName"] as! String
				let last = dictionary["lastName"] as! String
				let mediaURL = dictionary["mediaURL"] as! String
				
				// Here we create the annotation and set its coordiate, title, and subtitle properties
				let annotation = MKPointAnnotation()
				annotation.coordinate = coordinate
				annotation.title = "\(first) \(last)"
				annotation.subtitle = mediaURL
				
				// Finally we place the annotation in an array of annotations.
				self.annotations.append(annotation)
			}

			self.mapView.addAnnotations(self.annotations)
			
		}
		task.resume()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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


