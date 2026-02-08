import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskRepository _repository = TaskRepository();
  
  // Get the current logged-in user
  final User currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${currentUser.displayName ?? 'User'}!'),
        actions: [
          // Sign Out Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        // WE USE THE USER'S ID AS THE "ORG ID"
        // This means every user has their own private list!
        stream: _repository.streamTasksForOrg(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text('You have no tasks. Add one!'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.status.name),
                  trailing: Checkbox(
                    value: task.status == TaskStatus.done,
                    onChanged: (val) {
                      final newStatus = val == true ? TaskStatus.done : TaskStatus.todo;
                      _repository.updateStatus(currentUser.uid, task.id, newStatus);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTask() {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Task ${DateTime.now().second}',
      description: '',
      status: TaskStatus.todo,
      assignedUserId: currentUser.uid,
      organizationId: currentUser.uid, // Save to THIS user's list
      createdAt: DateTime.now(),
    );
    _repository.createTask(newTask);
  }
}