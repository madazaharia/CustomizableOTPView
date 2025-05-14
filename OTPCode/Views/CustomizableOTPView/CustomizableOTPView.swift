//
//  CustomizableOTPView.swift
//  OTPCode
//
//  Created by Madalin Zaharia on 14.05.2025.
//

import Combine
import SwiftUI

struct CustomizableOTPView: View {

    let length: Int
    let focusColor: Color
    let borderColor: Color

    @State private var otpDigits: [String]
    @FocusState private var focusedIndex: Int?

    // keep the value to update even if is suffix or prefix near TextField cursor
    @State private var oldValue: String = ""

    init(
        length: Int = 6,
        focusColor: Color = .black,
        borderColor: Color = .gray
    ) {
        self.length = length
        self.focusColor = focusColor
        self.borderColor = borderColor

        self._otpDigits = State(initialValue: Array(repeating: "", count: length))
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<length, id: \ .self) { index in
                TextField(
                    "",
                    text: $otpDigits[index],
                    onEditingChanged: { editing in
                        if editing {
                            oldValue = otpDigits[index]
                        }
                    }
                )
                .frame(width: 53, height: 84)
                .background(Color.white)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode) // autocomplete code from sms
                .focused($focusedIndex, equals: index)
                .cornerRadius(4)
                .tag(index)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            focusedIndex == index ? focusColor : borderColor,
                            lineWidth: focusedIndex == index ? 2 : 1
                        )
                )
                .onChange(of: otpDigits[index]) { newValue in
                    onChange(index, newValue)
                }
            }
        }
        .padding()
        .onAppear {
            // Delay required to make sure view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusedIndex = 0 // show keyboard with focus on first box
            }
        }
    }

    private func onChange(_ index: Int, _ newValue: String) {
        if otpDigits[index].count > 1 { // override old value
            let currentValue = Array(otpDigits[index])

            guard !oldValue.isEmpty else {
                return
            }

            if currentValue[0] == Character(oldValue) {
                otpDigits[index] = String(otpDigits[index].suffix(1))
            } else {
                otpDigits[index] = String(otpDigits[index].prefix(1))
            }
        }

        if !newValue.isEmpty { // start typing
            if index == otpDigits.count - 1 {
                focusedIndex = nil // close keyboard when last digit is entered
            } else {
                focusedIndex = (focusedIndex ?? 0) + 1 // move forward
            }
        } else { // backspace is pressed, move backward
            focusedIndex = (focusedIndex ?? 0) - 1
        }
    }
}

#Preview {
    CustomizableOTPView(length: 6, focusColor: .black, borderColor: .gray)
}
