import SwiftUI

struct NoTasksView: View {
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("У ВАС НЕТ ЗАДАЧ.\nЖЕЛАЕТЕ ДОБАВИТЬ ЗАДАЧУ?")
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundStyle(Color.primaryColor)
                .opacity(0.5)
            
            Spacer()
        }
    }
}

#Preview {
    NoTasksView()
}
