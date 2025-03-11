//working code

// import 'package:flutter/material.dart';
//
// Future<void> showCustomAlertDialog(
//     BuildContext context, {
//       String title = "Title",
//       Widget content = const Text("content here."),
//       required List<Widget> actions,
//       InputDecoration? inputDecoration,
//       double titleFontSize = 25.0,
//       FontWeight titleFontWeight = FontWeight.bold,
//       bool showYesButton = false,
//       bool showNoButton = false,
//       bool showCancelButton = false,
//       Function? onYesPressed,
//       Function? onNoPressed,
//       Function? onCancelPressed,
//       String yesButtonText = "Yes",
//       String noButtonText = "No",
//       String cancelButtonText = "Cancel",
//       IconData? yesIcon,
//       IconData? noIcon,
//       IconData? cancelIcon,
//     }) async {
//   List<Widget> dialogActions = [];
//
//   Widget _buildTextButton(String buttonText, Function? onPressedCallback, BuildContext context) {
//     return TextButton(
//       onPressed: () {
//         if (onPressedCallback != null) {
//           onPressedCallback();
//         }
//       },
//       child: Text(buttonText),
//     );
//   }
//
//   Widget _buildIconButton(IconData icon, Function? onPressedCallback, BuildContext context) {
//     return IconButton(
//       onPressed: () {
//         if (onPressedCallback != null) {
//           onPressedCallback();
//         }
//       },
//       icon: Icon(icon),
//     );
//   }
//
//   // Add cancel button with IconButton or TextButton
//   if (showCancelButton) {
//     if (cancelIcon != null) {
//       dialogActions.add(_buildIconButton(cancelIcon, onCancelPressed, context));
//     } else {
//       dialogActions.add(_buildTextButton(cancelButtonText, onCancelPressed, context));
//     }
//   }
//
//   if (showNoButton) {
//     if (noIcon != null) {
//       dialogActions.add(_buildIconButton(noIcon, onNoPressed, context));
//     } else {
//       dialogActions.add(_buildTextButton(noButtonText, onNoPressed, context));
//     }
//   }
//
//   if (showYesButton) {
//     if (yesIcon != null) {
//       dialogActions.add(_buildIconButton(yesIcon, onYesPressed, context));
//     } else {
//       dialogActions.add(_buildTextButton(yesButtonText, onYesPressed, context));
//     }
//   }
//
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Align(
//           alignment: Alignment.center,
//           child: Text(
//             title,
//             style: TextStyle(
//               fontSize: titleFontSize,
//               fontWeight: titleFontWeight,
//             ),
//           ),
//         ),
//         content: content,
//         actions: dialogActions,
//       );
//     },
//   );
// }
//
// void showMyCustomDialog(
//     BuildContext context, {
//       String? title,
//       Widget? content,
//       bool showYesButton = false,
//       bool showNoButton = false,
//       bool showCancelButton = false,
//       Function? onYesPressed,
//       Function? onNoPressed,
//       Function? onCancelPressed,
//       String yesButtonText = "Yes",
//       String noButtonText = "No",
//       String cancelButtonText = "Cancel",
//       IconData? yesIcon,
//       IconData? noIcon,
//       IconData? cancelIcon,
//     }) {
//   showCustomAlertDialog(
//     context,
//     actions: [],
//     showYesButton: showYesButton,
//     showNoButton: showNoButton,
//     showCancelButton: showCancelButton,
//     onYesPressed: onYesPressed,
//     onNoPressed: onNoPressed,
//     onCancelPressed: onCancelPressed,
//     yesButtonText: yesButtonText,
//     noButtonText: noButtonText,
//     cancelButtonText: cancelButtonText,
//     yesIcon: yesIcon,
//     noIcon: noIcon,
//     cancelIcon: cancelIcon,
//   );
// }
//
// class Shreya extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Alert Dialog")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             showMyCustomDialog(
//               context,
//               title: "Shreya",
//               content: Text("Hey, good morning"),
//               showYesButton: true,
//               showNoButton: true,
//               showCancelButton: true,
//               yesButtonText: "Agree",
//               noButtonText: "Disagree",
//               cancelButtonText: "Close",
//
//               onYesPressed: () {
//                 print("Agree button pressed");
//               },
//               onNoPressed: () {
//                 print("Disagree button pressed");
//               },
//               onCancelPressed: () {
//                 print("Close button pressed");
//               },
//             );
//           },
//           child: Text("Show Dialog"),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
//
// Future<void> showCustomAlertDialog(
//     BuildContext context, {
//       String title = "Title",
//       Widget content = const Text("content here."),
//       required List<Widget> actions,
//       InputDecoration? inputDecoration,
//       double titleFontSize = 25.0,
//       FontWeight titleFontWeight = FontWeight.bold,
//       bool showYesButton = false,
//       bool showNoButton = false,
//       bool showCancelButton = false,
//       Function? onYesPressed,
//       Function? onNoPressed,
//       Function? onCancelPressed,
//     }) async {
//
//   List<Widget> dialogActions = [];
//
//   Widget _buildDialogButton(
//       String buttonText,
//       Function? onPressedCallback,
//       BuildContext context,
//       ) {
//     return TextButton(
//       onPressed: () {
//         if (onPressedCallback != null) {
//           onPressedCallback();
//         }
//       },
//       child: Text(buttonText),
//     );
//   }
//   if (showCancelButton) {
//     dialogActions.add(
//       _buildDialogButton("Cancel", onCancelPressed, context),
//     );
//   }
//   if (showNoButton) {
//     dialogActions.add(
//       _buildDialogButton("No", onNoPressed, context),
//     );
//   }
//   if (showYesButton) {
//     dialogActions.add(
//       _buildDialogButton("Yes", onYesPressed, context),
//     );
//   }
//
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Align(
//           alignment: Alignment.center,
//           child: Text(
//             title,
//             style: TextStyle(
//               fontSize: titleFontSize,
//               fontWeight: titleFontWeight,
//             ),
//           ),
//         ),
//         content: content,
//         actions: dialogActions,
//       );
//     },
//   );
// }
//
//
//
// void showMyCustomDialog(BuildContext context, {
//   String? title,
//   Widget? content,
//   bool showYesButton = false,
//   bool showNoButton = false,
//   bool showCancelButton = false,
//   Function? onYesPressed,
//   Function? onNoPressed,
//   Function? onCancelPressed,
// }) {
//   showCustomAlertDialog(
//     context,
//     actions: [],
//     showYesButton: showYesButton,
//     showNoButton: showNoButton,
//     showCancelButton: showCancelButton,
//     onYesPressed: onYesPressed,
//     onNoPressed: onNoPressed,
//     onCancelPressed: onCancelPressed,
//   );
// }
//
// class Shreya extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Alert Dialog")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             showMyCustomDialog(
//               context,
//               title: "Shreya",
//               content: Text("Hey, good morning"),
//               showYesButton: true,
//               showNoButton: true,
//               showCancelButton: true,
//               onYesPressed: () {
//                 print("Yes button pressed");
//               },
//               onNoPressed: () {
//                 print("No button pressed");
//               },
//               onCancelPressed: () {
//                 print("Cancel button pressed");
//               },
//             );
//           },
//           child: Text("Show Dialog"),
//         ),
//       ),
//     );
//   }
// }


import 'package:lktaskmanagementapp/packages/headerfiles.dart';

Future<void> showCustomAlertDialog(
    BuildContext context, {
      required String title,
      required Widget content,
      required List<Widget> actions,
      InputDecoration? inputDecoration,
      double titleFontSize = 25.0,
      FontWeight titleFontWeight = FontWeight.bold,
      Color titleColor = Colors.white,
      Widget? additionalTitleContent,
      double titleHeight = 102,
      double titleTopPadding = 13.0,
    }) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.all(0),
        title: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: titleHeight,
              decoration: BoxDecoration(
                color: Color(0xFF005296),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                top: titleTopPadding,
                left: 15,
                right: 15,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: titleFontWeight,
                        fontSize: titleFontSize,
                      ),
                    ),
                    if (additionalTitleContent != null) additionalTitleContent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: titleColor,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
        content: content,
        actions: actions,
      );
    },
  );
}
