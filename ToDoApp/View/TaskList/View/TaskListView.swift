import SwiftUI

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText: String = ""
    @State private var selectedTask: TaskEntity?

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
                                TaskRow(model: task) {
                                    withAnimation {
                                        task.isCompleted.toggle()
                                        try? viewContext.save()
                                    }
                                }
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
