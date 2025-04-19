import 'package:lktaskmanagementapp/packages/headerfiles.dart';

Future<void> showCustomAlertDialog(
    BuildContext context, {
      String? title,
      Widget? titleWidget,
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
      Widget buildTitle() {
        if (titleWidget != null) {
          return titleWidget!;
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: titleFontWeight,
                    fontSize: titleFontSize,
                  ),
                ),
              if (additionalTitleContent != null) additionalTitleContent!,
            ],
          );
        }
      }

      Widget dialogContent = Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: titleHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF005296),
                ),
                padding: EdgeInsets.only(
                  top: titleTopPadding,
                  left: 15,
                  right: 15,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: buildTitle(),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: titleColor, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(child: content),
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
      );

      if (isFullScreen) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: dialogContent,
          ),
        );
      } else {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.zero,
          title: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: titleHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF005296),
                  borderRadius: const BorderRadius.only(
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
                  child: buildTitle(),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: titleColor, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
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

