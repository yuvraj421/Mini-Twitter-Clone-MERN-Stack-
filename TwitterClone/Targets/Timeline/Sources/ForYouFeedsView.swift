//
//  ForYouFeedsView.swift
//  TTwin

import Feeds

import SwiftUI

public struct ForYouFeedsView: View {
    @EnvironmentObject var feedClient: FeedsClient
    
    public init() {}
    
    public var body: some View {
        List(feedClient.activities) {
            item in
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: "\(item.userProfilePhoto ?? "https://picsum.photos/id/219/200")")) { loading in
                    if let image = loading.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    } else if loading.error != nil {
                        Image(systemName: "exclamationmark.icloud")
                            .resizable()
                            .scaledToFit()
//                            .clipShape(Circle())
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 48, height: 48)
                .accessibilityLabel("Profile photo")
                .accessibilityAddTraits(.isButton)
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text("\(item.actor)")
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .layoutPriority(1)
                        
                        Text("\(item.actor)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .layoutPriority(1)
                        
                        Text("* \(item.tweetSentAt ?? "???")")
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName:"ellipsis.circle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    HStack(alignment: .bottom) {
                        Text("\(item.tweetSummary ?? "???")")
                            .layoutPriority(2)
                        Text("\(item.hashTag ?? "???")")
                            .foregroundColor(.streamGreen)
                            .layoutPriority(3)
                        
                    }.font(.subheadline)
                    
                    AsyncImage(url: URL(string: "\(item.tweetPhoto ?? "heart")")) { loading in
                        if let image = loading.image {
                            image
                                .resizable()
                                .scaledToFit()
                        } else if loading.error != nil {
                            Image(systemName: "exclamationmark.icloud")
                                .resizable()
                                .scaledToFit()
    //                            .clipShape(Circle())
                        } else {
                            //ProgressView()
                        }
                    }
                    .frame(width: .infinity, height: 180)
                    .cornerRadius(16)
                    .accessibilityLabel("Tweet with photo")
                    .accessibilityAddTraits(.isButton)
                    
                    HStack{
                        Image(systemName: "message")
                        Text("\(item.numberOfComments ?? "x")")
                        Spacer()
                        Image(systemName:"arrow.2.squarepath")
                        Spacer()
                        Image(systemName: "heart")
                        Text("\(item.numberOfLikes ?? "0")")
                        Spacer()
                        Image(systemName: "square.and.arrow.up.on.square")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        } //LIST STYLES
        .listStyle(.plain)
        .onAppear {
            Task {
                // TODO: switch between the right feeds depending on context
                do {
                    try await feedClient.getActivities()
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct ForYouFeedsView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouFeedsView()
            .preferredColorScheme(.dark)
    }
}
