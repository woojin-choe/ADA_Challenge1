//
//  SplashView.swift
//  QuickTime
//
//  Created by 최우진 on 3/30/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Image("Splash_Logo")
                Spacer()
                Image("Splash_Logo_Sub")
            }
        }
    }
}

#Preview {
    SplashView()
}
