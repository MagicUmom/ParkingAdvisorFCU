//
//  MainViewController.swift
//  ParkingAdvisor
//
//  Created by WeiKang on 2017/11/19.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import Alamofire
import WebKit

class MainViewController: UIViewController ,CLLocationManagerDelegate, GMSMapViewDelegate , WKUIDelegate{
    
    let config  = sizeConfig()

    @IBOutlet weak var uiview_mapView: UIView!
    
    // webview
    var webView: WKWebView!
//    var myWebView: UIWebView!

    // map view
    var isMapInit : Bool = false
    var mapView : GMSMapView!
    var blurEffectView : UIVisualEffectView!
    let locationManager = CLLocationManager()
    var img_view_tick : UIImageView = UIImageView()
    var locationCircle : GMSCircle = GMSCircle()
    var marker_myLocation : GMSMarker = GMSMarker()
    
    // marker tapped
    var marker_tapped : GMSMarker = GMSMarker()

    // monitor
    private var monitorTimer = Timer()
    private var monitorCounter : Int = 0
    private var isMonitor : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        isMapInit = false
        initMap()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(
            x: 0, y: 0,
            width: 414,
            height:
            320), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.alpha = 0
        let myURL = URL(string: "http://192.168.2.103:8081")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        self.view.addSubview(webView)

        // webview Configuration
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
////        webView.alpha = 0
//        uiview_mapView.addSubview(webView)


    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 取得定位要求
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }
            // 2. 用戶不同意
        else if CLLocationManager.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Alert", message: "未提供GPS資訊", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "瞭解", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
            // 3. 用戶已經同意
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Init
    
    func initMap() {
        let camera = GMSCameraPosition.camera(withLatitude: PASingleton.sharedInstance().getLocation().latitude,
                                              longitude: PASingleton.sharedInstance().getLocation().longitude,
                                              zoom: 19)
        if(uiview_mapView != nil){
            self.mapView = GMSMapView.map(withFrame: uiview_mapView.frame, camera: camera)
        }
        self.mapView.frame.origin = CGPoint.zero
        mapView.delegate = self
        
        if(uiview_mapView != nil){
            mapView.settings.myLocationButton = true
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            
            //  標記主要位置
            self.marker_myLocation.position = camera.target
            self.marker_myLocation.map = mapView

            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "sdstyle", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
            
            // 製作google circle 圓圈
            self.locationCircle.radius = 40 // Meters
            self.locationCircle.position = camera.target
            self.locationCircle.fillColor = UIColor(rgba:0x00a0dfaa)
            self.locationCircle.strokeWidth = 3
            self.locationCircle.strokeColor = UIColor(rgba: 0x232288aa )
            self.locationCircle.map = mapView
            
            
            uiview_mapView.insertSubview(mapView, at: 0)
            isMapInit = true
            
            // 拿點
            self.getPointFromAPI(location: PASingleton.sharedInstance().getLocation())
        }
        
    }
    
    // MARK: - MAP Delegate
    
    @nonobjc func mapView(_ mapView : GMSMapView, didTapMarker marker: GMSMarker){
        
        NSLog("marker did tap")
//        self.marker_tapped = marker
//        if(detailVCisOn == true){
//            self.updateVC()
//            return
//        }else{
//            self.showVC()
//        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        let vancouver = CLLocationCoordinate2D(latitude:PASingleton.sharedInstance().getLocation().latitude, longitude: PASingleton.sharedInstance().getLocation().longitude)
        let vancouverCam = GMSCameraUpdate.setTarget(vancouver)
        mapView.animate(with: vancouverCam)
        return true
    }
    
    
    // MARK: - MAP POINT
    func getPointFromAPI(location:CLLocationCoordinate2D){
        
        if let path = Bundle.main.path(forResource: "database", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    print("jsonData:\(jsonObj)")
                    showPointAtMap(arrayToShow: jsonObj)
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        
    }
    
    func showPointAtMap(arrayToShow :NSArray ,color :String){
        for i in (0..<arrayToShow.count) where i % 2 == 0 {
            let position = CLLocationCoordinate2D(latitude: Double(String(describing: arrayToShow[i+1]))! , longitude: Double(String(describing: arrayToShow[i]))! )
            let point = GMSMarker(position: position)
            point.title = color
            point.icon = UIImage(named: "map_point_"+color)
            point.map = self.mapView
        }
        
        
    }
    func showPointAtMap(arrayToShow :JSON){
        
        for i in (0..<arrayToShow.count){
            let position = CLLocationCoordinate2D(latitude: arrayToShow[i]["lat"].doubleValue , longitude: arrayToShow[i]["long"].doubleValue )
            let point = GMSMarker(position: position)
            
            point.title = arrayToShow[i]["roadname"].stringValue
            
            if ( arrayToShow[i]["score"].intValue < 40){
                point.icon = UIImage(named: "map_point_red")
            }else if( arrayToShow[i]["score"].intValue < 70){
                point.icon = UIImage(named: "map_point_yellow")
            }else if( arrayToShow[i]["score"].intValue <= 100){
                point.icon = UIImage(named: "map_point_green")
            }
            point.snippet = arrayToShow[i]["score"].stringValue
            point.map = self.mapView
            
        }
    }
    
    //    MARK: - BTN ACTION
    @IBAction func btn_report(_ sender: Any) {
//        self.marker_myLocation.position = CLLocationCoordinate2D(latitude: 24.180134, longitude: 120.645128)
//        self.locationCircle.position = CLLocationCoordinate2D(latitude: 24.180134, longitude: 120.645128)
        
        if webView.alpha == 1 {
            webView.alpha = 0
        }else {webView.alpha = 1}
        
        // [START subscribe_topic]
        Messaging.messaging().subscribe(toTopic: "news")
        print("Subscribed to news topic!!")
        // [END subscribe_topic]


    }
    @IBAction func btn_monitor(_ sender: Any) {
//         [START log_fcm_reg_token]
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
//         [END log_fcm_reg_token]
        
        let parameters : Dictionary = [
            "UUID":"231123",
            "Latitude":"25.12345",
            "Longitude":"124.123456"
        ]
        
        Alamofire.request("http://140.134.25.56/api/GetPosition", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        let comm = ServerCommunicator.shareInstance()
        comm.send_location(parameter: parameters) {(json)in
            if json == JSON.null {
                print("send location fail")
                return
            }
        }
    }
    
}
