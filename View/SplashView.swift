//
//  SplashView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    var body: some View {
        ZStack {
            BackgroundColor()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("ChemVistaLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("ChemVista")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                self.scale = 1.0
                self.opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
        .preferredColorScheme(.dark)
}
