//
//  ContentView.swift
//  BetterRest
//
//  Created by Tausif Qureshi on 2023-02-02.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        let components = DateComponents(hour: 7, minute: 0)
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var calculatedSleepTime: String {
        var sleepTime: Date = Date.now
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            sleepTime = wakeUp - prediction.actualSleep
            
         
           
        } catch {
            // something went wrong!
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
            return alertTitle + "\n" + alertMessage
        }
        
        return sleepTime.formatted(date: .omitted, time: .shortened)
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(spacing: 30) {
                    Section {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    } header: {
                        Text("When do you want to wake up?")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
//                        Text("Daily coffee intake")
//                            .font(.headline)
//
//                        Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
//
                        Picker("Daily Coffee Intake", selection: $coffeeAmount) {
                            ForEach(1..<20){
                                Text("\($0)")
                            }
                            .font(.headline)
                        }
                    }
                    
                    Section {
                        Text(calculatedSleepTime)
                            .font(.headline)
                    } header : {
                        Text("Your bedtime is...")
                            .font(.title)
                    }
                }
            }
            .navigationTitle("BetteRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedTime)
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("OK") {}
//            } message: {
//                Text(alertMessage)
//            }
        }
        
    }
    
    func calculateBedTime () {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // something went wrong!
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}

 

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
