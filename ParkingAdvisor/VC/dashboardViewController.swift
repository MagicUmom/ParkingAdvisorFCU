//
//  dashboardViewController.swift
//  ParkingAdvisor
//
//  Created by MCLAB on 2017/4/11.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import UIKit
import GoogleMaps
import AFNetworking

class dashboardViewController: UIViewController ,CLLocationManagerDelegate, GMSMapViewDelegate , CircleBarProtocol{
    
    var circleVC : CircleBarViewController! = nil
    
    // scan view
    private var progress: UInt8 = 0
    private var animationTimer = Timer()
    
    
    let config  = sizeConfig()
    // parameter
    let color_lightblue_lbl = UIColor(rgba : 0x388BB8FF)
    var isStartAnalyse : Bool = false
    var detailVCisOn : Bool = false
    var isSpreaded : Bool = true
    
    // label
    @IBOutlet weak var lbl_address: UILabel!
    @IBOutlet weak var lbl_prccessing : UILabel!
    @IBOutlet weak var lbl_score: UILabel!
    var lbl_progress : UILabel = UILabel()
    
    
    // map view
    var isMapInit : Bool = false
    var mapView : GMSMapView!
    var blurEffectView : UIVisualEffectView!
    let locationManager = CLLocationManager()
    var img_view_tick : UIImageView = UIImageView()
    
    @IBOutlet weak var uiimgview_ten : UIImageView!
    @IBOutlet weak var uiimgview_one : UIImageView!
    @IBOutlet weak var uiimgview_percent : UIImageView!
    
    @IBOutlet weak var uiview_mapView: UIView!
    
    // marker tapped
    var marker_tapped : GMSMarker = GMSMarker()
    
    // title view
    @IBOutlet weak var uiview_proccessing: UIView!
    @IBOutlet weak var uiview_address: UIView!
    
    private var monitorTimer = Timer()
    private var monitorCounter : Int = 0
    private var isMonitor : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        isMapInit = false
        blurInit()
        initMap()
        // set background
//        UIGraphicsBeginImageContext(self.view.frame.size)
//        UIImage(named: "background_2")?.draw(in: self.view.bounds)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        self.view.backgroundColor = UIColor(patternImage: image)
        
        
//        configureMyCircleProgress()
    }
    
    /*
     *
     *  initMap() blurInit()
     *  updateCameraByGPS()
     *
     *
     *
     *
     *
     */
    
    // MARK: - LIFE CYCLE
    
    override func loadView() {
        super.loadView()
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
        
        
    
        
        if(!self.isSpreaded){
            tabBarController?.tabBar.isHidden = false
        }else{
            tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
//        animationTimer.invalidate()
//        monitorTimer.invalidate()
//        uiview_mapView?.removeFromSuperview()
//        myCircleProgress?.removeFromSuperview()
//        pulsator.stop()
//        pulsator.removeFromSuperlayer()
//        background_circle.removeFromSuperview()
    }
    
    
    // MARK: - ViewController Method
    
    @objc private func updateProgress() {
        if Double(progress) / Double(UInt8.max) < 99/255
            //Double(PASingleton.sharedInstance().getScore()) / Double(100)
        {
            progress = progress &+ 1
            self.uiimgview_ten.image = UIImage(named: "DG_b_\(progress / 10 % 10)")
            self.uiimgview_one.image = UIImage(named: "DG_b_\(progress % 10 )")
            
            
            // old function
//            self.lbl_progress.text = "\(progress)"
//            print(progress)
//            let normalizedProgress = Double(progress) / Double(UInt8.max)
//            myCircleProgress.progress = normalizedProgress
            
        }else{
            print("ScanView updateProgress end")
            
            // 跑馬燈動畫結束
            self.circleVC.uiview_background.layer.removeAllAnimations()
            
            CATransaction.commit()
            
            self.setNumbersAlpha(alpha: 0)
            animationTimer.invalidate()
            
            // after score animate finished
            self.lbl_progress.text = setScoreChinese()
            self.lbl_progress.font = self.lbl_progress.font.withSize(95)
            self.lbl_progress.sizeToFit()
            self.lbl_progress.center.x = self.view.center.x
            self.shrinkIn()
            self.isSpreaded = false
            // text score view appear
            
            // 打勾/驚嘆號 動畫 開始
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                // 完成打勾/驚嘆號動畫後的動作
                UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseIn, animations: {
                    // 打勾/驚嘆號 動畫 結束
                    
                    self.blurEffectView.alpha = 0
                    self.lbl_progress.alpha = 0
                    self.img_view_tick.alpha = 0
                    
                }, completion: {_ in
                    // 從資料拿到點
                    self.getPointFromAPI(location: PASingleton.sharedInstance().getLocation())
                    // 消失uiview_address
                    self.uiview_address.alpha = 0
                    // 接上消失標語 出現大地圖
                    self.blurEffectView.removeFromSuperview()
                    self.img_view_tick.removeFromSuperview()
                    
                })
                
            })
            self.Animate_tick(score: PASingleton.sharedInstance().getScore())
            CATransaction.commit()
            
            
            
            
        }
    }
    
    func setScoreChinese() -> String {
        let score : Int = PASingleton.sharedInstance().getScore()
        
        if (score < 20){
            return "極危險"
        }else if (score <= 40){
            return "危險"
        }else if (score <= 60){
            return "需注意"
        }else if (score <= 80){
            return "安全"
        }else if (score <= 100){
            return "極安全"
        }
        print("error -- no score --")
        return "無資料"
    }
    
    // MARK: - Init
    
    func initMap() {
        // 初次開地圖為展開狀態
        self.isSpreaded = true
        
        lbl_prccessing.text = "定位中"
        lbl_prccessing.alpha = 1
        lbl_score.alpha = 0
        lbl_address.text = "請稍等"
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
            
            self.setNumbersAlpha(alpha: 0)
            uiview_mapView.addSubview(mapView)
            isMapInit = true
            updateCameraByGPS()
        }
        
    }
    
    func setNumbersAlpha(alpha : CGFloat){
        uiimgview_ten.alpha = alpha
        uiimgview_one.alpha = alpha
        uiimgview_percent.alpha = alpha
        
    }
    
