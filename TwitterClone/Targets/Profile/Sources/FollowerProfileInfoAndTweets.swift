//
//  ProfileInfoAndTweets.swift
//  TwitterClone
//

import SwiftUI

import Timeline
import TwitterCloneUI

struct FollowerProfileInfoAndTweets: View {
    @State private var selection = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    FollowerProfileImage()
                        .scaleEffect(1.2)
                    
                    Spacer()
                    
                    Button{
                        print("receives notifications from this user")
                    } label: {
                        Image(systemName: "bell.badge.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                    }
                    
                    Button{
                        print("")
                    } label: {
                        Image(systemName: "message.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                    }
                    
                    Button{
                        print("")
                    } label: {
                        Text("Following")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.bordered)
                }
                
                ProfileInfoView(myProfile: FollowerProfileData)
                
                ForYouFeedsView()
                    .frame(height: UIScreen.main.bounds.height)
            }.padding()
        }
       
        
    }
}

struct FollowerProfileInfoAndTweets_Previews: PreviewProvider {
    static var previews: some View {
        FollowerProfileInfoAndTweets()
            .preferredColorScheme(.dark)
    }
}