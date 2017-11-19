//
//  ReportViewController.swift
//  ParkingAdvisor
//
//  Created by MCLAB on 2017/6/29.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications
import UserNotificationsUI

class ReportViewController: UIViewController ,CLLocationManagerDelegate, GMSMapViewDelegate ,CircleBarProtocol{
    
    
    var circleVC : CircleBarViewController! = nil
    let  requestIdentifier = "SampleRequest" //identifier is to cancel the notification request
    
    // map view
    var isMapInit : Bool = false
    var mapView : GMSMapView!
    let locationManager = CLLocationManager()
    var blurEffectView : UIVisualEffectView!
    
    @IBOutlet weak var uiview_mapView: UIView!
    @IBOutlet weak var lbl_address: UILabel!
    
    @IBOutlet weak var lbl_thanks: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        initMap()
        blurInit()
        self.spreadOut()
        self.circleVC?.editCircleBarTitle(titleIndex : 5)
        self.circleVC?.setCircleTitleClickable(isClickable: true)
        self.circleVC?.hightLightBTNIcon(index: 2)
        
        
        self.lbl_thanks.alpha = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        
        // Do any additional setup after loading the view.
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
        
        
        
        tabBarController?.tabBar.isHidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    // MARK: - MAP
    
    func initMap() {
        lbl_address.text = PASingleton.sharedInstance().getAddress()
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
            isMapInit = true
            CATransaction.begin()
            CATransaction.setValue(1, forKey: kCATransactionAnimationDuration)
            mapView.animate(toZoom: 19.0)
            CATransaction.commit()
            
        }
    }
    
    func blurInit(){
        // blur effect
        let blurEffect : UIBlurEffect!
        blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0
        blurEffectView.frame.size = uiview_mapView.frame.size
        blurEffectView.frame.origin = CGPoint.zero
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.clipsToBounds = true
        
    }
    
    func reported(){
        print("reported")
        self.uiview_mapView.addSubview(blurEffectView)
        self.uiview_mapView.bringSubview(toFront: self.lbl_thanks)
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseIn, animations: {
            self.blurEffectView.alpha = 0.9
            self.lbl_thanks.alpha = 1
            
        },completion:{_ in
            UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
                self.blurEffectView.alpha = 0
                self.lbl_thanks.alpha = 0
                
            })
        })
        
    }
    
    // MARK - Label
    
    func initLabel(){
//        lbl_location.text = String(format: "%6f, %6f", PASingleton.sharedInstance().getLocation().latitude, PASingleton.sharedInstance().getLocation().longitude)
//        
//        lbl_address.text = PASingleton.sharedInstance().getAddress()
//        lbl_thanks.alpha = 0
    }
    
    // MARK - Button
    
    
    func pushNotification(){
        print("notification will be triggered in one seconds..Hold on tight")
        let content = UNMutableNotificationContent()
        //        content.title = "Intro to Notifications"
        //        content.subtitle = "Lets code,Talk is cheap"
        //        content.body = "Sample code from WWDC"
        content.title = "警告"
        content.body = "有其他使用者通報此處正在開單！"
        content.sound = UNNotificationSound.default()
        
        //To Present image in notification
        //        if let path = Bundle.main.path(forResource: "monkey", ofType: "png") {
        //            let url = URL(fileURLWithPath: path)
        //
        //            do {
        //                let attachment = try UNNotificationAttachment(identifier: "sampleImage", url: url, options: nil)
        //                content.attachments = [attachment]
        //            } catch {
        //                print("attachment not found.")
        //            }
        //        }
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier:requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription)
            }
        }
        
    }
    
    // MARK: - TAB_BAR Protocol
    func TitleAction(State : Int){
        switch State {
        case 5 :
            self.reported()
            if(PASingleton.sharedInstance().getIsMonitor()){
                self.pushNotification()
            }
            return
        default:
            print("Title Action 找不到相對應的動作")
            return
        }
    }
    
    func spreadOut(){
        //  隱藏原本的tabbar
        self.tabBarController?.tabBar.isHidden = true
        //  顯示圓形的tabbar
        circleVC = storyboard!.instantiateViewController(withIdentifier: "CircleBarViewController") as! CircleBarViewController
        circleVC.delegate = self
        
        self.view.addSubview(circleVC.view)
        self.addChildViewController(circleVC)
        circleVC.view.frame.origin.y = self.view.bounds.height * 0.72
        
    }
    
    func shrinkIn() -> Bool{
        if(PASingleton.sharedInstance().getIsSpreaded())
        {
            let viewBack : UIView = view.subviews.last!
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                //        self.willMove(toParentViewController: nil)
                var frameMenu : CGRect = viewBack.frame
                frameMenu.origin.y = 2 * UIScreen.main.bounds.size.height
                viewBack.frame = frameMenu
                
                viewBack.layoutIfNeeded()
                viewBack.backgroundColor = UIColor.clear
                //        self.removeFromParentViewController()
            }, completion: { (finished) -> Void in
                viewBack.removeFromSuperview()
                self.tabBarController?.tabBar.isHidden = false
                
            })
            PASingleton.sharedInstance().setIsSpreaded(isSpreaded: false)
            
            return true
        }
        return false
    }
    
}

extension ReportViewController:UNUserNotificationCenterDelegate{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == requestIdentifier{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

