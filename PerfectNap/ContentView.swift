//
//  ContentView.swift
//  PerfectNap
//
//  Created by Ryan McSweeney on 1/18/23.
//  Sources used:
//  For notifications https://stackoverflow.com/questions/68191982/swiftui-ask-notification-permission-on-start-without-button

import SwiftUI
import NotificationCenter

struct ContentView: View {
    let center = UNUserNotificationCenter.current()
    let sleepContent = UNMutableNotificationContent()
    let wakeContent = UNMutableNotificationContent()
    
    
    //Set timer interval "every" and tolerance (tolerance at 1/10 good for preserving device power)
    let timer  = Timer.publish(every: 300, tolerance: 30, on: .main, in: .common).autoconnect()
    let every = 5 //every as minutes
    
    let fallAsleepReload = 5
    //State variables for hours/minutes on UI and determined falling asleep check timer
    @State private var hours = 0
    @State private var minutes = 0
    @State private var fallAsleepTime = 0
    @State private var alarmTime = 0
    
    //unimplemented
    @State private var authorized = true
    
    enum userState {
        case idle
        case fallingAsleep
        case asleep
        case wakeUp
    }
    
    @State private var userStatus = userState.idle
    
    init() {
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
            if let error = error{
                print("Error in authorization: " + error.localizedDescription)
            }
            if (!granted){
                print("Access not granted.")
            }
        })
        
        sleepContent.title = "Still awake?"
        sleepContent.body = "Tap here"
        sleepContent.sound = UNNotificationSound.default
        
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
        }
    }
    
    func beginSleep(){
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
        let sleepRequest = UNNotificationRequest(identifier: UUID().uuidString, content: sleepContent, trigger: nil)
        center.add(sleepRequest)
    }
    
    func notifyWakeUp(){
        let wakeUpRequest = UNNotificationRequest(identifier: UUID().uuidString, content: wakeContent, trigger: nil)
        center.add(wakeUpRequest)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.none)
    }
}
