import 'package:easy_table/src/experimental/table_callbacks.dart';
import 'package:easy_table/src/experimental/table_layout_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Experimental',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    TableLayoutSettings layoutSettings = TableLayoutSettings(
        visibleRowsCount: null,
        rowHeight: 32,
        hasHeader: true,
        headerHeight: 32,
        hasScrollbar: true,
        scrollbarHeight: 20);
    TablePaintSettings paintSettings = TablePaintSettings(debugAreas: true);
    TableCallbacks callbacks = TableCallbacks(
        onTap: _onTap,
        onDragStart: _onDragStart,
        onDragUpdate: _onDragUpdate,
        onDragEnd: _onDragEnd);
    Widget body = TableLayoutExp(
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        callbacks: callbacks,
        children: const []);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Experimental'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(64),
            child: Container(
                decoration: BoxDecoration(border: Border.all()), child: body)));
  }

  void _onTap() {
    print('_onTap');
  }

  void _onDragStart(DragStartDetails details) {
    print('_onDragStart: ${details.localPosition}');
  }

  void _onDragUpdate(DragUpdateDetails details) {
    print('_onDragUpdate: ${details.localPosition}');
  }

  void _onDragEnd(DragEndDetails details) {
    print('_onDragEnd: $details');
  }
}
