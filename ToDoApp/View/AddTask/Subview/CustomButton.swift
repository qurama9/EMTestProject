import SwiftUI

struct CustomButton: View {

//    MARK: - Properties
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment (\.dismiss) private var dismiss
    var placeholder: String
    let action: () -> ()
    
//    MARK: - Body
    var body: some View {
        Button {
            action()
            dismiss()
        } label: {
            Text(placeholder)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellowColor)
                .foregroundColor(.backgroundColor)
                .cornerRadius(10)
        }
    }
}

//    MARK: - Preview
#Preview {
    CustomButton(placeholder: "Добавить задачу") {}
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
}
