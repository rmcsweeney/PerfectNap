//
//  AppDelegate.swift
//  PerfectNap
//
//  Created by Ryan McSweeney on 1/22/23.
//

import Foundation
import SwiftUI
import UserNotifications
//TODO: implement handling automatically
class NotificationHandler {
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                didReceive response: UNNotificationResponse,
                withCompletionHandler completionHandler:
                   @escaping () -> Void) {
        
        if (response.notification.request.content.categoryIdentifier == "ALARM_ACTION"){
                
            //handleAlarm(response)
        }
        else {
            // Handle Sleep Checking
            switch response.actionIdentifier {
                case UNNotificationDefaultActionIdentifier, UNNotificationDismissActionIdentifier:
                //    notifyCheckSleeping()
                    break
                default:
                    break
            }
            
        }
            
       // Always call the completion handler when done.
       completionHandler()
    }
}
