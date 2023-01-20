//
//  ContentView.swift
//  PerfectNap
//
//  Created by Ryan McSweeney on 1/18/23.
//  Sources used:
//

import SwiftUI
import NotificationCenter

struct ContentView: View {
    
    
    //Set timer interval "every" and tolerance (tolerance at 1/10 good for preserving device power)
    let timer  = Timer.publish(every: 600, tolerance: 60, on: .main, in: .common).autoconnect()
    
    
    
    //State variables for hours/minutes on UI and determined falling asleep check timer
    @State private var hours = 0
    @State private var minutes = 0
    @State private var sleepCheck = 0
    
    enum userState {
        case idle
        case fallingAsleep
        case asleep
        case wakeUp
    }
    
    @State private var userStatus = userState.idle
    
    
        
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
            }.padding()
        }
    }
    
    func beginSleep(){
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
            if (sleepCheck > 0){
                
            }
            else{
                
            }
        case .asleep:
            <#code#>
        case .wakeUp:
            <#code#>
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.none)
    }
}
