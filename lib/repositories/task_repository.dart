import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new task in the specific Organization's collection
  Future<void> createTask(Task task) async {
    // We use the organizationId to determine WHERE to save it
    final collectionPath = 'organizations/${task.organizationId}/tasks';
    
    await _firestore.collection(collectionPath).doc(task.id).set(task.toJson());
  }

  // Stream tasks live (Real-time updates)
  Stream<List<Task>> streamTasksForOrg(String orgId) {
    return _firestore
        .collection('organizations/$orgId/tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
    });
  }
  
  // Update status (e.g. dragging from Todo -> Done)
  Future<void> updateStatus(String orgId, String taskId, TaskStatus newStatus) async {
     await _firestore
        .collection('organizations/$orgId/tasks')
        .doc(taskId)
        .update({'status': newStatus.name}); // Storing enum as string
  }
}