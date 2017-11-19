//
//  CircleBarViewController.swift
//  ParkingAdvisor
//
//  Created by WeiKang on 2017/9/5.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import UIKit

protocol CircleBarProtocol{
//    func SpreadOut()
//    func ShrinkIn()
//    func GetTitleAction() -> Int
    func TitleAction(State : Int)
}

class CircleBarViewController: UIViewController ,UITabBarControllerDelegate{
    
//    var dashboardView : UIViewController!
//    var monitorView : UIViewController!
//    var reportView : UIViewController!
//    var viewControllers : [UIViewController]!
//    var selectedItem : Int = 0
    
    @IBOutlet weak var lbl_tabTitle: UILabel!
    @IBOutlet weak var uiview_background: UIView!
    
    @IBOutlet weak var btn_tap_map: UIButton!
    @IBOutlet weak var btn_tap_monitor: UIButton!
    @IBOutlet weak var btn_tap_report: UIButton!
    
    
    var delegate : CircleBarProtocol?
    
    private var titleState : [String] = ["無狀態","開始分析","掃描中","開始","停止","開單中 | 拖吊中"]
    private var titleIndex : Int = 0
    /*
     0 : 無狀態
     1 : 開始分析
     2 : 掃描中
     3 : 開始監控
     4 : 停止監控
     5 : 開單中＆拖吊中
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(CircleBarViewController.lbl_tabTitle_be_Tap))
        self.lbl_tabTitle.addGestureRecognizer(tap)
        
        initBackground()
        // set background
//        UIGraphicsBeginImageContext(self.uiview_background.frame.size)
//        UIImage(named: "round_grey")?.draw(in: self.uiview_background.bounds)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        self.uiview_background.backgroundColor = UIColor(patternImage: image)
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        dashboardView = storyboard.instantiateViewController(withIdentifier: "Dashboard")
//        monitorView = storyboard.instantiateViewController(withIdentifier: "Monitor")
//        reportView = storyboard.instantiateViewController(withIdentifier: "Report")
//        viewControllers = [dashboardView,monitorView,reportView]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_tabItems(_ sender: Any) {
        assert((sender as AnyObject).tag >= 200 , "tag 要永遠大於 200 ")
        assert((sender as AnyObject).tag <= 203 , "tag 要小於等於最大tab值 , 203")
        if ( self.tabBarController?.selectedIndex != (sender as AnyObject).tag - 200){
            self.tabBarController?.selectedIndex = (sender as AnyObject).tag - 200
        }
    }
    
    
    func setCircleTitleClickable (isClickable : Bool){
        if (isClickable){
            self.lbl_tabTitle.isUserInteractionEnabled = true
            
        }else{
            self.lbl_tabTitle.isUserInteractionEnabled = false
        }
    }
    
    /*
     after lbl_tabTitle tapped call delegate TitleAction with index :titleIndex
     */
    
    func lbl_tabTitle_be_Tap(sender:UITapGestureRecognizer){
        print("lbl_tabtitle tapped")
        if(self.delegate != nil){
            delegate?.TitleAction(State: titleIndex)
        }else{
            print(" CircleBar Protocol delegate nil")
        }
    }
    
    func editCircleBarTitle(titleIndex : Int) {
        if(lbl_tabTitle != nil){
            self.titleIndex = titleIndex
            lbl_tabTitle.text = self.titleState[self.titleIndex]
            print("editing circle bar title")
        }
        else {
            print("lbl_tabTitle is nil")
        }
    }
    
    func initBackground(){
        let finalSize = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.3)
        let layerHeight = finalSize.height * 0.5
        let layer = CAShapeLayer()
        let bezier = UIBezierPath()
        
