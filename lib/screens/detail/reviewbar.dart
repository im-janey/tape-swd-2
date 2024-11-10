import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/detail/Rating.dart';
import 'package:flutter_application_1/screens/detail/reviewList.dart';

class ReviewPage extends StatefulWidget {
  final String collectionName;
  final String id;
  final Map<String, String> ratingFields;

  const ReviewPage({
    super.key,
    required this.collectionName,
    required this.id,
    required this.ratingFields,
  });

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<String> _getDownloadUrl(String imageUrl) async {
    if (imageUrl.startsWith('gs://')) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        return await ref.getDownloadURL();
      } catch (e) {
        print('Failed to get download URL: $e');
        return '';
      }
    } else {
      return imageUrl;
    }
  }

  Future<void> _loadUserProfile() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String imageUrl = userData['image'] ?? '';
      imageUrl = await _getDownloadUrl(imageUrl);

      setState(() => _profileImageUrl = imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: _profileImageUrl.isNotEmpty
                  ? NetworkImage(_profileImageUrl)
                  : null,
              child: _profileImageUrl.isEmpty ? Icon(Icons.person) : null,
            ),
            SizedBox(width: 15),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Rating(
                    collectionName: widget.collectionName,
                    id: widget.id,
                    ratingFields: widget.ratingFields,
                  ),
                ),
              ),
              child: SizedBox(
                width: 130,
                height: 30,
                child: Image.asset('assets/rating1.png'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: ReviewList(
            //작성화면
            collectionName: widget.collectionName,
            id: widget.id,
          ),
        ),
      ],
    );
  }
}
