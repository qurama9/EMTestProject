import SwiftUI
import UIKit

struct TaskListView: View {
    
//    MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText: String = ""
    @State private var selectedTask: TaskEntity?
    @StateObject private var viewModel = TaskViewModel()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<TaskEntity>

    // MARK: - Task Filter
    var filteredTasks: [TaskEntity] {
        if searchText.isEmpty {
            return Array(tasks)
        } else {
            return tasks.filter { task in
                (task.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                (task.taskDescription ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack {
                    
//                    MARK: - Search filter
                    TextField("Поиск", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    if filteredTasks.isEmpty {
                        NoTasksView()
                    } else {
                        
//                        MARK: Task List
                        List {
                            ForEach(filteredTasks) { task in
                                TaskRow(
                                    model: task,
                                    action: {
                                    withAnimation {
                                        task.isCompleted.toggle()
                                        try? viewContext.save()
                                    }
                                },
                                    selectedTask: $selectedTask,
                                    viewModel: viewModel
                                    )
                                .onTapGesture {
                                    selectedTask = task
                                }
                            }
                            .onDelete(perform: deleteTasks)
                        }
                        .listStyle(.plain)
                        .sheet(item: $selectedTask) { taskToEdit in
                            TaskEditView(task: taskToEdit)
                                .id(taskToEdit.objectID)
                        }
                        
//                        MARK: - Share View
                        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShareTask"))) { notification in
                            if let text = notification.userInfo?["text"] as? String {
                                let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                                
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    window.rootViewController?.present(av, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }

                // MARK: - Footer
                HStack {
                    Spacer().frame(width: 44)
                    
                    Text("У вас \(tasks.count) задач")
                        .foregroundColor(.white)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .center)

                    NavigationLink(destination: AddTaskView()) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.yellow)
                            .font(.title2)
                            .padding(8)
                    }
                }
                .padding()
                .background(Color(.systemGray5))
            }
            .navigationTitle("Задачи")
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredTasks[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

//MARK: - Preview
#Preview {
    TaskListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
}
