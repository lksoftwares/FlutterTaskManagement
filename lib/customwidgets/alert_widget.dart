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
      bool isFullScreen = true,
    }) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      if (isFullScreen) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),

              ),
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: titleHeight,
                      decoration: BoxDecoration(
                        color: Color(0xFF005296),

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
                            if (additionalTitleContent != null)
                              additionalTitleContent,
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
                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    child: content,
                  ),
                ),
                if (actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ),
              ],
            ),
          ),
        );
      } else {
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
                      if (additionalTitleContent != null)
                        additionalTitleContent,
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
      }
    },
  );
}
