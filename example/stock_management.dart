import 'package:davi/davi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class Data {
  Data(
      {required this.product,
      required this.category,
      required this.stock,
      required this.stockLimit,
      required this.price});

  final String product;
  final String category;
  final int stock;
  final int stockLimit;
  final int price;

  double get stockStatus => stock / stockLimit;
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Management',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DaviModel<Data> _model;

  @override
  void initState() {
    super.initState();
    _buildModel();
  }

  void _buildModel() {
    List<Data> rows = [
      Data(
          product: 'Laptop',
          category: 'Electronics',
          stock: 60,
          stockLimit: 100,
          price: 1200),
      Data(
          product: 'Office Chair',
          category: 'Furniture',
          stock: 2,
          stockLimit: 10,
          price: 150),
      Data(
          product: 'Wireless Mouse',
          category: 'Accessories',
          stock: 15,
          stockLimit: 200,
          price: 25),
      Data(
          product: 'Coffee Table',
          category: 'Furniture',
          stock: 2,
          stockLimit: 10,
          price: 70),
      Data(
          product: 'Air Conditioner',
          category: 'Appliances',
          stock: 10,
          stockLimit: 50,
          price: 300),
      Data(
          product: 'Smartwatch',
          category: 'Electronics',
          stock: 25,
          stockLimit: 100,
          price: 200)
    ];

    _model = DaviModel<Data>(
        rows: rows,
        columns: [
          DaviColumn(
              name: 'Product', cellValue: (params) => params.data.product),
          DaviColumn(
              name: 'Category', cellValue: (params) => params.data.category),
          DaviColumn(
              name: 'Price',
              cellValue: (params) => params.data.price,
              cellValueStringify: (value) => '\$$value'),
          DaviColumn(
              cellPadding: const EdgeInsets.all(4),
              name: 'Stock',
              cellBarValue: (params) => params.data.stockStatus,
              cellBarValueStringify: (params) =>
                  '${params.data.stock}/${params.data.stockLimit}',
              cellBarStyle: CellBarStyle(
                  barBackground: Colors.transparent,
                  barForeground: (value) {
                    value = value.clamp(0.0, 1.0);
                    return Color.lerp(Colors.grey, Colors.green, value)!;
                  }))
        ],
        multiSortEnabled: true);
  }

  @override
  Widget build(BuildContext context) {
    DaviTheme theme = DaviTheme(
        data: DaviThemeData(
            row: RowThemeData(
              fillHeight: true,
              color: RowThemeData.zebraColor(),
              hoverForeground: (index) =>
                  Colors.blue[300]!.withValues(alpha: .2),
            ),
            cell: CellThemeData(nullValueColor: (index, hover) => Colors.grey)),
        child: Davi<Data>(_model,
            columnWidthBehavior: ColumnWidthBehavior.fit, visibleRowsCount: 6));

    return Scaffold(
        body: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(32),
            child: theme));
  }
}
