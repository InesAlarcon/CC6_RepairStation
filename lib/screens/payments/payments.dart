import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../../../models/payment.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Payments>(
      future: Future(
            () async {
          return await Payments.getPayments();
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
              return PaymentsList(
                payments: snapshot.data!,
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

class PaymentsList extends StatefulWidget {
  final Payments payments;
  const PaymentsList({required this.payments, super.key});

@override
PaymentsListState createState() => PaymentsListState();
}

class PaymentsListState extends State<PaymentsList> {
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
                    "Pagos",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => FutureProgressDialog(
                        Future(
                              () async {
                            widget.payments.payments =
                                (await Payments.getPayments()).payments;
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
              ],
            ),
          ),
          SizedBox(
            height: 750,
            child: ListView.builder(
              itemCount: widget.payments.payments.length,
              itemBuilder: (context, index) {
                String title =
                    "Order ID: ${widget.payments.payments[index].orderId}";
                String subtitle =
                    "ID de Pago:${widget.payments.payments[index].paymentId}";
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      title: Text(title),
                      subtitle: Text(subtitle),
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
