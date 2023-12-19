//
//  ContentView.swift
//  Customized Aerial Screen Saver
//
//  Created by falcon on 2023/10/7.
//

import SwiftUI
import Security
import SecurityFoundation

enum PasswordTestResult{
    case empty
    case success
    case failed
}

struct ContentView: View {
    let screenSaverManager = CustomScreenSaverManager()
    
    @State var showPaaswordPrompt: Bool = true
    @State var username: String = NSUserName()
    @State var userPassword: String = ""
    @State var passwordTestResult: PasswordTestResult = .empty
    
    private func testPassword() -> Bool{
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "sudo -S -v"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        let inputPipe = Pipe()
        process.standardInput = inputPipe
        
        process.launch()
        inputPipe.fileHandleForWriting.write(userPassword.data(using: .utf8)!)
        do{
            try inputPipe.fileHandleForWriting.close()
        }catch{
            print(error)
        }
        
        let timeoutDate = Date().addingTimeInterval(TimeInterval(0.5))
        while process.isRunning && Date() < timeoutDate {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
        if process.isRunning {
            process.terminate()
        }
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            print("Command failed with exit status \(process.terminationStatus)")
        }
        return process.terminationStatus == 0 ? true : false
    }
    
    private func verifyPassword(){
        if(testPassword()){
            passwordTestResult = .success
            screenSaverManager.setUserPassword(password: userPassword)
            showPaaswordPrompt = false
            
            // I think this might be a good part of the startup flow to trigger migration
            moveFilesIfFound()
        }else{
            passwordTestResult = .failed
            userPassword = ""
        }
    }

    var body: some View {
        CustomAerialsManagementView(screenSaverManager: screenSaverManager)
            .sheet(isPresented: $showPaaswordPrompt) {
                Text("Your password is required to make system-level changes.")
                    .padding()
                VStack{
                    TextField("Username", text: $username)
                        .disabled(true)
                    SecureField("\(passwordTestResult == .failed ? "Invalid Password" : "Password" )", text: $userPassword)
                        .foregroundStyle(passwordTestResult == .failed ? .red : .gray)
                        .background(passwordTestResult == .failed ? Color(red: 1, green: 0, blue: 0, opacity: 0.5) : .clear)
                }.padding().onSubmit {
                    verifyPassword()
                }
                Button {
                    verifyPassword()
                } label: {
                    Text("Authorize")
                }.padding()
            }
    }
    
}

#Preview {
    ContentView()
}
