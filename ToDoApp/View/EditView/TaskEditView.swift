import SwiftUI

struct TaskEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var task: TaskEntity

    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Редактирование")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .topLeading) {
                        Button("Отмена") {
                            dismiss()
                        }
                        .foregroundStyle(Color.yellowColor)
                    }
                    .padding(.vertical)
            }

            // MARK: - Task Name
            TextField("Название задачи...", text: $taskTitle)
                .padding()
                .background(Color(.systemGray4))
                .cornerRadius(10)

            // MARK: - Task Description
            TextField("Описание задачи...", text: $taskDescription, axis: .vertical)
                .padding()
                .background(Color(.systemGray4))
                .cornerRadius(10)
                .lineLimit(3, reservesSpace: true)

            CustomButton(placeholder: "Сохранить") {
                task.title = taskTitle
                task.taskDescription = taskDescription
                task.date = Date()

                do {
                    try viewContext.save()
                    dismiss()
                } catch {
                    print("Ошибка при сохранении задачи: \(error.localizedDescription)")
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            taskTitle = task.title ?? ""
            taskDescription = task.taskDescription ?? ""
        }
    }
}
//    MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = TaskEntity(context: context)
    task.title = "Пример"
    task.taskDescription = "Описание"
    task.date = Date()
    task.isCompleted = false

    return TaskEditView(task: task)
        .environment(\.managedObjectContext, context)
        .preferredColorScheme(.dark)
}