        bezier.move(to: CGPoint( x: 0 , y: finalSize.height - layerHeight))
        bezier.addLine(to: CGPoint( x: 0, y: finalSize.height - 1))
        bezier.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - 1))
        bezier.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - layerHeight))
        bezier.addQuadCurve(to: CGPoint( x: 0, y: finalSize.height - layerHeight), controlPoint: CGPoint(x: finalSize.width / 2, y: -50))
        
        
        layer.path = bezier.cgPath
        layer.fillColor = UIColor(rgba: 0xf2f2f2ff).cgColor
        
        uiview_background.layer.insertSublayer(layer, at: 0)
        
    }
    
    func hightLightBTNIcon(index: Int){
        switch index {
        case 0:
            self.btn_tap_map.setImage(UIImage(named: "tap_icon_scan"), for: .normal)
            self.btn_tap_monitor.setImage(UIImage(named: "tap_icon_monitor_g"), for: .normal)
            self.btn_tap_report.setImage(UIImage(named: "tap_icon_report_g"), for: .normal)
            return
        case 1:
            self.btn_tap_map.setImage(UIImage(named: "tap_icon_scan_g"), for: .normal)
            self.btn_tap_monitor.setImage(UIImage(named: "tap_icon_monitor"), for: .normal)
            self.btn_tap_report.setImage(UIImage(named: "tap_icon_report_g"), for: .normal)
            
            return
        case 2:
            self.btn_tap_map.setImage(UIImage(named: "tap_icon_scan_g"), for: .normal)
            self.btn_tap_monitor.setImage(UIImage(named: "tap_icon_monitor_g"), for: .normal)
            self.btn_tap_report.setImage(UIImage(named: "tap_icon_report"), for: .normal)
            
            return
        default:
            print("error #101")
        }
    }
    
    func LightAnimation(colors: [CGColor] , locations: [Double]){
        // 設定顏色 開始
        let gl = CAGradientLayer()
        gl.frame = self.uiview_background.bounds
        gl.colors = colors
        gl.startPoint = CGPoint(x:0, y:0.5)
        gl.endPoint = CGPoint(x:1, y:0.5)
        
        self.uiview_background.layer.insertSublayer(gl, at:0)
        // 設定顏色 結束
        
        // 設定上下的alpha 漸層
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0.1).cgColor, UIColor.white.withAlphaComponent(0.2).cgColor, UIColor.white.withAlphaComponent(0.3).cgColor,UIColor.white.withAlphaComponent(0.4).cgColor, UIColor.white.cgColor]
        gradientLayer.frame = self.uiview_background.bounds;
        gradientLayer.locations = locations as [NSNumber]
        gradientLayer.startPoint = CGPoint(x:0.5, y:0)
        gradientLayer.endPoint = CGPoint(x:0.5, y:1)
        gl.mask = gradientLayer
        // 設定上下的alpha 漸層end
        
        // 設定開始可視範圍
        let finalSize = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.3)
        let layerHeight = finalSize.height * 0.5
        let layer = CAShapeLayer()
        let bezier = UIBezierPath()
        let newPath = UIBezierPath()
        let aniHeight = finalSize.height * 0.1
        
        bezier.move(to: CGPoint( x: 0 , y: finalSize.height - layerHeight))
        bezier.addLine(to: CGPoint( x: 0, y: finalSize.height - 1))
        bezier.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - 1))
        bezier.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - layerHeight))
        bezier.addQuadCurve(to: CGPoint( x: 0, y: finalSize.height - layerHeight), controlPoint: CGPoint(x: finalSize.width / 2, y: -50 ))
        
        newPath.move(to: CGPoint( x: 0 , y: finalSize.height - layerHeight - aniHeight))
        newPath.addLine(to: CGPoint( x: 0, y: finalSize.height - 1))
        newPath.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - 1))
        newPath.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - layerHeight - aniHeight))
        newPath.addQuadCurve(to: CGPoint( x: 0, y: finalSize.height - layerHeight - aniHeight), controlPoint: CGPoint(x: finalSize.width / 2, y: -50 - aniHeight))
        
        layer.path = bezier.cgPath
        layer.frame = self.view.bounds
        self.uiview_background.layer.mask = layer
        
        let anim = CABasicAnimation(keyPath : "path")
        anim.fromValue = layer.path
        anim.toValue  = newPath.cgPath
        anim.duration = 1.0
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        anim.repeatCount = .infinity
        
        layer.add(anim, forKey: nil)
        
        layer.path = newPath.cgPath
        self.uiview_background.layer.mask = layer
        
    }
    
    /*
     // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
