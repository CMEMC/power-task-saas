import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String orgId = "DEMO_ORG_123"; // Logic for multi-tenancy

  // Controllers for the Dialog input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _csiController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  // Function to show the "Rugged Utility" Task Entry Dialog
  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E), // Dark theme
        title: Text("NEW FIELD TASK", 
          style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_titleController, "Task Name (e.g. Plate Layout)"),
              _buildTextField(_csiController, "CSI Code (e.g. 06 11 00)"),
              _buildTextField(_budgetController, "Allocated Budget (\$)", isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700]),
            onPressed: () {
              _saveTaskToFirestore();
              Navigator.pop(context);
            },
            child: Text("CREATE TASK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Industrial Input Field Widget
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white60),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow[700]!)),
        ),
      ),
    );
  }

  // The SaaS Database Logic
  Future<void> _saveTaskToFirestore() async {
    if (_titleController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('tasks_instances').add({
      "org_id": orgId,
      "title": _titleController.text,
      "csi_code": _csiController.text,
      "budget_allocated": double.tryParse(_budgetController.text) ?? 0.0,
      "actual_cost_to_date": 0.0, // New tasks start at zero actuals
      "isDone": false,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Clear controllers after save
    _titleController.clear();
    _csiController.clear();
    _budgetController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('POWER TASK: FIELD LOG', 
          style: TextStyle(fontWeight: FontWeight.black, letterSpacing: 1.5)),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks_instances')
            .where('org_id', isEqualTo: orgId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var task = snapshot.data!.docs[index];
              return _buildTaskCard(task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.yellow[700],
        icon: Icon(Icons.add, color: Colors.black),
        label: Text("NEW TASK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTaskCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    double budget = (data['budget_allocated'] ?? 0.0).toDouble();
    double actual = (data['actual_cost_to_date'] ?? 0.0).toDouble();
    double variance = budget - actual;
    
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: variance < 0 ? Colors.red : Colors.greenAccent, width: 2),
      ),
      child: ListTile(
        title: Text(data['title']?.toUpperCase() ?? 'NEW TASK', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        subtitle: Text("CSI: ${data['csi_code'] ?? 'N/A'} • Variance: \$${variance.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}