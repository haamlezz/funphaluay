import 'package:flutter/material.dart';

class Headder extends StatelessWidget {
  const Headder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text(
            "ຝັນພາລວຍ",
            style: TextStyle(color: Colors.white, fontSize: 50),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "ສານຝັນໃຫ້ເປັນຈິງ",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
