import 'package:flutter/widgets.dart';

class TableScrollControllers {
  ScrollController unpinnedContentArea = ScrollController();

  double get unpinnedContentAreaOffset {
    if (unpinnedContentArea.hasClients) {
      return unpinnedContentArea.offset;
    }
    return 0;
  }

  void addListener(VoidCallback listener) {
    unpinnedContentArea.addListener(listener);
  }

  void dispose() {
    unpinnedContentArea.dispose();
  }
}
