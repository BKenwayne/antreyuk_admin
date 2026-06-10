import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Helper to clear active queue for a patient in the Realtime Database
Future<void> clearUserActiveQueue(String queueKey) async {
  try {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
    final snapshot = await usersRef.get();
    if (snapshot.exists) {
      final usersData = snapshot.value;
      if (usersData is Map) {
        usersData.forEach((uid, userData) {
          if (userData is Map && userData['active_queue'] is Map) {
            final activeQueue = userData['active_queue'];
            if (activeQueue['queue_key'] == queueKey) {
              usersRef.child('$uid/active_queue').remove();
            }
          }
        });
      }
    }
  } catch (e) {
    debugPrint("Gagal menghapus active_queue user untuk key $queueKey: $e");
  }
}

/// Helper to update active queue status for a patient in the Realtime Database
Future<void> updateUserActiveQueueStatus(String queueKey, String status) async {
  try {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
    final snapshot = await usersRef.get();
    if (snapshot.exists) {
      final usersData = snapshot.value;
      if (usersData is Map) {
        usersData.forEach((uid, userData) {
          if (userData is Map && userData['active_queue'] is Map) {
            final activeQueue = userData['active_queue'];
            if (activeQueue['queue_key'] == queueKey) {
              usersRef.child('$uid/active_queue').update({'status': status});
            }
          }
        });
      }
    }
  } catch (e) {
    debugPrint("Gagal memperbarui status active_queue user untuk key $queueKey: $e");
  }
}
