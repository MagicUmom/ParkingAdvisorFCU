//
//  ServerCommunicator.swift
//  ParkingAdvisor
//
//  Created by MCLAB on 2017/9/18.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import Foundation
//import AFNetworking

class ServerCommunicator {
    // MARK: API defined
    //  發出GPS 回傳路名
    let GET_ROADNAME = "https://mclab.iecs.fcu.edu.tw/getRoad.php"
    //  發出GPS 回傳附近的路名、經緯度、分數
    let GET_SCORE = "https://mclab.iecs.fcu.edu.tw/getNearbyRoads.php"
    
    // MARK: init func
    private var _serverCommunicator: ServerCommunicator?
    
    func sharedInstance() -> ServerCommunicator {
        
        if _serverCommunicator == nil {
            
            _serverCommunicator = ServerCommunicator()
        }
        
        return _serverCommunicator!
    }
    
    
    // MARK: 共用POST方法 public post function
    private func toPost(API:String, data:Dictionary<String,String>, doneHandler: @escaping(_ error:Error?, _ result: Any?) -> Void) {
        
//        let manager = AFHTTPSessionManager()
        
//        do {
//            
//            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//            
//            var request = URLRequest(url: URL(string: API)!)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("application/json", forHTTPHeaderField: "Accept")
//            request.httpBody = jsonData
//            request.timeoutInterval = 10.0
//            let task = manager.dataTask(with: request, completionHandler: { (response, result, error) in
//                
//                if error != nil {
//                    doneHandler(error, nil)
//                    return
//                }
//                
//                doneHandler(nil,result)
//                
//            })
//            
//            task.resume()
//            
//        }catch {
//            
//            print("Convert to data error : \(error)")
//            
//        }
    }
    
}
