import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../../../models/order.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrdersList>(
      future: Future(
            () async {
          return await OrdersList.getAllOrders();
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: const TextStyle(fontSize: 18),
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data != null) {
              return OrdersListWidget(
                orders: snapshot.data!,
              );
            } else {
              return Text(
                "Ocurrió un error",
                style: Theme.of(context).textTheme.headline1,
              );
            }
          }
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class OrdersListWidget extends StatefulWidget {
  final OrdersList orders;
  const OrdersListWidget({required this.orders, super.key});

@override
OrdersListWidgetState createState() => OrdersListWidgetState();
}

class OrdersListWidgetState extends State<OrdersListWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 8.0,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    "Órdenes",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => FutureProgressDialog(
                    Future(
                          () async {
                        widget.orders.orders =
                            (await OrdersList.getAllOrders()).orders;
                        setState(() {});
                      },
                    ),
                    message: Text(
                      'Actualizando Lista...',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.refresh,
                color: Colors.white.withOpacity(0.90),
              ),
              label: Text(
                "Actualizar",
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          ),
          SizedBox(
            height: 750,
            child: ListView.builder(
              itemCount: widget.orders.orders.length,
              itemBuilder: (context, index) {
                String title = "Órden: ${widget.orders.orders[index].orderId}";
                String subtitle =
                widget.orders.orders[index].descriptionOrder();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      title: Text(title),
                      subtitle: Text(subtitle),
                      trailing: widget.orders.orders[index].delivery == null
                          ? const Icon(
                        Icons.warning,
                        color: Colors.yellow,
                        size: 35,
                      )
                          : const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 35,
                      ),
                      onTap: widget.orders.orders[index].delivery != null
                          ? null
                          : () {
                        Navigator.pushNamed(context, "/deliveryform",
                            arguments: widget.orders.orders[index])
                            .then(
                              (value) {
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
