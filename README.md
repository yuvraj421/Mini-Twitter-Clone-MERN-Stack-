# Build a Twitter Clone With SwiftUI in a Weekend :sunglasses:

[![Build a Twitter Clone With SwiftUI in a Weekend](https://github.com/GetStream/twitter-clone/blob/main/Preview/byot-github-thumbnail.png)](https://youtu.be/OYwMgbLh2MAE "Build a Twitter Clone With SwiftUI in a Weekend")

[Eight tutorials](https://getstream.io/resources/projects/twitter-clone/) aimed at teaching you how to build a functional Twitter clone using APIs and SwiftUI. In this project, we will use [Stream](https://getstream.io/ios-activity-feed/tutorial/) for Chat and Activity Feeds, [Algolia](https://www.algolia.com/) for search, [RevenueCat](https://www.revenuecat.com/) for subscriptions, [100ms](https://www.100ms.live/) for audio rooms and [Mux](https://www.mux.com/) for video playback.

![Header image](https://github.com/GetStream/build-your-own-twitter/blob/main/Preview/byot-wrapup-header.png)

## Key Features

| Partners | Main Features | Description | Preview |
|---------------|---------------|-------------|---------|
| ![Stream](https://github.com/GetStream/stream-twitter-byo-ios/blob/main/Preview/stream.svg) | **Homepage Timeline Feeds**     | Drive social engagement by integrating Stream Feeds and Chat.    | ![Stream feeds](https://github.com/GetStream/stream-twitter-byo-ios/blob/main/Preview/01_signInTimeLine.gif) |
| ![100ms](https://github.com/GetStream/stream-twitter-byo-ios/blob/main/Preview/100ms.svg) |   **Twitter Spaces**   | Integrate live audio streaming capabilities with 100ms to recreate Twitter Spaces.     | ![https://www.100ms.live/](https://github.com/GetStream/stream-twitter-byo-ios/blob/main/Preview/04_spaces.gif) |
| ![Algolia](https://github.com/GetStream/stream-twitter-byo-ios/blob/main/Preview/algolia.svg) | **Search & Follow Users**     | Leverage Algolia’s advanced search functionality to help users find friends and connect with one another.     | ![Algolia](https://github.com/GetStream/stream-twitter-byo-ios/blob/main/Preview/03_search.gif) |
| ![Mux](https://github.com/GetStream/stream-twitter-byo-ios/blob/main/Preview/mux.svg) | **Media Upload**     | Use Mux to upload and play back videos in your app.     | ![Media upload with Mux](https://github.com/GetStream/build-your-own-twitter/blob/main/Preview/muxMedisUpload.png) |
| ![RevenueCat](https://github.com/GetStream/stream-twitter-byo-ios/blob/main/Preview/revenueCat.svg) | **Twitter Blue**     | Power your platform’s monetization model by using RevenueCat to integrate in-app purchases and subscriptions.     | ![RevenueCat subscription](https://github.com/GetStream/build-your-own-twitter/blob/main/Preview/revenueCatSubscription.png) |


## The following links are the various parts of the tutorial series.

1. [Building the Timeline](https://getstream.io/resources/projects/twitter-clone/building-the-timeline) 
2. [Adding Stream Feeds to the Timeline](https://getstream.io/resources/projects/twitter-clone/adding-stream-feeds-to-the-timeline/)
3. [Enabling Support For Media Tweets and Video Playback](https://getstream.io/resources/projects/twitter-clone/enabling-support-for-media-tweets-and-video-playback/)
4. [Searching and Following Users](https://getstream.io/resources/projects/twitter-clone/searching-and-following-users/)
5. [Messaging and DMs](https://getstream.io/resources/projects/twitter-clone/messaging-and-dms/)
6. [Conversations With Spaces](https://getstream.io/resources/projects/twitter-clone/conversations-with-spaces/)
7. [Twitter Blue and In-app Subscriptions](https://getstream.io/resources/projects/twitter-clone/twitter-blue-in-app-subscriptions/)
8. [Brining it all together](https://getstream.io/resources/projects/twitter-clone/wrap-up-and-conclusion/)

-------------

# Getting Started

## Node backend
Please run the Node sample backend from this Git repository: [GetStream/stream-node-simple-integration-sample](https://github.com/getstream/stream-node-simple-integration-sample/)

## iOS Frontend

The folder TwitterClone contains the iOS codebase

To get started with it, you need to install Tuist and run `tuist generate` in the directory `TwitterClone`. Then open the `TwitterClone.xcworkspace` file.

[![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)


### To install Tuist on your system:

Run:
```shell
curl -Ls https://install.tuist.io | bash
```

### Fetching external dependencies

When you get freshly cloned this repository or dependencies have been updated. Run:

```shell
tuist fetch
```

### Generate and open project files
To generate the Xcode project files and open the project in Xcode, run:
```shell
tuist generate
```

## iOS package graph
We work towards a µFramework based packaging system

![](TwitterClone/graph.png)

To generate a fresh graph, in case you updated the project's package structure or dependencies. Run:

```shell
tuist graph --skip-test-targets
```

