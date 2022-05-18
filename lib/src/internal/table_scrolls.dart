import 'dart:math' as math;
import 'package:easy_table/src/internal/scroll_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TableScrolls {
  factory TableScrolls(
      {ScrollController? unpinnedHorizontal,
      ScrollController? pinnedHorizontal,
      ScrollController? vertical}) {
    AreaScrolls pinnedArea = AreaScrolls(
        horizontal: pinnedHorizontal ?? EasyTableScrollController());
    AreaScrolls unpinnedArea = AreaScrolls(
        horizontal: unpinnedHorizontal ?? EasyTableScrollController());
    return TableScrolls._(
        pinnedArea: pinnedArea,
        unpinnedArea: unpinnedArea,
        vertical: vertical ?? EasyTableScrollController());
  }

  TableScrolls._(
      {required this.pinnedArea,
      required this.unpinnedArea,
      required ScrollController vertical})
      : _vertical = vertical {
    _addVerticalListeners();
  }

  final AreaScrolls pinnedArea;
  final AreaScrolls unpinnedArea;

  ScrollController _vertical;

  ScrollController get vertical => _vertical;

  set vertical(ScrollController vertical) {
    _removeVerticalListeners();
    _vertical = vertical;
    _addVerticalListeners();
  }

  void removeListeners() {
    _removeVerticalListeners();
    pinnedArea._removeHorizontalListeners();
    unpinnedArea._removeHorizontalListeners();
  }

  void _removeVerticalListeners() {
    _vertical.removeListener(_onVerticalChange);
    pinnedArea.contentVertical.removeListener(_onPinnedVerticalChange);
    unpinnedArea.contentVertical.removeListener(_onUnpinnedVerticalChange);
  }

  void _addVerticalListeners() {
    _vertical.addListener(_onVerticalChange);
    pinnedArea.contentVertical.addListener(_onPinnedVerticalChange);
    unpinnedArea.contentVertical.addListener(_onUnpinnedVerticalChange);
  }

  /// used to avoid circular calls
  bool _ignore = false;

  void _onVerticalChange() {
    if (_ignore) {
      return;
    }
    _ignore = true;
    if (_vertical.hasClients) {
      if (pinnedArea.contentVertical.hasClients) {
        pinnedArea.contentVertical.jumpTo(math.min(_vertical.offset,
            pinnedArea.contentVertical.position.maxScrollExtent));
      }
      if (unpinnedArea.contentVertical.hasClients) {
        unpinnedArea.contentVertical.jumpTo(math.min(_vertical.offset,
            unpinnedArea.contentVertical.position.maxScrollExtent));
      }
    }
    _ignore = false;
  }

  void _onPinnedVerticalChange() {
    if (_ignore) {
      return;
    }
    _ignore = true;
    if (pinnedArea.contentVertical.hasClients) {
      if (_vertical.hasClients) {
        _vertical.jumpTo(pinnedArea.contentVertical.offset);
      }
      if (unpinnedArea.contentVertical.hasClients) {
        unpinnedArea.contentVertical.jumpTo(pinnedArea.contentVertical.offset);
      }
    }
    _ignore = false;
  }

  void _onUnpinnedVerticalChange() {
    if (_ignore) {
      return;
    }
    _ignore = true;
    if (unpinnedArea.contentVertical.hasClients) {
      if (_vertical.hasClients) {
        _vertical.jumpTo(unpinnedArea.contentVertical.offset);
      }
      if (pinnedArea.contentVertical.hasClients) {
        pinnedArea.contentVertical.jumpTo(unpinnedArea.contentVertical.offset);
      }
    }
    _ignore = false;
  }
}

class AreaScrolls {
  AreaScrolls({required ScrollController horizontal})
      : _horizontal = horizontal {
    _addHorizontalListeners();
  }

  final ScrollController contentVertical = ScrollController();

  final ScrollController headerHorizontal = ScrollController();
  final ScrollController contentHorizontal = ScrollController();

  bool _ignore = false;

  ScrollController _horizontal;

  ScrollController get horizontal => _horizontal;

  set horizontal(ScrollController horizontal) {
    _removeHorizontalListeners();
    _horizontal = horizontal;
    _addHorizontalListeners();
  }

  void _removeHorizontalListeners() {
    _horizontal.removeListener(_onHorizontalChange);
    headerHorizontal.removeListener(_onHeaderHorizontalChange);
    contentHorizontal.removeListener(_onContentHorizontalChange);
  }

  void _addHorizontalListeners() {
    _horizontal.addListener(_onHorizontalChange);
    headerHorizontal.addListener(_onHeaderHorizontalChange);
    contentHorizontal.addListener(_onContentHorizontalChange);
  }

  void _onHorizontalChange() {
    if (_ignore) {
      return;
    }
    _ignore = true;
    if (_horizontal.hasClients &&
        _horizontal.offset < _horizontal.position.maxScrollExtent) {
      if (headerHorizontal.hasClients) {
        headerHorizontal.jumpTo(_horizontal.offset);
      }
      if (contentHorizontal.hasClients) {
        contentHorizontal.jumpTo(_horizontal.offset);
      }
    }
    _ignore = false;
  }

  void _onHeaderHorizontalChange() {
    if (_ignore) {
      return;
    }

    _ignore = true;
    if (headerHorizontal.hasClients &&
        headerHorizontal.offset < headerHorizontal.position.maxScrollExtent) {
      if (_horizontal.hasClients) {
        _horizontal.jumpTo(headerHorizontal.offset);
      }
      if (contentHorizontal.hasClients) {
        contentHorizontal.jumpTo(headerHorizontal.offset);
      }
    }
    _ignore = false;
  }

  void _onContentHorizontalChange() {
    if (_ignore) {
      return;
    }
    _ignore = true;
    if (contentHorizontal.hasClients &&
        contentHorizontal.offset < contentHorizontal.position.maxScrollExtent) {
      if (headerHorizontal.hasClients) {
        headerHorizontal.jumpTo(contentHorizontal.offset);
      }
      if (_horizontal.hasClients) {
        _horizontal.jumpTo(contentHorizontal.offset);
      }
    }
    _ignore = false;
  }
}
