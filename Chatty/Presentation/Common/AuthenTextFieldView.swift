//
//  AuthenTextFieldView.swift
//  Chatty
//
//  Created by Phil Tran on 7/6/24.
//

import SwiftUI

struct AuthenTextFieldView<TextFieldContent: View>: View {
    private let textField: TextFieldContent
    private let title: String
    private let inValidText: String
    private let isValid: Binding<Bool>

    init(title: String, inValidText: String, isValid: Binding<Bool>, @ViewBuilder textField: () -> TextFieldContent) {
        self.title = title
        self.inValidText = inValidText
        self.isValid = isValid
        self.textField = textField()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(isValid.wrappedValue ? Color.greenCustom : Color.systemRed)
            textField
                .padding(.top, 12)
            Rectangle()
                .fill(isValid.wrappedValue ? Color.systemGray4 : Color.systemRed)
                .frame(height: 1)
                .padding(.top, 4)
            Text(inValidText)
                .font(.caption)
                .foregroundStyle(isValid.wrappedValue ? Color.clear : Color.systemRed)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 8)
        }
    }
}

#Preview {
    @State var isValid = true
    @State var text = ""
    return AuthenTextFieldView(title: "Your email", inValidText: "Invalid your email", isValid: $isValid) {
        TextField("", text: $text)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
    }
}
