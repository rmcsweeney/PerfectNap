//
//  ContentView.swift
//  PerfectNap
//
//  Created by Ryan McSweeney on 1/18/23.
//  Sources used:
//  For notifications https://stackoverflow.com/questions/68191982/swiftui-ask-notification-permission-on-start-without-button
//  https://developer.apple.com/documentation/usernotifications/declaring_your_actionable_notification_types

import SwiftUI
import NotificationCenter

let DEBUG = true

let snoozeAction = UNNotificationAction(identifier: "SNOOZE", title: "Snooze", options: [])
let turnOffAction = UNNotificationAction(identifier: "ALARM_OFF", title: "Turn Off", options: [])
let alarmCategory = UNNotificationCategory(identifier: "ALARM_ACTION", actions: [snoozeAction, turnOffAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)

let sleepContent = UNMutableNotificationContent()
let wakeContent = UNMutableNotificationContent()


struct ContentView: View {
    
    let center = UNUserNotificationCenter.current()
    

    
    
    //Set timer interval "every" and tolerance (tolerance at 1/10 good for preserving device power)
    let timer  = Timer.publish(every: 3, tolerance: 3, on: .main, in: .common).autoconnect()
    let every = 5 //every as minutes
    
    let fallAsleepReload = 5
    //State variables for hours/minutes on UI and determined falling asleep check timer
    @State private var hours = 0
    @State private var minutes = 0
    @State private var fallAsleepTime = 0
    @State private var alarmTime = 0
    
    @State private var currentNotif: String? = nil
    
    //unimplemented
    @State private var authorized = true
    
    enum userState {
        case idle
        case fallingAsleep
        case asleep
        case wakeUp
    }
    
    @State private var userStatus = userState.idle
    
    func requestNotifications() {
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
            if let error = error{
                print("Error in authorization: " + error.localizedDescription)
            }
            if (!granted){
                print("Access not granted.")
            }
            else{
                print("Access allowed")
            }
        })
        
        center.setNotificationCategories([alarmCategory])
        
        sleepContent.title = "Still awake?"
        sleepContent.body = "Tap here"
        sleepContent.sound = UNNotificationSound.default
        sleepContent.categoryIdentifier = "ALARM_ACTION"
        
        wakeContent.title = "Wake up!"
        wakeContent.body = "Alarm running"
        wakeContent.sound = UNNotificationSound.defaultRingtone
        
    }
        
    var body: some View {
        ZStack{
            VStack{
                Text("Sleep Better")
                    .padding()
                        .font(.title)
                Text("Enter desired nap time")
                    .font(.subheadline)
                HStack{
                    Picker("Hours", selection: $hours){
                        ForEach((0 ..< 10), id:\.self) {
                            Text("\($0) hour(s)")
                            
                        }
                    }.padding()
                        .disabled(!(userStatus==userState.idle))
                    Picker("Minutes", selection: $minutes){
                        ForEach(Array(stride(from: 0, to: 59, by: 5)), id:\.self) {
                            Text("\($0) minute(s)")
                        }
                    }.padding()
                        .disabled(!(userStatus==userState.idle))
                }.pickerStyle(.menu)
                Button(action: beginSleep){
                    Text("Press to start nap process")
                }.padding()
                    .buttonStyle(.bordered)
                    .shadow(radius: 5)
                    .disabled(!(userStatus==userState.idle))
                Button(action: resetSleep){
                    Text("Cancel sleep process")
                }.opacity(userStatus==userState.fallingAsleep ? 0:1)
                    .disabled(!(userStatus==userState.fallingAsleep))
                Text("Notifications not authorized!")
                    .opacity(authorized ? 0:1)
            }.padding()
            
            if (DEBUG){
                HStack{
                    Button(action: notifyCheckSleeping){
                        Text("Test sleepcheck")
                    }
                }
            }
        }
    }
    
    func beginSleep(){
        requestNotifications()
        fallAsleepTime = fallAsleepReload
        userStatus = userState.fallingAsleep
    }
    
    func resetSleep(){
        userStatus = userState.idle
    }
    
    func timerHandler(){
        switch userStatus {
        case .idle:
            userStatus = userState.idle
        case .fallingAsleep:
            if (fallAsleepTime > 0){
                fallAsleepTime -= every
            }
            else{
                notifyCheckSleeping()
            }
        case .asleep:
            if (alarmTime > 0){
                alarmTime -= every
            }
            else{
                notifyWakeUp()
                userStatus = userState.wakeUp
            }
        case .wakeUp:
            notifyWakeUp()
        }
    }
    
    
    func notifyCheckSleeping(){
        let sleepRequest = UNNotificationRequest(identifier: UUID().uuidString, content: sleepContent, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
        UNUserNotificationCenter.current().add(sleepRequest)
    }
    
    func notifyWakeUp(){
        let wakeUpRequest = UNNotificationRequest(identifier: UUID().uuidString, content: wakeContent, trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * hours * 60), repeats: false))
        center.add(wakeUpRequest)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.none)
    }
}
