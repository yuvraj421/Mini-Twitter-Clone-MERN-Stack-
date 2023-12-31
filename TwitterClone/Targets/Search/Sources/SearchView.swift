//
//  ContentView.swift
//  TTwin

import SwiftUI

import Feeds
import Combine
import Auth
import InstantSearchCore
import InstantSearchInsights
import InstantSearchSwiftUI

@MainActor
class AlgoliaController: ObservableObject {
    let searcher: HitsSearcher
    let insights: Insights
    let searchBoxInteractor: SearchBoxInteractor
    let searchBoxController: SearchBoxObservableController

    let hitsInteractor: HitsInteractor<FeedUser>
    let hitsController: HitsObservableController<FeedUser>
  
    var feedsClient: FeedsClient
    var auth: TwitterCloneAuth
    
    private let indexName: IndexName = "TwitterCloneUsers"
    
    func submit() {
        searchBoxController.submit()
        Task {
            let feedFollowers: [FeedFollower]
            followedUserFeedIds.removeAll()
            feedFollowers = try await feedsClient.following()
            feedFollowers.forEach { followedUserFeedIds.insert($0.targetId) }
        }
    }
    
    @Published var followedUserFeedIds = Set<String>()
    
    init(feedsClient: FeedsClient, auth: TwitterCloneAuth) {
        self.feedsClient = feedsClient
        self.auth = auth
        let appID: ApplicationID = "BGP9QX4VDE"
        let apiKey: APIKey = "d50d7e16b4341c04814ef66977faa4c2"
        let userToken = UserToken(rawValue: feedsClient.authUser.userId)
        self.searcher = HitsSearcher(appID: appID,
                                 apiKey: apiKey,
                                 indexName: indexName)
        self.insights = Insights.register(appId: appID, apiKey: apiKey, userToken: userToken)
        self.searchBoxInteractor = .init()
        self.searchBoxController = .init()
        self.hitsInteractor = .init()
        self.hitsController = .init()
        setupConnections()
    }
  
    func setupConnections() {
      searchBoxInteractor.connectSearcher(searcher)
      searchBoxInteractor.connectController(searchBoxController)
      hitsInteractor.connectSearcher(searcher)
      hitsInteractor.connectController(hitsController)
    }
    
    func isFollowing(user: FeedUser) -> Bool {
        return followedUserFeedIds.contains("user:" + user.userId)
    }
    
    func unfollow(user: FeedUser) {
        Task {
            do {
                try await feedsClient.unfollow(target: user.userId, keepHistory: true)
                insights.clicked(eventName: EventName(rawValue: "unfollow"), indexName: indexName, objectID: ObjectID(rawValue: user.userId), userToken: UserToken(rawValue: feedsClient.authUser.userId))
                followedUserFeedIds.remove("user:" + user.userId)
            } catch {
                print(error)
            }
        }
    }
    
    func follow(user: FeedUser) {
        Task {
            do {
                try await feedsClient.follow(target: user.userId, activityCopyLimit: 100)
                insights.clicked(eventName: EventName(rawValue: "follow"), indexName: indexName, objectID: ObjectID(rawValue: user.userId), userToken: UserToken(rawValue: feedsClient.authUser.userId))
                followedUserFeedIds.insert("user:" + user.userId)
            } catch {
                print(error)
            }
        }
    }
      
}

public struct SearchView: View {
    
    @StateObject var algoliaController: AlgoliaController
    
    @ObservedObject var searchBoxController: SearchBoxObservableController
    @ObservedObject var hitsController: HitsObservableController<FeedUser>

    @State private var isEditing = false
    
    public init(feedsClient: FeedsClient, auth: TwitterCloneAuth) {
        let algoliaController = AlgoliaController(feedsClient: feedsClient, auth: auth)
        _algoliaController = StateObject(wrappedValue: algoliaController)
        _searchBoxController = ObservedObject(wrappedValue: algoliaController.searchBoxController)
        _hitsController = ObservedObject(wrappedValue: algoliaController.hitsController)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 7) {
                HStack {
                    Text("Recent searchers")
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                    
                    Button {
                        // Clear recent searches
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title3)
                            .bold()
                    }
                }
                
                ScrollView(.horizontal) {
                    RecentSearchesView()
                }
                .padding(.top, -24)
                
                SearchBar(text: $searchBoxController.query,
                          isEditing: $isEditing,
                          onSubmit: {
                    algoliaController.submit()
                })
                .autocapitalization(.none)
                .foregroundColor(Color(.systemGray))
                .padding(.bottom)
                
                HitsList(hitsController) { user, _ in
                    if let user {
                        HStack {
                            Text(user.username)
                                .font(.headline)
                            Text(user.userId)
                            Spacer()
                            if user.userId != algoliaController.auth.authUser?.userId {
                                if algoliaController.isFollowing(user: user) {
                                    Button("Unfollow") {
                                        algoliaController.unfollow(user: user)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    
                                } else {
                                    Button("Follow") {
                                        algoliaController.follow(user: user)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    
                } noResults: {
                    Text("No Results")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    algoliaController.submit()
                }
            }
            .padding()
            .navigationBarTitle("Algolia & SwiftUI")
        }
    }
}
