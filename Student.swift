//
//  Student.swift
//  OnTheMap
//
//  Created by Darren Leith on 16/02/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

struct Student {
	
	var objectId:String?
	var uniqueKey: String?
	var firstName: String?
	var lastName: String?
	var mapString: String?
	var mediaURL: String?
	var latitude: Float?
	var longitude: Float?
	
	init(dictionary: [String: AnyObject]?) {
		if let dictionary = dictionary {
			if let objectId = dictionary["objectId"] as? String {
				self.objectId = objectId
			}
			if let uniqueKey = dictionary["uniqueKey"] as? String {
				self.uniqueKey = uniqueKey
			}
			if let firstName = dictionary["firstName"] as? String{
				self.firstName = firstName
			}
			if let lastName = dictionary["lastName"] as? String{
				self.lastName = lastName
			}
			if let mapString = dictionary["mapString"] as? String {
				self.mapString = mapString
			}
			if let mediaURL = dictionary["mediaURL"] as? String {
				self.mediaURL = mediaURL
			}
			if let latitude = dictionary["latitude"] as? Float {
				self.latitude = latitude
			}
			if let longitude = dictionary["longitude"] as? Float{
				self.longitude = longitude
			}
		}
	}
	
	// Print statment for Student
	var description: String {
		let empty = "nil"
		return String("Student [objectId: \((objectId == nil) ? empty : objectId!), uniqueKey: \((uniqueKey == nil) ? empty : uniqueKey!), firstName: \((firstName == nil) ? empty : firstName!), lastName: \((lastName == nil) ? empty : lastName!), mapString: \((mapString == nil) ? empty : mapString!), mediaURL: \((mediaURL == nil) ? empty : mediaURL!), latitude: \((latitude == nil) ? 0 : latitude!), longitude: \((longitude == nil) ? 0 : longitude!)]")
	}
}
