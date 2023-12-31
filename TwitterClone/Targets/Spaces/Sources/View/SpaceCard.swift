//
//  SpaceCard.swift
//  Spaces
//
//  Created by Stefan Blos on 16.02.23.
//  Copyright © 2023 Stream.io Inc. All rights reserved.
//

import SwiftUI
import TwitterCloneUI

struct SpaceCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: SpacesViewModel
    var space: Space
    
    var body: some View {
        Button {
            viewModel.spaceCardTapped(space: space)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    if space.state == .running {
                        SoundIndicatorView()
                            .scaleEffect(0.3)
                            .frame(width: 40, height: 40)
                    }
                    Text(space.state.cardString)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(space.name)
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    
                    Text(space.description)
                        .font(.caption)
                        .lineLimit(3)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal)
                }
                
                if space.state == .running {
                    HStack {
                        HStack(spacing: -20) {
                            ForEach(space.listeners.prefix(3), id: \.self) { listener in
                                ImageFromUrl(url: listener.imageURL, size: 30)
                            }
                        }
                        Text("\(space.listeners.count) listening")
                            .font(.caption)
                            .foregroundColor(.white)
                    }.padding()
                } else if space.state == .planned {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("Planned: ")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(space.startDate.formatted())
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                } else if space.state == .finished {
                    Text("This space has finished")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                }
                
                HStack {
                    ImageFromUrl(url: URL(string: space.hostImageUrl), size: 30)
                    
                    Text(space.host)
                        .font(.footnote)
                    Image(systemName: "checkmark.seal.fill")
                    
                    Spacer()
                    
                    Text("Host")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.trailing)
                }
                .foregroundColor(.white)
                .padding()
                .background(colorScheme == .light ? .lowerBarLight : .lowerBarDark)
            }
            .background(LinearGradient(gradient: Gradient(colors: [colorScheme == .light ? .streamLightStart : .streamDarkStart, colorScheme == .light ? .streamLightEnd : .streamDarkEnd]), startPoint: .top, endPoint: .bottom))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .sheet(item: $viewModel.selectedSpace, onDismiss: {
            viewModel.spaceCloseTapped()
        }, content: { selectedSpace in
            SpaceView(selectedSpace: selectedSpace, viewModel: viewModel)
                .presentationDetents([.fraction(0.9)])
        })
        .cornerRadius(12)
        .frame(width: 280)
    }
}

struct SpaceCard_Previews: PreviewProvider {
    static var previews: some View {
        SpaceCard(viewModel: .preview, space: .preview)
    }
}