//    func pulseInit(){
//
//        pulsator.radius = uiview_mapView.frame.width / 2 + 50
//        pulsator.numPulse = 5
//        pulsator.animationDuration = 10
//        pulsator.pulseInterval = 1
//        pulsator.backgroundColor = UIColor(red: 0/255, green: 169/255, blue: 180/255, alpha: 1).cgColor
//        pulsator.position = uiview_mapView.center
//        self.view.layer.insertSublayer(pulsator, below: uiview_mapView.layer)
//
//    }
    
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
    
    func updateCameraByGPS() {
        
        lbl_prccessing.text = "周遭評估"
        lbl_address.text = PASingleton.sharedInstance().getAddress()
        let camera = GMSCameraPosition.camera(withLatitude: PASingleton.sharedInstance().getLocation().latitude,
                                              longitude: PASingleton.sharedInstance().getLocation().longitude,
                                              zoom: 10)
        let marker = GMSMarker()
        marker.position = camera.target
        marker.map = mapView
        CATransaction.begin()
        CATransaction.setValue(1, forKey: kCATransactionAnimationDuration)
        mapView.animate(toZoom: 19.0)
        CATransaction.commit()
        
//        lbl_location.text = "\(locationManager.location!.coordinate.latitude) ,\(locationManager.location!.coordinate.longitude)"
//        lbl_location.text = String(format: "%6f, %6f", PASingleton.sharedInstance().getLocation().latitude, PASingleton.sharedInstance().getLocation().longitude)
        
        if(self.spreadOut()){
            self.circleVC?.editCircleBarTitle(titleIndex : 1)
            self.circleVC?.setCircleTitleClickable(isClickable: true)
            self.circleVC?.hightLightBTNIcon(index: 0)
            print("spreadOuted")
        }
        
    }
    
    func startAnalyse() {
        if(isStartAnalyse == false){
            isStartAnalyse = true
            
            // 設定title標題、點按與否
            circleVC?.setCircleTitleClickable(isClickable: false)
            circleVC.editCircleBarTitle(titleIndex: 1)
            
            // 毛玻璃開始
            // blur effect
            if(uiview_mapView != nil){
                self.uiview_mapView.addSubview(blurEffectView)
                print("insert blurEffectView")
            }
            UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseIn, animations: {
                self.blurEffectView.alpha = 0.9
            },completion: {_ in
                // 毛玻璃結束
                
                // 開始分析動畫 數字跑動
                
                self.progress = 0
                self.lbl_progress = UILabel(frame: CGRect(x: (self.uiview_mapView.frame.width - self.config.getSize(key: "lbl_progress_width")) / 2 , y: (self.uiview_mapView.frame.height - self.config.getSize(key: "lbl_progress_height")) / 2 , width: self.config.getSize(key: "lbl_progress_width"), height: self.config.getSize(key: "lbl_progress_height")))
                self.lbl_progress.font = UIFont(name: "HelveticaNeue", size: self.config.getSize(key: "lbl_progress_size"))
                self.lbl_progress.textAlignment = .center
                self.lbl_progress.textColor = UIColor(rgba: 0x666666FF)
//                self.lbl_progress.text = "0"
                self.uiview_mapView.bringSubview(toFront: self.uiimgview_one)
                self.uiview_mapView.bringSubview(toFront: self.uiimgview_ten)
                self.uiview_mapView.bringSubview(toFront: self.uiimgview_percent)
                self.setNumbersAlpha(alpha: 1)
                self.uiview_mapView.addSubview(self.lbl_progress)
                self.animationTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(dashboardViewController.updateProgress), userInfo: nil, repeats: true)
                
                let colors = [ UIColor(rgba: 0x00a0dfff).cgColor,UIColor(rgba: 0x232288ff).cgColor,UIColor(rgba: 0xe3007eff).cgColor,UIColor(rgba: 0xe51f1fff).cgColor,UIColor(rgba: 0xfeed00ff).cgColor,UIColor(rgba: 0x00974bff).cgColor  ]
                CATransaction.begin()
                let locations = [0, 0.15, 0.25, 0.5, 1]
                self.circleVC.LightAnimation(colors: colors, locations: locations)
            })
            
        }
    }
    
    // MARK: - TAB_BAR Protocol
    func TitleAction(State : Int){
        switch State {
        case 0 :
            print("Title Action ERROR")
            return
        case 1 :
            self.startAnalyse()
            return
        case 2 :
            return
        default:
            print("Title Action 找不到相對應的動作")
            return
        }
    }
    
    func spreadOut() -> Bool{
            //  隱藏原本的tabbar
            self.tabBarController?.tabBar.isHidden = true
            //  顯示圓形的tabbar
            circleVC = storyboard!.instantiateViewController(withIdentifier: "CircleBarViewController") as! CircleBarViewController
            circleVC.delegate = self
            
            self.view.addSubview(circleVC.view)
            self.addChildViewController(circleVC)
            circleVC.view.frame.origin.y = self.view.bounds.height * 0.72
            self.isSpreaded = true
            
            return true
    }
    
    func shrinkIn() -> Bool{
        
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
            self.isSpreaded = false
        })
        return true
    }
    
    // MARK: - MAP Delegate
    
    func mapView(_ mapView : GMSMapView, didTapMarker marker: GMSMarker){
        
        NSLog("marker did tap")
        self.marker_tapped = marker
        if(detailVCisOn == true){
            self.updateVC()
            return
        }else{
            self.showVC()
        }
        
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
            
            //            print("\(point)")
            
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
    
    // MARK: - DetailView Controll
    
    func closeVC() {
        
        NSLog("closeVC")
        
        if(detailVCisOn == true){
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
            })
            detailVCisOn = false
            
        }
        
    }
    
    func showVC(){
        
        self.lbl_address.text = self.getAddress()
        self.lbl_address.frame.origin.x = view.frame.width * 0.03
        self.lbl_score.text = self.getScore()
        self.lbl_score.alpha = 1
        
        
        self.uiview_address.alpha = 0.8
        detailVCisOn = true
        
    }
    
    func updateVC(){
        closeVC()
        showVC()
        return
    }
    
    func getLocation() -> String{
        return String(format: "%6f, %6f", marker_tapped.position.latitude, marker_tapped.position.longitude)
    }
    func getAddress() -> String{
        return marker_tapped.title!
        
        
    }
    func getScore() -> String{
        return marker_tapped.snippet!+"分"
        
    }
    
    // MARK: - Animate
    
    func Animate_tick( score: Int ){
        
        var img_tick : UIImage = UIImage()
        if(score > 50){
            img_tick = UIImage(named: "map_tick")!
            img_view_tick = UIImageView(image: img_tick)
            img_view_tick.frame = CGRect(x: 146,y: 405,width:123 , height: 83 )
        }else{
            img_tick = UIImage(named: "map_exmark")!
            img_view_tick = UIImageView(image: img_tick)
            img_view_tick.frame = CGRect(x: 194,y: 382,width:26 , height: 102 )
            
        }
        self.uiview_mapView.addSubview(img_view_tick)
        
        let path = UIBezierPath(rect: CGRect(x:0,y:0,width:0,height:img_view_tick.frame.height))
        let newPath = UIBezierPath(rect: img_view_tick.bounds)
        
        let layer = CAShapeLayer()
        layer.frame = img_view_tick.bounds
        layer.path = path.cgPath
        
        img_view_tick.layer.mask = layer
        
        let anim = CABasicAnimation(keyPath : "path")
        anim.fromValue = layer.path
        anim.toValue  = newPath.cgPath
        anim.duration = 0.8
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        layer.add(anim, forKey: "path")
        layer.path = newPath.cgPath
        img_view_tick.layer.mask = layer
        
    }
    
    
    
    // MARK: - Button
    
