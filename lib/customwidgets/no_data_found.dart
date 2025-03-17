import 'package:flutter/material.dart';

class NoDataFoundScreen extends StatelessWidget {
  const NoDataFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          Image.asset(
            'images/nodata.jpg',
            width: 180,
            height: 180,
          ),
          SizedBox(height: 30),

          Text(
            'No results found 😞',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Try searching with a different term.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
