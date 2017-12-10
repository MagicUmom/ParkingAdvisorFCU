//
//  ServerCommunicator.swift
//  ParkingAdvisor
//
//  Created by MCLAB on 2017/9/18.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class ServerCommunicator {
    // MARK: API defined
    //  發出GPS 回傳路名
    let GET_ROADNAME = "https://mclab.iecs.fcu.edu.tw/getRoad.php"
    //  發出GPS 回傳附近的路名、經緯度、分數
    let GET_SCORE = "https://mclab.iecs.fcu.edu.tw/getNearbyRoads.php"
    
    private let BASE_API = "http://140.134.25.56/api"
    private let SEND_LOCATION = "GetPosition"
    
    // MARK: init func
    private static var _serverCommunicator: ServerCommunicator?

    static func shareInstance() -> ServerCommunicator {
        
        if _serverCommunicator == nil {
            
            _serverCommunicator = ServerCommunicator()
            
        }
        
        return _serverCommunicator!
        
    }

    func send_location(parameter: Dictionary <String, String>, done: @escaping(JSON)->Void ){
        let fullUrl = BASE_API + SEND_LOCATION
        post(url: fullUrl, parameter: parameter) { (json) in
            done(json)
        }

    }
    
    private func post(url: String, parameter: Dictionary <String, String> ,done: @escaping(JSON) -> Void) {
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.timeoutInterval = 10
            
            Alamofire.request(request).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    
                    let jsonData = JSON(value)
                    done(jsonData)
                    
                    break
                    
                case .failure(let error):
                    
                    print("error: \(error.localizedDescription)")
                    done(JSON.null)
                    
                    break
                }
                
            })
            
        } catch {
            
            print("Convert dictionary to data fail \n reson: \(error.localizedDescription) ")
            
        }
    }

}
