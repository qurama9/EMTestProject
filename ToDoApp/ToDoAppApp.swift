import SwiftUI

@main
struct ToDoAppApp: App {
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @StateObject var viewModel = TaskViewModel()
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContainerView()
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
