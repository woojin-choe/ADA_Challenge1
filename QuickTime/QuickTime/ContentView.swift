//
//  ContentView.swift
//  QuickTime
//
//  Created by 최우진 on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        if showSplash {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
        } else {
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
