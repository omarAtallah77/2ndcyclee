import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:untitled/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user stream
  /*

  * Streams a list of users with whom the current user has a chat room.
  * Filters the chat_rooms collection to find rooms where the current user is a participant.
    For each room, retrieves all participants except the current user.
  * Fetches details of each participant from the Users collection and returns a list of user data.

   */
  Stream<List<Map<String, dynamic>>> getUserStream() {
    final currentUserID = _auth.currentUser!.uid;

    return _firestore.collection("chat_rooms")
        .where("participants", arrayContains: currentUserID)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> users = [];

      for (var doc in snapshot.docs) {
        List<String> participants = List<String>.from(doc.data()["participants"]);

        for (String participantID in participants) {
          if (participantID != currentUserID) {
            var userSnapshot = await _firestore.collection("Users").doc(participantID).get();
            if (userSnapshot.exists) {
              users.add(userSnapshot.data()!);
            }
          }
        }
      }
      return users;
    });
  }

  // Send a message to a specific user
  Future<void> sendMessages(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Add the new message to the database
    await _firestore.collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // Get messages for a specific chat room
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }



}
