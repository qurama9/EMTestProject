import SwiftUI

struct TaskRow: View {
    
//    MARK: - Properties
    var model: TaskEntity
    let action: () -> ()
    @Binding var selectedTask: TaskEntity?
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        HStack {
            
            //                MARK: - Toggle Button
            VStack {
                Button {
                    action()
                } label: {
                    Image(systemName: model.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(Color.yellowColor)
                        .font(.title)
                }
                .buttonStyle(.borderless)
                Spacer()
            }
            
            //            MARK: - Task Name
            VStack(alignment: .leading, spacing: 6) {
                if model.isCompleted {
                    Text(model.title ?? "")
                        .strikethrough()
                        .foregroundStyle(Color.toDoPrimary.opacity(0.5))
                        .font(.callout)
                } else {
                    Text(model.title ?? "")
                        .foregroundStyle(Color.toDoPrimary)
                        .font(.callout)
                }
                
                //            MARK: - Task Description
                Text(model.taskDescription ?? "")
                    .font(.caption)
                    .foregroundStyle(model.isCompleted ? .toDoPrimary.opacity(0.5) : .toDoPrimary)
                
                
                //            MARK: - Task Create Date
                Text(formattedDate(model.date ?? Date()))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        
//        MARK: - Context Menu
        .contextMenu {
            Button {
                selectedTask = model
            } label: {
                Label("Редактировать", systemImage: "square.and.pencil")
            }
            Button {
                viewModel.shareTask(task: model)
            } label: {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            Button(role: .destructive) {
                viewModel.deleteTask(task: model)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
    
//    MARK: - Methods
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.shared.container.viewContext
    let task = TaskEntity(context: context)
    task.title = "Пример задачи"
    task.taskDescription = "Описание задачи"
    task.isCompleted = false
    task.date = Date()
    
    @State var selectedTaskPreview: TaskEntity? = nil
    let viewModel = TaskViewModel()

    return List {
        TaskRow(
            model: task,
            action: {},
            selectedTask: .constant(nil),
            viewModel: viewModel
        )
    }
    .environment(\.managedObjectContext, context)
    .preferredColorScheme(.dark)
}
