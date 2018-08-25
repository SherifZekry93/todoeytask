//
//  NotificationTableViewController.swift
//  todoeytask
//
//  Created by Sherif  Wagih on 8/25/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: "SendNotification")
    }
    @IBAction func onOffValueChanged(_ sender: UISwitch)
    {
        if sender.isOn
        {
            LocalPushManager.shared.sendLocalPush(in: 60)
        }
        else
        {
             LocalPushManager.shared.center.removePendingNotificationRequests(withIdentifiers: ["ToDoNotification"])
        }
        UserDefaults.standard.setValue(sender.isOn, forKey: "SendNotification")
    }
    @IBOutlet weak var notificationSwitch: UISwitch!
    
}
