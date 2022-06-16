import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/drawer.dart';
import '../widgets/order_item.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders-screen";

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your orders!"),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: ordersData.orderlar.length,
        itemBuilder: (ctx, i) => OrderWidget(ordersData.orderlar[i]),
      ),
    );
  }
}