//    @IBAction func btn_startAnalyse(_ sender: Any) {
//        if(isStartAnalyse == false){
//            isStartAnalyse = true
//            // 毛玻璃開始
//            // blur effect
//            if(uiview_mapView != nil){
//                uiview_mapView.addSubview(blurEffectView)
//            }
//            UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseIn, animations: {
//                self.blurEffectView.alpha = 0.9
//            },completion: {_ in
//                // 毛玻璃結束
//                // do something ...
//                // need to edit ...
//                // 開始分析動畫 數字跑動
//                self.progress = 0
//                self.lbl_progress = UILabel(frame: CGRect(x: (self.uiview_mapView.frame.width - self.config.getSize(key: "lbl_progress_width")) / 2 , y: (self.uiview_mapView.frame.height - self.config.getSize(key: "lbl_progress_height")) / 2 , width: self.config.getSize(key: "lbl_progress_width"), height: self.config.getSize(key: "lbl_progress_height")))
//                self.lbl_progress.font = UIFont(name: "HelveticaNeue", size: self.config.getSize(key: "lbl_progress_size"))
//                self.lbl_progress.textAlignment = .center
//                self.lbl_progress.textColor = UIColor(rgba: 0x5AC8FAFF)
//                self.lbl_progress.text = "0"
//                self.uiview_mapView.addSubview(self.lbl_progress)
//                self.animationTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(dashboardViewController.updateProgress), userInfo: nil, repeats: true)
//
//                self.lbl_prccessing.text = "掃描中"
//                self.btn_scan.isHidden = false
//            })
//
//        }
//    }
    
