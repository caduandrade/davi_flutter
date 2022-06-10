import 'package:flutter/widgets.dart';

class TableScrollControllers {
  ScrollController unpinnedContentArea = ScrollController();
  ScrollController vertical = ScrollController();

  double get unpinnedContentAreaOffset {
    return unpinnedContentArea.hasClients ? unpinnedContentArea.offset : 0;
  }

  double get verticalOffset {
    return vertical.hasClients ? vertical.offset : 0;
  }

  void addListener(VoidCallback listener) {
    unpinnedContentArea.addListener(listener);
    vertical.addListener(listener);
  }

  void dispose() {
    unpinnedContentArea.dispose();
    vertical.dispose();
  }
}
