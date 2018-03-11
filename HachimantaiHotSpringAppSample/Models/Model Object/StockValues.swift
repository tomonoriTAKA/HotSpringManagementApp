//
//  StockValues.swift
//  HachimantaiHotSpringAppSample
//
//  Created by 高橋知憲 on 2018/01/04.
//  Copyright © 2018年 高橋知憲. All rights reserved.
//

import UIKit
import Alamofire

class StockValues: NSObject {
    
    class func postValue(value: ValuesMemo) {
        let params: [String:Any] = [
            "values": value.values
        ]
        
        Alamofire.request("http://localhost:3000/api/memos", method: HTTPMethod.post, parameters: params)
    
    }
    

}
