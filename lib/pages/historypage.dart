import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'billpage.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('buyHistory')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        // 'id': doc.id,
        'numberData': List<Map<String, dynamic>>.from(data['numbers']),
        'total': data['total'] as int,
        'timestamp': (data['timestamp'] as Timestamp).toDate(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ປະຫວັດການຊື້'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No purchase history.'));
          }

          final historyList = snapshot.data!;

          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              final dateFormatted = DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(history['timestamp']);

              return ListTile(
                title: Text('ວັນທີ: $dateFormatted'),
                subtitle: Text(
                    'ລວມທັງໝົດ: ${NumberFormat('#,###').format(history['total'])}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillPage(
                        numberData:
                            history['numberData'] as List<Map<String, dynamic>>,
                        total: history['total'],
                        timestamp: history['timestamp'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