//    @IBAction func btn_startMonitor(_ sender: Any) {
//        NSLog("btn_startMonitor pressed")
//        if(self.isMonitor == false){
//            self.isMonitor = true
//            monitorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dashboardViewController.upgradeMonitorTimer), userInfo: nil, repeats: true)
//        }else{
//            self.stopMonitor()
//            self.isMonitor = false
//        }
//    }
    // MARK: Monitor
//
//    func upgradeMonitorTimer(){
//        lbl_startMonitor.text = "停止監控"
//
//        monitorCounter = monitorCounter + 1
//        self.lbl_progress.text = String(format: "%.2d:%.2d", monitorCounter / 60, monitorCounter % 60)
//
//    }
//    func stopMonitor(){
//        monitorTimer.invalidate()
//        showComment()
//
//    }
    
    // MARK: - Comment
    
//    func showComment(){
//
//        let commentVC : CommentViewController = storyboard!.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
//
//
//        commentVC.delegate = self
//        commentVC.view.alpha = 0
//        self.view.addSubview(commentVC.view)
//        self.addChildViewController(commentVC)
//        UIView.animate(withDuration: 1 ,animations : {
//            commentVC.view.alpha = 1
//        })
//    }
//
//    func closeComment() {
//
//        NSLog("closeComment")
//        let viewBack : UIView = view.subviews.last!
//        UIView.animate(withDuration: 0.3, animations: { () -> Void in
//            //        self.willMove(toParentViewController: nil)
//            var frameMenu : CGRect = viewBack.frame
//            frameMenu.origin.y = 2 * UIScreen.main.bounds.size.height
//            viewBack.frame = frameMenu
//
//            viewBack.layoutIfNeeded()
//            viewBack.backgroundColor = UIColor.clear
//            //        self.removeFromParentViewController()
//        }, completion: { (finished) -> Void in
//            viewBack.removeFromSuperview()
//        })
//
//        self.viewDidDisappear(false)
//        self.loadView()
//        self.viewWillAppear(true)
//        self.viewDidLoad()
//    }
//
//    func getTimer() -> Int{
//        return monitorCounter
//    }
    
    // MARK: - LocationManager
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//
//        // singleton
//        PASingleton.sharedInstance().setLocation(location: locValue)
//
//        if (!isMapInit){
//            initMap()
//            isMapInit = true
//        }
//
//    }
    
    // START
    // V2 沒用到這個func
    //
    //    private func configureMyCircleProgress(){
    //
    //
    //        myCircleProgress = KYCircularProgress(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), showGuide: true)
    //
    //        let lineWidth = 15.0
    //        if(self.uiview_mapView != nil){
    //            myCircleProgress.path = UIBezierPath(arcCenter: self.uiview_mapView.center, radius: self.uiview_mapView.frame.width / 2, startAngle: CGFloat(Double.pi)*1.5, endAngle: CGFloat(Double.pi)*3.5, clockwise: true)
    //        }
    //        myCircleProgress.lineWidth = lineWidth
    //        myCircleProgress.guideLineWidth = lineWidth
    //        myCircleProgress.guideColor = UIColor(rgba: 0xF6F6F6FF)
    //        myCircleProgress.colors = [UIColor(rgba: 0x28FF28AA), UIColor(rgba: 0x0080FFAA), UIColor(rgba: 0xFF77FFAA), UIColor(rgba: 0xFF5151AA)]
    //
    //        if(self.uiview_mapView != nil){
    //            background_circle.frame = CGRect( x:0, y:0, width: uiview_mapView.frame.width, height: uiview_mapView.frame.height )
    //            background_circle.center = uiview_mapView.center
    //            background_circle.backgroundColor = UIColor(rgba: 0xF6F6F6FF)
    //            background_circle.layer.cornerRadius = uiview_mapView.frame.width
    //            myCircleProgress.addSubview(background_circle)
    //
    //        lbl_progress = UILabel(frame: CGRect(x: (self.uiview_mapView.frame.width - config.getSize(key: "lbl_progress_width")) / 2 , y: (uiview_mapView.frame.height - config.getSize(key: "lbl_progress_height")) / 2 , width: config.getSize(key: "lbl_progress_width"), height: config.getSize(key: "lbl_progress_height")))
    //        lbl_progress.font = UIFont(name: "HelveticaNeue", size: config.getSize(key: "lbl_progress_size"))
    //        lbl_progress.textAlignment = .center
    //        lbl_progress.textColor = UIColor(rgba: 0x5AC8FAFF)
    //        uiview_mapView.addSubview(lbl_progress)
    //        }
    //        myCircleProgress.progressChanged {
    //            (progress: Double, circularProgress: KYCircularProgress) in
    ////            print("progress: \(progress)")
    //            self.lbl_progress.text = "\(Int(progress * 100.0))"
    //        }
    //        if(self.uiview_mapView != nil){
    //            view.insertSubview(myCircleProgress, belowSubview: self.uiview_mapView)
    //        }
    //    }
    //
    // V2 沒用到這個func
    // END
    
    
    
}






