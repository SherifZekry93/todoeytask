//
//  Notification.swift
//  todoeytask
//
//  Created by Sherif  Wagih on 8/25/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import Foundation
import UserNotifications
class LocalPushManager: NSObject {
    static var shared = LocalPushManager()
    let center = UNUserNotificationCenter.current()
    func requestAuth()
    {
        center.requestAuthorization(options: [.alert,.sound]) { (granted, error) in
            if error == nil && granted
            {
                UserDefaults.standard.setValue(true, forKey: "SendNotification")
                LocalPushManager.shared.sendLocalPush(in: 60 * 120)
            }
        }
    }
    //Set up local push with ios os
    func sendLocalPush(in time:TimeInterval)
    {
        //create local push content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "WASSUP!!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "It's time for you to do what you should do!!", arguments: nil)
        //trigger push notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: true)
        let request = UNNotificationRequest(identifier: "ToDoNotification", content: content, trigger: trigger)
        center.add(request) { (error) in
            if error == nil
            {
                print("Schedule push succeed")
            }
        }
    }
}
