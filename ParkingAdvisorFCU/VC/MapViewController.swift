//
//  MapViewController.swift
//  ParkingAdvisorFCU
//
//  Created by MCLAB on 2017/11/14.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController ,CLLocationManagerDelegate, GMSMapViewDelegate{
    
    // map view
    @IBOutlet weak var uiview_mapView: UIView!
    var mapView : GMSMapView!
    let locationManager = CLLocationManager()

    // marker tapped
    var marker_tapped : GMSMarker = GMSMarker()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    // MARK: - Init
    
    func initMap() {
        // 初次開地圖為展開狀態
        let camera = GMSCameraPosition.camera(withLatitude: PASingleton.sharedInstance().getLocation().latitude,
                                              longitude: PASingleton.sharedInstance().getLocation().longitude,
                                              zoom: 10)
        if(uiview_mapView != nil){
            self.mapView = GMSMapView.map(withFrame: uiview_mapView.frame, camera: camera)
        }
        self.mapView.frame.origin = CGPoint.zero
        mapView.delegate = self
        
        if(uiview_mapView != nil){
            mapView.settings.myLocationButton = true
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            let marker = GMSMarker()
            
            marker.position = camera.target
            //        marker.snippet = "Hello World"
            //        marker.appearAnimation = GMSMarkerAnimationPop
            
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "bstyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
            marker.map = mapView
            
            uiview_mapView.addSubview(mapView)
//            updateCameraByGPS()
        }
        
    }

}

