//
//  CircularProfileImageView.swift
//  Chatty
//
//  Created by Foo on 21/06/2024.
//

import Kingfisher
import SwiftUI

struct CircularProfileImageView: View {
    let profileImageUrl: String?
    let size: Size
    let fallbackImage: FallbackImage

    init(_ profileImageUrl: String? = nil, size: Size) {
        self.profileImageUrl = profileImageUrl
        self.size = size
        self.fallbackImage = .directChatIcon
    }

    var body: some View {
        if let profileImageUrl {
            KFImage(URL(string: profileImageUrl))
                .resizable()
                .placeholder {
                    ProgressView()
                        .tint(Color(.systemGray))
                }
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            placeholderImageView
        }
    }

    var placeholderImageView: some View {
        Image(systemName: fallbackImage.rawValue)
            .resizable()
            .scaledToFit()
            .imageScale(.large)
            .foregroundStyle(Color(.systemGray))
            .frame(width: size.dimension, height: size.dimension)
            .background(Color.white)
            .clipShape(Circle())
    }
}

extension CircularProfileImageView {
    enum Size {
        case xMini, mini, xSmall, small, medium, large, xLarge
        case custom(CGFloat)

        var dimension: CGFloat {
            switch self {
            case .xMini:
                return 28
            case .mini:
                return 30
            case .xSmall:
                return 40
            case .small:
                return 50
            case .medium:
                return 60
            case .large:
                return 80
            case .xLarge:
                return 120
            case .custom(let dimen):
                return dimen
            }
        }
    }

    enum FallbackImage: String {
        case directChatIcon = "person.circle.fill"
        case groupChatIcon = "person.2.circle.fill"

        init(for membersCount: Int) {
            switch membersCount {
            case 2:
                self = .directChatIcon
            default:
                self = .groupChatIcon
            }
        }
    }
}

extension CircularProfileImageView {
    init(_ channel: ChannelItem, size: Size) {
        self.profileImageUrl = channel.coverImageUrl
        self.size = size
        self.fallbackImage = FallbackImage(for: channel.membersCount)
    }
}

#Preview {
    CircularProfileImageView(size: .large)
}
