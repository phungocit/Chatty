//
//  UIEmojiTextView.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import SwiftUI
import UIKit

class UIEmojiTextView: UITextView {
    var isEmoji = false {
        didSet {
            setEmoji()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setEmoji() {
        reloadInputViews()
    }

    override var textInputContextIdentifier: String? {
        return ""
    }

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" && isEmoji {
                keyboardType = .default
                return mode

            } else if !isEmoji {
                return mode
            }
        }
        return nil
    }

    override var intrinsicContentSize: CGSize {
        let size = sizeThatFits(.init(width: bounds.width, height: .greatestFiniteMagnitude))
        return CGSize(width: bounds.width, height: size.height)
    }
}

struct EmojiTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEmoji: Bool

    func makeUIView(context: Context) -> UIEmojiTextView {
        let emojiTextView = UIEmojiTextView()
        emojiTextView.backgroundColor = .clear
        emojiTextView.font = UIFont.preferredFont(forTextStyle: .body)
        emojiTextView.text = "Placeholder"
        emojiTextView.textColor = UIColor.lightGray
        emojiTextView.delegate = context.coordinator
        emojiTextView.isEmoji = isEmoji
        return emojiTextView
    }

    func updateUIView(_ uiView: UIEmojiTextView, context: Context) {
        uiView.text = text
        uiView.isEmoji = isEmoji
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: EmojiTextView

        init(parent: EmojiTextView) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.text = textView.text ?? ""
        }
    }
}
