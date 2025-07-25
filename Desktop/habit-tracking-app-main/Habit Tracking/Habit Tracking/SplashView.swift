import SwiftUI

struct SplashView: View {
    @StateObject private var appState = AppStateManager.shared
    @State private var waveOffset: CGFloat = 0
    @State private var buttonsOffset: CGFloat = 0
    @State private var blueFlowerOffset: CGSize = .zero
    @State private var redFlowerOffset: CGSize = .zero
    @State private var isExiting: Bool = false

    var body: some View {
        ZStack {
            // PNG cvetovi (iza SVG-a)
            GeometryReader { geo in
                // Plavi cvet - 30% vidljiv desno, horizontalni flip
                let blueWidth = 277 * 1.2
                Image("SplashFlowerBlue")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 552 * 1.2)
                    .rotationEffect(.degrees(169.341))
                    .scaleEffect(x: -1, y: -1) // horizontalni i vertikalni flip
                    .blur(radius: 8)
                    .position(x: geo.size.width - (blueWidth * 0.3) / 2 + 20, y: 415 + (552 * 1.2) / 2 - 15)
                    .offset(blueFlowerOffset)

                // Crveni cvet - 30% vidljiv levo
                let redWidth = 294 * 1.2
                Image("SplashFlowerRed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 504 * 1.2)
                    .rotationEffect(.degrees(13.603))
                    .blur(radius: 8)
                    .position(x: (redWidth * 0.3) / 2, y: 399 + (504 * 1.2) / 2 - 15)
                    .offset(redFlowerOffset)
            }
            .allowsHitTesting(false)

            // SVG Union (crni talas na dnu) - puna širina
            VStack {
                Spacer()
                SplashBottomWave()
                    .frame(width: UIScreen.main.bounds.width, height: 152)
                    .offset(y: waveOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // HeaderText
            VStack {
                VStack(spacing: 14) {
                    Text("SET YOUR\nBIGGEST GOAL")
                        .font(.custom("Thunder-BoldLC", size: 82))
                        .fontWeight(.black)
                        .foregroundColor(.black)
                        .tracking(0.82)
                        .multilineTextAlignment(.center)
                        .frame(width: 400)

                    Text("Create one goal that will set everything else in motion. The goal that, once achieved, makes other wins easier to reach.")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.black.opacity(0.7))
                        .tracking(-0.56)
                        .frame(width: 277)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 120)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .offset(y: isExiting ? -300 : 0)
            .opacity(isExiting ? 0 : 1)
            .animation(.easeInOut(duration: 0.6), value: isExiting)

            // Dugmad (uvek na vrhu)
            VStack {
                Spacer()
                HStack(spacing: 8) {
                Button(action: {
                    animateWaveAndNavigate(to: .signUp)
                }) {
                    Text("Sign Up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        .background(Color.black)
                        .cornerRadius(100)
                        .tracking(-0.64)
                }
                Button(action: {
                    animateWaveAndNavigate(to: .goalEntry)
                }) {
                    Text("Set your Goal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(100)
                        .tracking(-0.64)
                }
            }
                .padding(.horizontal, 24)
                .padding(.bottom, 45)
                .offset(y: buttonsOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 440, height: 956)
    }
    
    private func animateWaveAndNavigate(to screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.4)) {
            isExiting = true
            waveOffset = 200
            buttonsOffset = 200
            blueFlowerOffset = CGSize(width: 200, height: 300)
            redFlowerOffset = CGSize(width: -200, height: 300)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            appState.navigateTo(screen)
        }
    }
}

// SVG Union (crni talas na dnu) - prilagođen za punu širinu
struct SplashBottomWave: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let height = geo.size.height
                
                // Prilagođen SVG path za punu širinu
                path.move(to: CGPoint(x: 0, y: 0))
                path.addCurve(to: CGPoint(x: width * 0.091, y: height * 0.263),
                              control1: CGPoint(x: 0, y: height * 0.145),
                              control2: CGPoint(x: width * 0.041, y: height * 0.263))
                path.addLine(to: CGPoint(x: width * 0.909, y: height * 0.263))
                path.addCurve(to: CGPoint(x: width, y: 0),
                              control1: CGPoint(x: width * 0.959, y: height * 0.263),
                              control2: CGPoint(x: width, y: height * 0.145))
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(Color.black)
        }
    }
}

#Preview {
    SplashView()
} 
