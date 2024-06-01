//
//  PairingView.swift
//  stage2
//
//  Created by Kyrell Leano Siauw on 02/06/24.
//

import SwiftUI

struct PairingView: View {
    @ObservedObject var multipeer: MultipeerManager = MultipeerManager()
    
    @State var pairingCode: String = ""
    private func appendCode(_ code: String){
        if pairingCode.count < 6 {
            pairingCode.append(code)
        }
    }
    private func submitPasscodeMultipeer(){
        self.multipeer.pairingCode = pairingCode
        self.multipeer.activate()
    }
    var body: some View {
        // Numeric Buttons
        NavigationStack{
            Text(pairingCode)
                .font(.title)
                .padding()
                .bold()
            Text("\(self.multipeer.$connectedPeer)")
            VStack{
                HStack{
                    Button(action: {
                        self.appendCode("1")
                    }, label: {
                        Text("1")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                    Button(action: {
                        self.appendCode("2")
                    }, label: {
                        Text("2")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                    Button(action: {
                        self.appendCode("3")
                    }, label: {
                        Text("3")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                }
                HStack{
                    Button(action: {
                        self.appendCode("4")
                    }, label: {
                        Text("4")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                    Button(action: {
                        self.appendCode("5")
                    }, label: {
                        Text("5")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                    Button(action: {
                        self.appendCode("6")
                    }, label: {
                        Text("6")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                }
                HStack{
                    Button(action: {
                        self.appendCode("7")
                    }, label: {
                        Text("7")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                    Button(action: {
                        self.appendCode("8")
                    }, label: {
                        Text("8")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                    Button(action: {
                        self.appendCode("9")
                    }, label: {
                        Text("9")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                    Button(action: {
                        self.appendCode("0")
                    }, label: {
                        Text("0")
                            .font(.title)
                            .frame(width: 100, height: 100)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                    })
                }
                Button(action: {
                    submitPasscodeMultipeer()
                }, label: {
                    Text("Enter")
                        .font(.title)
                        .frame(width: 100, height: 100)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(50)
                })
            }
        }
        
    }
}

#Preview {
    PairingView()
}
