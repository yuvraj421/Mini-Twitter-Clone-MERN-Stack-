//
//  URLFactory.swift
//  TwitterCloneFeeds
//
//  Created by Jeroen Leenarts on 25/01/2023.
//  Copyright © 2023 Stream.io Inc.  All rights reserved.
//

import Foundation
import SwiftUI
import NetworkKit

internal enum FeedsURL {
    case images
    case reaction(activityId: String? = nil)
    case followers(userId: String)
    case follows(userId: String)
    case user(userId: String? = nil)
    case userFeed(userId: String)
    case timelineFeed(userId: String)
    case follow(userId: String)
    case unfollow(userId: String, target: String)

}

public enum Region: String {
    case usEast = "https://us-east-api.stream-io-api.com/api/v1.0/"
    case euWest = "https://eu-west-api.stream-io-api.com/api/v1.0/"
    case singapore = "https://singapore-api.stream-io-api.com/api/v1.0/"
}

internal class URLFactory {
    let baseUrl: URL

    internal init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }

    internal func url(forPath: FeedsURL) -> URL {
        var newURL = baseUrl

        switch forPath {
        case .images:
            newURL.append(path: "images")
        case .followers(let userId):
            newURL.append(path: "feed/user")
           newURL.append(path: userId)
           newURL.append(path: "followers")
        case .user(let userId):
            newURL.append(path: "user")
            if let userId {
                newURL.append(path: userId)
            }
        case .userFeed(let userId):
            newURL.append(path: "enrich/feed/user")
            newURL.append(path: userId)
            newURL.append(queryItems: [URLQueryItem(name: "withRecentReactions", value: "true")])
            newURL.append(queryItems: [URLQueryItem(name: "withReactionCounts", value: "true")])
            newURL.append(queryItems: [URLQueryItem(name: "withOwnReactions", value: "true")])
        case .timelineFeed(let userId):
            // Note: we are GETting the enriched timeline feed which includes actor information.
            newURL.append(path: "enrich/feed/timeline")
            newURL.append(path: userId)
            newURL.append(queryItems: [URLQueryItem(name: "withRecentReactions", value: "true")])
            newURL.append(queryItems: [URLQueryItem(name: "withReactionCounts", value: "true")])
            newURL.append(queryItems: [URLQueryItem(name: "withOwnReactions", value: "true")])
        case .follows(let userId):
            newURL.append(path: "feed/timeline")
           newURL.append(path: userId)
           newURL.append(path: "follows")
        case .follow(userId: let userId):
            newURL.append(path: "feed/timeline")
            newURL.append(path: userId)
            newURL.append(path: "follows")
        case .unfollow(userId: let userId, target: let target):
            newURL.append(path: "feed/timeline")
            newURL.append(path: userId)
            newURL.append(path: "follows")
            newURL.append(path: "user:" + target)
        case .reaction(activityId: let activityId):
            newURL.append(path: "reaction")
            if let activityId {
                newURL.append(path: activityId)
            }
        }
        newURL.appendApiKey()
        return newURL
    }
}

private extension URL {
    mutating func appendApiKey() {
        append(queryItems: [URLQueryItem(name: "api_key", value: TwitterCloneNetworkKit.apiKey)])
        
    }

    func appendingApiKey() -> URL {
        return appending(queryItems: [URLQueryItem(name: "api_key", value: TwitterCloneNetworkKit.apiKey)])
    }
}
