import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/course/make_cos.dart';

class Modal extends StatefulWidget {
  const Modal({super.key});

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  final TextEditingController _cosNameController = TextEditingController();

  Future<void> _saveCosName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cosName = _cosNameController.text.trim();
      if (cosName.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'cosname': cosName});
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MakeCosPage(),
            ),
          );
        } catch (e) {
          print('Error saving cos name: $e');
          // You might want to show an error message to the user here
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff5CCDD0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.flag,
            color: Colors.white,
            size: 35,
          ),
          SizedBox(height: 50)
        ],
      ),
      content: TextField(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        decoration: InputDecoration(
          hintText: '코스 이름을 입력하세요',
          hintStyle: const TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
        cursorColor: Colors.white,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            '취소',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _saveCosName;
          },
          child: Text(
            '설정',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
