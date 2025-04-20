import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""

    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Task Name
            TextField("Название задачи...", text: $taskTitle)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            // MARK: - Task Description
            TextField("Описание задачи...", text: $taskDescription, axis: .vertical)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .lineLimit(3, reservesSpace: true)

            // MARK: - Add Button
            CustomButton(placeholder: "Добавить задачу") {
                let newTask = TaskEntity(context: viewContext)
                newTask.id = UUID()
                newTask.title = taskTitle
                newTask.taskDescription = taskDescription
                newTask.isCompleted = false
                newTask.date = Date()

                do {
                    try viewContext.save()
                    dismiss()
                } catch {
                    print("Ошибка сохранения задачи: \(error.localizedDescription)")
                }
            }
            .disabled(taskTitle.isEmpty)

            Spacer()
        }
        .padding()
        .navigationTitle("Добавить задачу")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(Color.yellowColor)
                }
            }
        }
        .onAppear {
            taskTitle = ""
            taskDescription = ""
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        AddTaskView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .preferredColorScheme(.dark)
    }
}
