import SwiftUI

struct LaunchScreen: View {
    
//    MARK: - Properties
    @Binding var isPresented: Bool
    @State var progress: CGFloat = 0.0
    @State private var scale = CGSize(width: 0.8, height: 0.8)
    
//    MARK: - Body
    var body: some View {
        ZStack {
            
//            MARK: - Background Color
            LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            
//                MARK: - Logo
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(20)
            
            
            VStack {
                
                //                MARK: - Launch Text
                Text("Test task by A.Ramazan")
                    .padding(.top, 200)
                    .font(.title)
                    .foregroundStyle(Color(.toDoPrimary))
                Spacer()
                
                //            MARK: - Progress View
                CustomProgressView(initialProgress: $progress, color: Color.toDoPrimary)
                    .frame(height: 8)
                    .onReceive([self.progress].publisher) { _ in
                        if self.progress >= 1.0 {
                            self.isPresented = false
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            self.startTimer()
        }
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { time in
            self.progress += 0.05
        }
    }
}

//MARK: - Preview
#Preview {
    LaunchScreen(isPresented: .constant(true))
        .preferredColorScheme(.dark)
}
