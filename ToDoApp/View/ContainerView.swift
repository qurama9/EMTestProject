import SwiftUI

struct ContainerView: View {
    
    @State private var isLaunchScreenViewPresented = true
    var body: some View {
        if !isLaunchScreenViewPresented {
            ContentView()
        } else {
            LaunchScreen(isPresented: $isLaunchScreenViewPresented)
        }
    }
}

#Preview {
    ContainerView()
}
