//
//  TestViewController.swift
//  ParkingAdvisor
//
//  Created by MCLAB on 2017/5/11.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class TestViewController: UIViewController {

    @IBOutlet weak var uiview_background: UIView!
    @IBOutlet weak var img_tick: UIImageView!
    
    let  requestIdentifier = "SampleRequest" //identifier is to cancel the notification request
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBackground()
//        kAnimate()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_action1(_ sender: Any) {
        
//        動畫 1 開始
//        let path = UIBezierPath(rect: CGRect(x:0,y:0,width:0,height:img_tick.frame.height))
//        let newPath = UIBezierPath(rect: img_tick.bounds)
//
//        let layer = CAShapeLayer()
//        layer.frame = img_tick.bounds
//        layer.path = path.cgPath
//
//        img_tick.layer.mask = layer
//
//        let anim = CABasicAnimation(keyPath : "path")
//        anim.fromValue = layer.path
//        anim.toValue  = newPath.cgPath
//        anim.duration = 3.0
//        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//
//        layer.add(anim, forKey: nil)
//
//        layer.path = newPath.cgPath
//        img_tick.layer.mask = layer
//        動畫 1 結束
        
        
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
    
    @IBAction func btn_action2(_ sender: Any) {
        
//        動畫 2 開始
//        let gl = CAGradientLayer()
//        gl.frame = self.uiview_background.bounds
//        gl.colors = [ UIColor(rgba: 0x00a0dfff).cgColor,UIColor(rgba: 0x232288ff).cgColor,UIColor(rgba: 0xe3007eff).cgColor,UIColor(rgba: 0xe51f1fff).cgColor,UIColor(rgba: 0xfeed00ff).cgColor,UIColor(rgba: 0x00974bff).cgColor  ]
//        //        gl.colors = [UIColor.red.cgColor , UIColor.blue.cgColor]
//        gl.startPoint = CGPoint(x:0, y:0.5)
//        gl.endPoint = CGPoint(x:1, y:0.5)
//
//        self.uiview_background.layer.addSublayer(gl)
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [UIColor.white.withAlphaComponent(0.0).cgColor, UIColor.white.withAlphaComponent(0.1).cgColor, UIColor.white.withAlphaComponent(0.2).cgColor,UIColor.white.withAlphaComponent(0.3).cgColor, UIColor.white.cgColor]
//        gradientLayer.frame = self.uiview_background.bounds;
//        gradientLayer.locations = [0, 0.15, 0.25, 0.5, 1]
//        gradientLayer.startPoint = CGPoint(x:0.5, y:0)
//        gradientLayer.endPoint = CGPoint(x:0.5, y:1)
//        gl.mask = gradientLayer
//
//        let finalSize = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.3)
//        let layerHeight = finalSize.height * 0.5
//        let layer = CAShapeLayer()
//        let bezier = UIBezierPath()
//        let newPath = UIBezierPath()
//        let aniHeight = finalSize.height * 0.1
//
//        bezier.move(to: CGPoint( x: 0 , y: finalSize.height - layerHeight))
//        bezier.addLine(to: CGPoint( x: 0, y: finalSize.height - 1))
//        bezier.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - 1))
//        bezier.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - layerHeight))
//        bezier.addQuadCurve(to: CGPoint( x: 0, y: finalSize.height - layerHeight), controlPoint: CGPoint(x: finalSize.width / 2, y: -50 ))
//
//        newPath.move(to: CGPoint( x: 0 , y: finalSize.height - layerHeight - aniHeight))
//        newPath.addLine(to: CGPoint( x: 0, y: finalSize.height - 1))
//        newPath.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - 1))
//        newPath.addLine(to: CGPoint( x: finalSize.width, y: finalSize.height - layerHeight - aniHeight))
//        newPath.addQuadCurve(to: CGPoint( x: 0, y: finalSize.height - layerHeight - aniHeight), controlPoint: CGPoint(x: finalSize.width / 2, y: -50 - aniHeight))
//
//        layer.path = bezier.cgPath
//        layer.frame = self.view.bounds
//        self.uiview_background.layer.mask = layer
//
//        let anim = CABasicAnimation(keyPath : "path")
//        anim.fromValue = layer.path
//        anim.toValue  = newPath.cgPath
//        anim.duration = 1.0
//        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//        anim.repeatCount = .infinity
//
//        layer.add(anim, forKey: nil)
//
//        layer.path = newPath.cgPath
//        self.uiview_background.layer.mask = layer
//        動畫 2 結束
        
        print("Removed all pending notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
        
    }
    func spreadOut(){
//        if(PASingleton.sharedInstance().getIsSpreaded())
//        {
            self.tabBarController?.tabBar.isHidden = true
            let CircleBar: CircleBarViewController = storyboard!.instantiateViewController(withIdentifier: "CircleBarViewController") as! CircleBarViewController
//            CircleBar.delegate = self as? SpreadProtocol
            self.view.addSubview(CircleBar.view)
            self.addChildViewController(CircleBar)
            CircleBar.view.frame.origin.y = self.view.bounds.height * 0.72
        
//        }
        
    }
    
    func shrinkIn(){
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
        self.tabBarController?.tabBar.isHidden = false
        
        print("myfun")
    }
    
    func kAnimate(){
        view.backgroundColor = .black
        
        let containerView = UIView()
        containerView.bounds = CGRect(x: 0, y: 300, width: 300, height: 80)
        containerView.center = view.center
        view.addSubview(containerView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containerView.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.white.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.25, 0.5, 0.75]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        containerView.layer.addSublayer(gradientLayer)
        
        gradientLayer.add(animation(), forKey: "LocationAnimation")
        
    }
    
    private func animation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.0, 0.25]
        animation.toValue = [0.75, 1.0, 1.0]
        animation.duration = 3.0
        animation.repeatCount = Float.infinity
        return animation
    }
    
    func initBackground(){
        
        
//        let finalSize = CGRect(x: 0, y: self.view.bounds.height * 0.9, width: self.view.bounds.width, height: self.view.bounds.height * 0.1)
//        let layerHeight = finalSize.height * 1.3
//        let layer = CAShapeLayer()
//        let bezier = UIBezierPath()
//        
//        bezier.move(to: CGPoint( x: 0 , y: finalSize.origin.y ))
//        bezier.addLine(to: CGPoint( x: 0, y: finalSize.origin.y + finalSize.height))
//        bezier.addLine(to: CGPoint( x: finalSize.width, y: finalSize.origin.y + finalSize.height))
//        bezier.addLine(to: CGPoint( x: finalSize.width, y: finalSize.origin.y))
//        bezier.addQuadCurve(to: CGPoint( x: 0, y: finalSize.origin.y), controlPoint: CGPoint(x: finalSize.width / 2, y: finalSize.origin.y - layerHeight ))
//        
//        
//        layer.path = bezier.cgPath
//        layer.fillColor = UIColor(rgba: 0xf2f2f2ff).cgColor
//        
//        
//        
//        self.view.layer.insertSublayer(layer, at: 0)
//        
//        let gl = CAGradientLayer()
//        gl.frame = self.view.bounds
//        gl.colors = [ UIColor(rgba: 0x00a0dfff).cgColor,UIColor(rgba: 0x232288ff).cgColor,UIColor(rgba: 0xe3007eff).cgColor,UIColor(rgba: 0xe51f1fff).cgColor,UIColor(rgba: 0xfeed00ff).cgColor,UIColor(rgba: 0x00974bff).cgColor  ]
//        //        gl.colors = [UIColor.red.cgColor , UIColor.blue.cgColor]
//        gl.startPoint = CGPoint(x:0, y:0.5)
//        gl.endPoint = CGPoint(x:1, y:0.5)
//        
//        //       self.view.layer.addSublayer(gl)
//        self.view.layer.addSublayer(gl)
//        gl.mask = layer
        
    }
    
}

extension TestViewController:UNUserNotificationCenterDelegate{
    
    
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

