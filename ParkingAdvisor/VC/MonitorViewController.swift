//
//  MonitorViewController.swift
//  ParkingAdvisor
//
//  Created by MCLAB on 2017/6/29.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import UIKit
import GoogleMaps

class MonitorViewController: UIViewController,CLLocationManagerDelegate,UIScrollViewDelegate,GMSMapViewDelegate ,CircleBarProtocol{
    
    
    var circleVC : CircleBarViewController! = nil
    
    
    
//    預設未監控狀態
    private var isStart : Bool = false
    var isMapInit : Bool = false
    var isSpreadOut : Bool = true
    var isDescribeViewShow : Bool = false
    var DescribeView : UITextView?
    var isMonitor : Bool = false
    
    
    private var monitorTimer = Timer()
    private var monitorCounter : Int = 0
    
    // scroll view
    var myScrollView: UIScrollView!
    var pageControl: UIPageControl!
    var myImageView : UIImageView!
    
    // 取得螢幕的尺寸
    var fullSize :CGSize! = CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 140 - (UIScreen.main.bounds.size.height * 0.13) )
    
    
    // uiview_title
    @IBOutlet weak var uiview_proccessing: UIView!
    @IBOutlet weak var uiview_address: UIView!
    @IBOutlet weak var lbl_proccessing: UILabel!
    @IBOutlet weak var lbl_address: UILabel!
    
    // uiimgview_numbers
    @IBOutlet weak var uiimgview_min: UIImageView!
    @IBOutlet weak var uiimgview_sec: UIImageView!
    @IBOutlet weak var uiimgview_min_ten: UIImageView!
    @IBOutlet weak var uiimgview_min_one: UIImageView!
    @IBOutlet weak var uiimgview_sec_ten: UIImageView!
    @IBOutlet weak var uiimgview_sec_one: UIImageView!
    @IBOutlet weak var uiimgview_green_ten: UIImageView!
    @IBOutlet weak var uiimgview_green_one: UIImageView!
    
    
    //  map view
    let locationManager = CLLocationManager()
    var mapView : GMSMapView!
    var blurEffectView : UIVisualEffectView!
    
    @IBOutlet weak var uiview_mapView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNumbersAlpha(alpha: 0)
        initMap()
        blurInit()
        // Do any additional setup after loading the view.
    }
    override func loadView() {
        super.loadView()
        print("monitor view load")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if(!self.isSpreadOut){
            tabBarController?.tabBar.isHidden = false
        }else{
            tabBarController?.tabBar.isHidden = true
        }
        
        print("monitor view will Appear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MAP
    
    func initMap() {
        
        lbl_proccessing.text = "停車監控"
        lbl_proccessing.alpha = 1
        lbl_address.text = PASingleton.sharedInstance().getAddress()
        self.lbl_address.sizeToFit()
        self.lbl_address.center.x = UIScreen.main.bounds.width / 2

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
            
            uiview_mapView.insertSubview(mapView, at: 0)
            isMapInit = true
            CATransaction.begin()
            CATransaction.setValue(1, forKey: kCATransactionAnimationDuration)
            mapView.animate(toZoom: 19.0)
            CATransaction.commit()
            
            
            if(self.spreadOut()){
                self.circleVC?.editCircleBarTitle(titleIndex : 3)
                self.circleVC?.setCircleTitleClickable(isClickable: true)
                self.circleVC?.hightLightBTNIcon(index: 1)
                print("spreadOuted")
                self.tabBarController?.tabBar.isHidden = true
                
            }
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
    
    func setNumbersAlpha(alpha : CGFloat){
        uiimgview_min.alpha = alpha
        uiimgview_sec.alpha = alpha
        uiimgview_min_ten.alpha = alpha
        uiimgview_min_one.alpha = alpha
        uiimgview_sec_ten.alpha = alpha
        uiimgview_sec_one.alpha = alpha
        uiimgview_green_ten.alpha = alpha
        uiimgview_green_one.alpha = alpha
        
    }
    
    // MARK: Monitor
    
    
    func upgradeMonitorTimer(){
        
        monitorCounter = monitorCounter + 1
        //        self.lbl_progress.text = String(format: "%.2d:%.2d", monitorCounter / 60, monitorCounter % 60)
        self.uiimgview_min_ten.image = UIImage(named: "LG_\(monitorCounter / 60000)")
        self.uiimgview_min_one.image = UIImage(named: "LG_\(monitorCounter / 6000 % 10)")
        self.uiimgview_sec_ten.image = UIImage(named: "DG_b_\(monitorCounter / 100 % 60 / 10)")
        self.uiimgview_sec_one.image = UIImage(named: "DG_b_\(monitorCounter / 100 % 60 % 10)")
        self.uiimgview_green_ten.image = UIImage(named: "green_\(monitorCounter % 100 / 10)")
        self.uiimgview_green_one.image = UIImage(named: "green_\(monitorCounter % 10)")
        
    }
    
    func startMonitor(){
        print("start Monitor")
        PASingleton.sharedInstance().setIsMonitor(IsMonitor: true)
        if(self.isMonitor == false){
            self.isMonitor = true
            self.uiview_mapView.insertSubview(blurEffectView, aboveSubview: mapView)
            
            UIView.animate(withDuration: 0.8, animations: {
                self.blurEffectView.alpha = 1
                
            }, completion: {_ in
                self.setNumbersAlpha(alpha: 1)
                self.circleVC?.editCircleBarTitle(titleIndex: 4)
                self.monitorTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(MonitorViewController.upgradeMonitorTimer), userInfo: nil, repeats: true)
                
            })
        }else{
            self.stopMonitor()
            self.isMonitor = false
        }
        
    }
    
    func stopMonitor(){
        PASingleton.sharedInstance().setIsMonitor(IsMonitor: false)
        monitorTimer.invalidate()
        self.shrinkIn()
        self.isSpreadOut = false
        
        self.showScrollView()
    }
    
    // MARK: - TAB_BAR Protocol
    func TitleAction(State : Int){
        print("\(State)")
        print("\(self.isMonitor)")
        switch State {
        case 3 :
            self.startMonitor()
            let colors = [ UIColor(rgba: 0x42cb6fff).cgColor,UIColor(rgba: 0x3ab75cff).cgColor ]
            CATransaction.begin()
            let locations = [0, 0.5, 1]
            self.circleVC.LightAnimation(colors: colors, locations: locations)
            
            return
        case 4 :
            self.circleVC.uiview_background.layer.removeAllAnimations()
            CATransaction.commit()
            self.stopMonitor()
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
        PASingleton.sharedInstance().setIsSpreaded(isSpreaded: true)
        
        self.isSpreadOut = true
        
        return true
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
            self.isSpreadOut = false
            return true
        }
        return false
    }
    
    // MARK: - UIScroll View Delegate
    
    // 建立 Scroll View
    func showScrollView(){
        self.lbl_proccessing.text = "您滿意這次"
        self.lbl_address.text = "停車服務嗎"
        
        self.lbl_proccessing.sizeToFit()
        self.lbl_proccessing.center.x = UIScreen.main.bounds.width / 2
        
        self.lbl_address.sizeToFit()
        self.lbl_address.center.x = UIScreen.main.bounds.width / 2
        
        // 建立 UIScrollView
        myScrollView = UIScrollView()
        
        // 設置尺寸 也就是可見視圖範圍
//        myScrollView.frame = CGRect(x: 0, y: 140, width: fullSize.width, height: UIScreen.main.bounds.height - (tabBarController?.tabBar.frame.size.height)! - 140 )
        myScrollView.frame = CGRect(x: 0, y: 140, width: fullSize.width, height: fullSize.height )
        
        // 實際視圖範圍
        myScrollView.contentSize = CGSize(width: fullSize.width * 3, height: fullSize.height)
        
        myScrollView.backgroundColor = UIColor.white
        // 是否顯示滑動條
        myScrollView.showsHorizontalScrollIndicator = false
        myScrollView.showsVerticalScrollIndicator = false
        
        // 滑動超過範圍時是否使用彈回效果
        myScrollView.bounces = true
        
        // 設置委任對象
        myScrollView.delegate = self
        
        // 以一頁為單位滑動
        myScrollView.isPagingEnabled = true
        
        // 加入到畫面中
        self.view.addSubview(myScrollView)
        
        
        // 建立 UIPageControl 設置位置及尺寸
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: fullSize.width * 0.85, height: 50))
        pageControl.center = CGPoint(x: fullSize.width * 0.5, y: fullSize.height + 100 )
        
        // 有幾頁 就是有幾個點點
        pageControl.numberOfPages = 3
        
        // 起始預設的頁數
        pageControl.currentPage = 0
        
        // 目前所在頁數的點點顏色
        pageControl.currentPageIndicatorTintColor = UIColor.black
        
        // 其餘頁數的點點顏色
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        
        // 增加一個值改變時的事件
        pageControl.addTarget(self, action: #selector(TestSecondViewController.pageChanged), for: .valueChanged)
        
        // 加入到基底的視圖中 (不是加到 UIScrollView 裡)
        // 因為比較後面加入 所以會蓋在 UIScrollView 上面
        self.view.addSubview(pageControl)
        
        
        // 建立 5 個 UILabel 來顯示每個頁面內容
//        var myImageView = UIImageView()
        var myImage = UIImage()
        myImage = UIImage(named: "report_face")!
        myImageView = UIImageView(image: myImage)
        myImageView.frame = CGRect(x:0, y:0 , width: fullSize.width * 3 ,height : 300)
        myImageView.center = CGPoint(x: fullSize.width * 1.5, y: 140 + fullSize.height * 0.2)
        myScrollView.addSubview(myImageView)
        
//        var myLabel = UILabel()
//        for i in 0...2 {
//            myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: fullSize.width, height: 40))
//            myLabel.center = CGPoint(x: fullSize.width * (0.5 + CGFloat(i)), y: fullSize.height * 0.2)
//            myLabel.font = UIFont(name: "Helvetica-Light", size: 48.0)
//            myLabel.textAlignment = .center
//            myLabel.text = "\(i + 1)"
        
//            myImageView.center = CGPoint(x: fullSize.width * (0.5 + CGFloat(i)), y: fullSize.height * 0.2)
            
//            var tempView = UIImageView()
//            tempView = myImageView
//            print("\(tempView.center)")
//            print("\(tempView.frame.width)")
//            print("\(tempView.frame.height)")
//            myScrollView.addSubview(myLabel)
//            myScrollView.addSubview(tempView)
//        }
        
        self.view.bringSubview(toFront: pageControl)
        
        let button = UIButton(frame: CGRect(x: 0, y: 140, width: 414, height: 300))
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
        
    }
    
    // 滑動結束時
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 左右滑動到新頁時 更新 UIPageControl 顯示的頁數
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = page
    }
    
    // 點擊點點換頁
    func pageChanged(_ sender: UIPageControl) {
        // 依照目前圓點在的頁數算出位置
        var frame = myScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
        frame.origin.y = 0
        
        // 再將 UIScrollView 滑動到該點
        myScrollView.scrollRectToVisible(frame, animated:true)
    }
    
    
    // MARK: - Button
    func buttonAction(){
        print("action")
        myScrollView.removeFromSuperview()
        myImageView.removeFromSuperview()
        pageControl.removeFromSuperview()
        
        self.viewDidLoad()
        setNumbersAlpha(alpha: 1)
        self.uiimgview_min_ten.image = UIImage(named: "LG_0")
        self.uiimgview_min_one.image = UIImage(named: "LG_0")
        self.uiimgview_sec_ten.image = UIImage(named: "DG_b_0")
        self.uiimgview_sec_one.image = UIImage(named: "DG_b_0")
        self.uiimgview_green_ten.image = UIImage(named: "green_0")
        self.uiimgview_green_one.image = UIImage(named: "green_0")
        self.circleVC?.editCircleBarTitle(titleIndex : 3)
        self.isMonitor = false
        monitorCounter = 0
    }
    // MARK: - Comment
    
    
}
