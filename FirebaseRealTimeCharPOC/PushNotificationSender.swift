//
//  sendNotification.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 26/08/21.
//

import Foundation


import UIKit
class PushNotificationSender {
    static var instance = PushNotificationSender()
    var dic = [String: Any]()
    
    func sendPushNotification(to token: String, title: String, body: String ,data: Message) {//dMhpE3dtv2j0YyEpJTYN0P:APA91bEg2uJ3VIBg8f8PGWmNiLZzaERxmZoTnSsi7cF0RV6py6XwEu3nRdruI_yOix5G0dYv4-nAjrjNRa70dixiTki2cPFueFZSml9X6cTxZ0ONJ_5QytcCAHZbHwTwieB4fZxWJB2W
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        self.dic = ["imageUrl":(data.downloadURL?.absoluteString ?? ""),"messageType:": (data.mediaType ?? "") as String,"messageId":data.messageId,"content":data.content]
        
        let sendMessageBody = self.dicToJson(data: [self.dic])
        let paramString: [String : Any] = ["to" : "dMhpE3dtv2j0YyEpJTYN0P:APA91bEg2uJ3VIBg8f8PGWmNiLZzaERxmZoTnSsi7cF0RV6py6XwEu3nRdruI_yOix5G0dYv4-nAjrjNRa70dixiTki2cPFueFZSml9X6cTxZ0ONJ_5QytcCAHZbHwTwieB4fZxWJB2W",
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : sendMessageBody]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAjVebzyY:APA91bFiaCmoU8rf04WA0FZagVoNACO4D3EvE15C7Mizico0p2hPtEdkmdC0OiiUHFqyj74E4K65CWUOUWuGQXYBkW-WIdaB-uLuVO0pEFjw5DlNr-3CjriKRSP-2jBLF4nVpMf9Zn5v", forHTTPHeaderField: "Authorization")   //secret key of firebase
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func dicToJson(data:[[String : Any]]) -> String{
           var str = String()
           var myData = [String:Any]()
           myData["userIn"] = data
           let jsonData = try? JSONSerialization.data(withJSONObject: myData, options: .prettyPrinted)
           let decoded = try? JSONSerialization.jsonObject(with: jsonData!, options: [])
           if let dictFromJSON = decoded as? [String:AnyObject] {
               print(dictFromJSON)
               let vv = dictFromJSON["userIn"]
               let jsonData1 = try! JSONSerialization.data(withJSONObject: vv as Any, options: [])
               let decoded1 = String(data: jsonData1, encoding: .utf8)!
               str = decoded1
           }
           return str
       }
}


