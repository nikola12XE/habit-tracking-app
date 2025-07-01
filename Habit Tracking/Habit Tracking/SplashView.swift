import SwiftUI

struct SplashView: View {
    @StateObject private var appState = AppStateManager.shared

    var body: some View {
        ZStack {
            // Pozadina
            Color(red: 0.93, green: 0.93, blue: 0.93) // #ededed
                .ignoresSafeArea()

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

                // Crveni cvet - 30% vidljiv levo
                let redWidth = 294 * 1.2
                Image("SplashFlowerRed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 504 * 1.2)
                    .rotationEffect(.degrees(13.603))
                    .blur(radius: 8)
                    .position(x: (redWidth * 0.3) / 2, y: 399 + (504 * 1.2) / 2 - 15)
            }
            .allowsHitTesting(false)

            // SVG Union (crni talas na dnu)
            VStack {
                Spacer()
                SplashBottomWave()
                    .frame(width: 440, height: 152)
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

            // Dugmad (uvek na vrhu)
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Button(action: {
                        appState.navigateTo(.signUp)
                    }) {
                        Text("Sign Up")
                            .font(.custom("Inter_28pt-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.black)
                            .cornerRadius(100)
                            .tracking(-0.64)
                    }
                    Button(action: {
                        appState.navigateTo(.goalEntry)
                    }) {
                        Text("Set your Goal")
                            .font(.custom("Inter_28pt-Bold", size: 16))
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 440, height: 956)
    }
}

// SVG Union (crni talas na dnu)
struct SplashBottomWave: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                // SVG: M0 0C0 22.0914 17.9086 40 40 40H400C422.091 40 440 22.0914 440 0V152H0V0Z
                path.move(to: CGPoint(x: 0, y: 0))
                path.addCurve(to: CGPoint(x: 40, y: 40),
                              control1: CGPoint(x: 0, y: 22.0914),
                              control2: CGPoint(x: 17.9086, y: 40))
                path.addLine(to: CGPoint(x: 400, y: 40))
                path.addCurve(to: CGPoint(x: 440, y: 0),
                              control1: CGPoint(x: 422.091, y: 40),
                              control2: CGPoint(x: 440, y: 22.0914))
                path.addLine(to: CGPoint(x: 440, y: 152))
                path.addLine(to: CGPoint(x: 0, y: 152))
                path.closeSubpath()
            }
            .fill(Color.black)
        }
    }
}

#Preview {
    SplashView()
} 