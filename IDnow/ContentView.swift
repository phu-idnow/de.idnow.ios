//
//  ContentView.swift
//  IDnow
//
//  Created by Aare Undo on 02.12.2021.
//

import SwiftUI
import IDnowSDK

struct ContentView: View {

    @State private var ident: String = "TST-SYVCR"
    @State private var error: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HStack {
                Spacer()
                Image("logo-main")
                Spacer()
            }.padding()
            Text("Please enter and confirm your Ident-ID to start the idenfitcation process")
                .padding()
                .multilineTextAlignment(.center)
            TextField("Enter your Ident-ID here", text: $ident)
                .padding()
                .padding()
                .multilineTextAlignment(.center)
                .onSubmit {
                    self.onConfirm()
                }
            HStack {
                Spacer()
                Button("CONFIRM") {
                    self.onConfirm()
                }
                Spacer()
            }
            
        }).alert(isPresented: .constant($error.wrappedValue != nil)) {
            Alert(title: Text("Error"), message: Text($error.wrappedValue!), dismissButton: .default(Text("Close"), action: {
                $error.wrappedValue = nil
            }))
        }
        
    }
    
    func onConfirm() {
        Task.init(priority: .background, operation: {
            IDnowService.instance.initialize(ident: $ident.wrappedValue)
            let result = await IDnowService.instance.start()
            if (result != nil) {
                $error.wrappedValue = result
            }
        })
    }
}

struct ContentView2: View {
    @ObservedObject var model: ViewModel
    @State var buttonEnabled: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HStack {
                Spacer()
                Image("logo-main")
                Spacer()
            }.padding()
            Text("Please enter and confirm your Ident-ID to start the idenfitcation process")
                .padding()
                .multilineTextAlignment(.center)
            TextField("Enter your Ident-ID here", text: $model.tokenField)
                .padding()
                .padding()
                .multilineTextAlignment(.center)
                .onSubmit {
                    self.onConfirm()
                }
            HStack {
                Spacer()
                Button("CONFIRM") {
                    self.onConfirm()
                }
                .disabled(!buttonEnabled)
                .onReceive(model.buttonEnabled) { enabled in
                    self.buttonEnabled = enabled
                }
                Spacer()
            }
            
        })
        .onAppear {
            model.tokenField = "TST-NHHCC"
        }
        .alert(isPresented: $model.identFinishedFailed ) {
            Alert(title: Text("Error"), message: Text(model.errorMessage), dismissButton: .default(Text("Close"), action: {
                model.finish()
            }))
        }
        
    }
    
    func onConfirm() {
        model.start()
    }
}


