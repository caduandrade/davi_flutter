import 'package:flutter/widgets.dart';

class TableScrollControllers {
  ScrollController leftPinnedContentArea = ScrollController();
  ScrollController unpinnedContentArea = ScrollController();
  ScrollController vertical = ScrollController();

  double get leftPinnedContentAreaOffset {
    return leftPinnedContentArea.hasClients ? leftPinnedContentArea.offset : 0;
  }

  double get unpinnedContentAreaOffset {
    return unpinnedContentArea.hasClients ? unpinnedContentArea.offset : 0;
  }

  double get verticalOffset {
    return vertical.hasClients ? vertical.offset : 0;
  }

  void addListener(VoidCallback listener) {
    leftPinnedContentArea.addListener(listener);
    unpinnedContentArea.addListener(listener);
    vertical.addListener(listener);
  }

  void dispose() {
    leftPinnedContentArea.dispose();
    unpinnedContentArea.dispose();
    vertical.dispose();
  }
}
