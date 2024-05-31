
//
//  PairingView.swift
//  conquery
//
//  Created by Kyrell Leano Siauw on 16/05/24.
//
import SwiftUI
struct ChooseDoorView: View {
    var body: some View {
        ZStack{
            VStack{
                Image("DreadscapeLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 128)
                HStack(alignment: .bottom){
                    Image("PintuDuniaNyata")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                        .offset(y: 20)
                    Image("PintuDuniaIsekai")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 500)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(.black)
    }
}
