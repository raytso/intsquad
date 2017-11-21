//
//  UserLocationMapView.swift
//  NoMoreParking
//
//  Created by Ray Tso on 3/14/17.
//  Copyright © 2017 Ray Tso. All rights reserved.
//

import UIKit
import MapKit

//protocol UserLocationConfirmationDelegate: class {
//    func userConfirmedLocation(sender: MKAnnotation)
//}

class UserLocationMapView: MKMapView, UIGestureRecognizerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func locationButtonPressed() {
        // center map to user location
        // change colour
    }
    
    // MARK: - Properties
    
    var userPinnedAnnotation: MKAnnotation? {
        didSet {
            guard userPinnedAnnotation != nil else { return }
            addPin(annotation: userPinnedAnnotation!, animated: true)
        }
    }
    
//    weak var userLocationDelegate: UserLocationConfirmationDelegate?
    
    var gestureLongPress: UILongPressGestureRecognizer?
    
    // MARK: - UDFs
    
    func prepareToShowAnnotationView(annotation: MKAnnotation) {
        UIView.animate(withDuration: 1.5, animations: {
            // add pin
            
        }) { (_) in
            self.selectAnnotation(annotation, animated: true)
        }
    }
    
    func addPin(annotation: MKAnnotation, animated: Bool) {
        self.addAnnotation(annotation)
//        self.showAnnotations([annotation], animated: animated)
    }
    
    func removePin(annotation: MKAnnotation?, animation: Bool) {
        guard annotation != nil else { return }
        if annotation is MKUserLocation { return }
        
        removeAnnotation(annotation!)
    }
    
    func centerMapToPoint(point: MKAnnotation) {
        
    }
    
    func addPinByGesture(gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            removePin(annotation: userPinnedAnnotation, animation: true)
            let point = gesture.location(in: self)
            let newCoordinate = self.convert(point, toCoordinateFrom: self)

            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinate
            annotation.title = " "
            userPinnedAnnotation = annotation
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gestureLongPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.addPinByGesture(gesture:)))
        gestureLongPress?.minimumPressDuration = 0.25
        self.addGestureRecognizer(gestureLongPress!)
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
