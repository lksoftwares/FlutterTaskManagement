// import 'package:flutter/material.dart';
//
// class NoDataFoundScreen extends StatelessWidget {
//   const NoDataFoundScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(height: 200),
//           Text(
//             'No results found 😞',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           SizedBox(height: 10),
//           Text(
//             'Try searching with a different term.',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class NoDataFoundScreen extends StatefulWidget {
  const NoDataFoundScreen({super.key});

  @override
  _NoDataFoundScreenState createState() => _NoDataFoundScreenState();
}

class _NoDataFoundScreenState extends State<NoDataFoundScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 200),
          FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              'No results found 😞',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(height: 10),
          FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              'Try searching with a different term.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
