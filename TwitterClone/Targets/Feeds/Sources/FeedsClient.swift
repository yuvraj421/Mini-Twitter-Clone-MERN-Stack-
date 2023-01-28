//
//  FeedsClient.swift
//  TwitterCloneFeeds
//
//  Created by Jeroen Leenarts on 18/01/2023.
//  Copyright © 2023 Stream.io Inc.  All rights reserved.
//

import Foundation
import SwiftUI
import Auth
import NetworkKit
import os.log

internal extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the view cycles like viewDidLoad.
    static let clientLog = OSLog(subsystem: subsystem, category: "client")
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

public class FeedsClient: ObservableObject {
    private ( set ) public var auth: TwitterCloneAuth
    
    private let mockEnabled: Bool
    
    @Published private ( set ) public var activities: [EnrichedPostActivity] = []
    
    private let urlFactory: URLFactory
    
    static public func productionClient(region: Region, auth: TwitterCloneAuth) -> FeedsClient {
        return FeedsClient(urlString: region.rawValue, auth: auth)
    }
    
    static public func previewClient() -> FeedsClient{
        return FeedsClient(urlString: Region.euWest.rawValue, auth: TwitterCloneAuth(), mockEnabled: true)
    }
    
    private init(urlString: String, auth: TwitterCloneAuth, mockEnabled: Bool = false) {
        urlFactory = URLFactory(baseUrl: URL(string: urlString)!)
        self.auth = auth
        self.mockEnabled = mockEnabled
    }
    
    public func user() async throws -> FeedUser {
        let session = TwitterCloneNetworkKit.restSession
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        
        var request = URLRequest(url: urlFactory.url(forPath: .user(userId: userId)))
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
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: urlFactory.url(forPath: .user(userId: userId)))
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
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let feedToken = authUser.feedToken
        var request = URLRequest(url: urlFactory.url(forPath: .user(userId: nil)))
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
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: urlFactory.url(forPath: .follow(userId: userId)))
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
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: urlFactory.url(forPath: .unfollow(userId: userId, target: target)))
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
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var url = urlFactory.url(forPath: .followers(userId: userId))
        url = pagingModel?.appendingPagingModel(to: url) ?? url
                
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
                
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        return try TwitterCloneNetworkKit.jsonDecoder.decode(ResultResponse<[FeedFollower]>.self, from: data).results
    }
    
    public func following(feedId: String, pagingModel: PagingModel? = nil) async throws -> [FeedFollower] {
        let session = TwitterCloneNetworkKit.restSession
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var url = urlFactory.url(forPath: .follows(userId: userId))
        url = pagingModel?.appendingPagingModel(to: url) ?? url
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        return try TwitterCloneNetworkKit.jsonDecoder.decode(ResultResponse<[FeedFollower]>.self, from: data).results
    }
    
    //TODO: paging
    public func getActivities() async throws {
        if (mockEnabled) {
            DispatchQueue.main.async { [weak self] in
                self?.activities = [EnrichedPostActivity.previewPostActivity()]
            }
            return
        }
        let session = TwitterCloneNetworkKit.restSession
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: urlFactory.url(forPath: .timelineFeed(userId: userId)))
        request.httpMethod = "GET"

        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)

        if OSLog.clientLog.isEnabled(type: .debug) {
            os_log(.debug, "getactivities response: %{public}@", String(data: data, encoding: .utf8) ?? "")
        }
        
        let activities = try TwitterCloneNetworkKit.jsonDecoder.decode(ResultResponse<[EnrichedPostActivity]>.self, from: data).results
        
        DispatchQueue.main.async { [weak self] in
            self?.activities = activities
        }
    }
    
    public func addActivity(_ activity: PostActivity) async throws -> PostActivityResponse {
        let session = TwitterCloneNetworkKit.restSession
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let userId = authUser.userId
        let feedToken = authUser.feedToken
        var request = URLRequest(url: urlFactory.url(forPath: .userFeed(userId: userId)))
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        return try TwitterCloneNetworkKit.jsonDecoder.decode(PostActivityResponse.self, from: data)
    }
    
    public func uploadImage(fileName: String, mimeType: String, imageData: Data) async throws -> URL {
        let session = TwitterCloneNetworkKit.restSession
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let feedToken = authUser.feedToken
        var request = URLRequest(url: urlFactory.url(forPath: .images))
        request.httpMethod = "POST"
        
        var multipart = MultipartRequest()
        multipart.add(key: "file", fileName: fileName, fileMimeType: mimeType, fileData: imageData)
        
        request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.httpBody
        
        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
        
        let fileUrl = try TwitterCloneNetworkKit.jsonDecoder.decode(String.self, from: data)
        return URL(string: fileUrl)! //TODO: check response
    }
    
    public func deleteImage(cdnUrl: String) async throws {
        let session = TwitterCloneNetworkKit.restSession
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let feedToken = authUser.feedToken
        var request = URLRequest(url: urlFactory.url(forPath: .images))
        request.httpMethod = "DELETE"
        request.httpBody = cdnUrl.data(using: .utf8)

        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)
    }
    
    public func processImage(cdnUrl: String, resize: CdnImageResizeStrategy? = nil, crop: CdnImageCropStrategy? = nil, width: Int? = nil, height: Int? = nil) async throws -> URL {
        let session = TwitterCloneNetworkKit.restSession
        
        guard let authUser = auth.authUser else {
            throw AuthError.noLoadedAuthUser
        }

        let feedToken = authUser.feedToken
        var url = urlFactory.url(forPath: .images)
        
        let queryItems = [
            resize.map{ URLQueryItem(name: "resize", value:$0.rawValue) },
            crop.map{ URLQueryItem(name: "crop", value:$0.rawValue) },
            width.map{ URLQueryItem(name: "w", value: "\($0)") },
            height.map{ URLQueryItem(name: "h", value: "\($0)") },
            URLQueryItem(name: "url", value: cdnUrl),
        ].compactMap {$0}
        
        url.append(queryItems:queryItems)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Headers
        request.addValue("jwt", forHTTPHeaderField: "Stream-Auth-Type")
        request.addValue(feedToken, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        try TwitterCloneNetworkKit.checkStatusCode(statusCode: statusCode)

        let fileUrl = try TwitterCloneNetworkKit.jsonDecoder.decode(String.self, from: data)
        return URL(string: fileUrl)! //TODO: check response
    }
}

public enum CdnImageResizeStrategy: String {
    case crop, scale, fill
}
public enum CdnImageCropStrategy: String {
    case top, bottom, left, right, center
}