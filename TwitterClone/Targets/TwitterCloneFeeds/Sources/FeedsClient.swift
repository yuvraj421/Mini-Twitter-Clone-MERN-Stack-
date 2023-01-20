//
//  FeedsClient.swift
//  TwitterCloneFeeds
//
//  Created by Jeroen Leenarts on 18/01/2023.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation
import TwitterCloneAuth
import TwitterCloneNetworkKit

enum Region: String {
    case usEast = "https://us-east-api.stream-io-api.com/api/v1.0/"
    case euWest = "https://eu-west-api.stream-io-api.com/api/v1.0/"
    case singapore = "https://singapore-api.stream-io-api.com/api/v1.0/"
}

private struct FollowParamModel: Encodable {
    let target: String
    let activity_copy_limit: Int
}

private struct UnfollowParamModel: Encodable {
    let keep_history: Bool
}

public struct PagingModel: Encodable {
    let limit: Int
    let offset: Int
    
    func appendingPagingModel(to url: URL) -> URL {
        return url.appending(queryItems:
            [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)"),
            ])
    }

}

private extension URL {
    mutating func appendApiKey() {
        append(queryItems: [URLQueryItem(name: "api_key", value: "dn4mpr346fns")])
    }
    
    func appendingApiKey() -> URL {
        return appending(queryItems: [URLQueryItem(name: "api_key", value: "dn4mpr346fns")])
    }
}

public class FeedsClient {
    let baseUrl: URL
    
    let auth = TwitterCloneAuth()
    
    private func userURL() -> URL {
        var newURL = baseUrl.appending(component: "user")
        newURL.appendApiKey()
        return newURL
    }
    
    private func userURL(userId: String) -> URL {
        var newURL = baseUrl.appending(component: "user")
        newURL.append(component: userId)
        newURL.appendApiKey()
        return newURL
    }
    
    private func userFeedURL(userId: String)-> URL {
        
        var newURL = baseUrl.appending(component: "feed/user")
        newURL.append(path: userId)
        newURL.appendApiKey()

        return newURL
    }
    
    private func timelineFeedFollowsURL(userId: String)-> URL {
        
        var newURL = baseUrl.appending(component: "feed/timeline")
        newURL.append(path: userId)
        newURL.append(path: "follows")
        newURL.appendApiKey()

        return newURL
    }
    
    private func timelineFeedUnfollowURL(userId: String, target: String)-> URL {
        
        var newURL = baseUrl.appending(component: "feed/timeline")
        newURL.append(path: userId)
        newURL.append(path: "unfollow")
        newURL.append(path: target)
        newURL.appendApiKey()

        return newURL
    }
    
    
    private func feedFollowersURL(userId: String)-> URL {
        
        var newURL = baseUrl.appending(component: "feed/user")
        newURL.append(path: userId)
        newURL.append(path: "followers")
        newURL.appendApiKey()

        return newURL
    }
    
    
    static func productionClient(region: Region) -> FeedsClient {
        return FeedsClient(urlString: region.rawValue)
    }
    
    private init(urlString: String) {
        baseUrl = URL(string: urlString)!
    }
    
    public func user() async throws -> FeedUser {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: userURL(userId: userId))
        request.httpMethod = "GET"

        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        return try TwitterCloneNetworkKit.jsonDecoder.decode(FeedUser.self, from: data)
    }
    
    public func updateUser(_ user: FeedUser) async throws {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: userURL(userId: userId))
        request.httpMethod = "PUT"
        request.httpBody = try TwitterCloneNetworkKit.jsonEncoder.encode(user)

        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
    }
    
    public func createUser(_ user: FeedUser) async throws {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let feedToken = authUser.feedToken
        var request = URLRequest(url: userURL())
        request.httpMethod = "POST"
        request.httpBody = try TwitterCloneNetworkKit.jsonEncoder.encode(user)

        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
    }
    
    public func follow(feedId: String, target: String, activityCopyLimit: Int) async throws {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: timelineFeedFollowsURL(userId: userId))
        request.httpMethod = "POST"
        request.httpBody = try TwitterCloneNetworkKit.jsonEncoder.encode(FollowParamModel(target: target, activity_copy_limit: activityCopyLimit))
        
        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
    }
    
    public func unfollow(feedId: String, target: String, keepHistory: Bool) async throws {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: timelineFeedUnfollowURL(userId: userId, target: target))
        request.httpMethod = "DELETE"
        
        request.httpBody = try TwitterCloneNetworkKit.jsonEncoder.encode(UnfollowParamModel(keep_history:keepHistory))

        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
    }
    
    public func followers(feedId: String, pagingModel: PagingModel? = nil) async throws -> [FeedFollower] {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var url = feedFollowersURL(userId: userId)
        url = pagingModel?.appendingPagingModel(to: url) ?? url
                
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
                
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        return try TwitterCloneNetworkKit.jsonDecoder.decode(FeedFollowers.self, from: data).followers
    }
    
    public func following(feedId: String, pagingModel: PagingModel? = nil) async throws -> [FeedFollower] {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        
        var url = timelineFeedFollowsURL(userId: userId)
        url = pagingModel?.appendingPagingModel(to: url) ?? url
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        return try TwitterCloneNetworkKit.jsonDecoder.decode(FeedFollowers.self, from: data).followers
    }
    
    public func getActivities() async throws -> [PostActivity] {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: userFeedURL(userId: userId))
        request.httpMethod = "GET"

        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        return try TwitterCloneNetworkKit.jsonDecoder.decode([PostActivity].self, from: data)
    }
    
    public func addActivity() async throws -> PostActivityResponse {
        let session = TwitterCloneNetworkKit.restSession
        
        let authUser = try auth.storedAuthUser()

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: userFeedURL(userId: userId))
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        return try TwitterCloneNetworkKit.jsonDecoder.decode(PostActivityResponse.self, from: data)
    }
}