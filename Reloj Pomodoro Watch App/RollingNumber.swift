//
//  RollingNumber.swift
//  Reloj Pomodoro Watch App
//
//  Created by Alejandro on 11/08/24.
//

import SwiftUI

struct RollingNumber: View {
    @Binding var targetValue: Int
    @State private var offset: [CGFloat] = [0]

    var body: some View {
        VStack {
            HStack {
                SingleDigitView(offset: offset[0])
            }
            .frame(width: 20, height: 20)
        }
        .padding(10)
        .onChange(of: targetValue) { newValue in
            setOffsets()
        }
    }
    
    struct SingleDigitView: View {
        var offset: CGFloat = 0
        
        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach(0..<10) { number in
                        Text("\(number)")
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .offset(y: -offset)
            }
            .clipped()
        }
    }
    
    func setOffsets() {
        let digits = String(format: "%01d", targetValue).map { String($0) }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            for (index, digit) in digits.enumerated() {
                offset[index] = CGFloat(Int(digit)!) * 20
            }
        }
    }
}
