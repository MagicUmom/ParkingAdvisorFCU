//
//  PAConfig.swift
//  ParkingAdvisor
//
//  Created by MCLAB on 2017/9/6.
//  Copyright © 2017年 MCLAB. All rights reserved.
//

import Foundation
import UIKit


class sizeConfig{
    
    let ipad_size = [
        "map_offset" : 250,
        "lbl_progress_size" : 250,
        // 中文評語size
        "lbl_progress_chinese_size" : 120 ,
        "lbl_progress_height" : 380,
        "lbl_progress_width" : 400,
        "lbl_location_after_animation_y": 155 + 28,
        // lbl_location_after_animation_y (y + height) + offset
        "lbl_address_after_animation_y": 213 + 28
        
    ]
    
    let iphone_size = [
        "map_offset" : 102,
        "lbl_progress_size" : 135,
        // 中文評語size
        "lbl_progress_chinese_size" : 80 ,
        "lbl_progress_height" : 180,
        "lbl_progress_width" : 250,
        "lbl_location_after_animation_y": 113,
        // lbl_location_after_animation_y (y + height) + offset
        "lbl_address_after_animation_y": 139
    ]
    init(){
        return
    }
    
    func getSize(key : String) -> CGFloat{
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return CGFloat(iphone_size[key]!)
        case .pad:
            return CGFloat(ipad_size[key]!)
        case .tv:
            print("error tv size")
        case .carPlay:
            print("error carPlay size")
        case .unspecified:
            print("error size")
            // Uh, oh! What could it be?
            
        }
        print("#ERROR No this SIZE")
        return CGFloat(0)
    }
    
}

