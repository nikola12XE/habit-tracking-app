import SwiftUI

struct SplashView: View {
    @StateObject private var appState = AppStateManager.shared
    @State private var showSignUpSheet = false
    
    var body: some View {
        ZStack {
            // Pozadina
            Color(red: 0.93, green: 0.93, blue: 0.93) // #ededed
                .ignoresSafeArea()

            // Plavi cvet
            Image("SplashFlowerBlue")
                .resizable()
                .frame(width: 277, height: 552)
                .rotationEffect(.degrees(169.341))
                .scaleEffect(x: 1, y: -1)
                .blur(radius: 8)
                .position(x: 184 + 277/2, y: 415 + 552/2)

            // Crveni cvet
            Image("SplashFlowerRed")
                .resizable()
                .frame(width: 294, height: 504)
                .rotationEffect(.degrees(13.603))
                .blur(radius: 8)
                .position(x: -170 + 294/2, y: 399 + 504/2)

            // SVG Union (crni talas na dnu)
            VStack {
                Spacer()
                SplashBottomWave()
                    .frame(width: 440, height: 152)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Centered Header and Paragraph
            VStack(spacing: 20) {
                Text("SET YOUR\nBIGGEST GOAL")
                    .font(.custom("Thunder-BoldLC", size: 82))
                    .fontWeight(.black)
                    .foregroundColor(.black)
                    .tracking(0.82)
                    .multilineTextAlignment(.center)
                    .frame(width: 400)

                Text("This will be your main focus for the next 30 days. You can always change it later.")
                    .font(.custom("Inter_28pt-Regular", size: 14))
                    .foregroundColor(.black.opacity(0.7))
                    .tracking(-0.56)
                    .frame(width: 277)
                    .multilineTextAlignment(.center)
            }
            .position(x: 220, y: 478) // Centered vertically

            // North Star brend
            Text("North Star")
                .font(.custom("TrashHand", size: 32))
                .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                .tracking(-0.32)
                .position(x: 220, y: 599 + 16)

            // Dugmad
            HStack(spacing: 16) {
                Button(action: {
                    showSignUpSheet = true
                }) {
                    Text("Sign Up")
                        .font(.custom("Inter_28pt-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(width: 162, height: 56)
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
                        .frame(width: 222, height: 56)
                        .background(Color.white)
                        .cornerRadius(100)
                        .tracking(-0.64)
                }
            }
            .frame(width: 440, height: 56)
            .position(x: 220, y: 956 - 30 - 28)
        }
        .frame(width: 440, height: 956)
        .sheet(isPresented: $showSignUpSheet) {
            SignUpSheetView()
        }
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