import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:repair_station/models/order.dart';
import 'package:repair_station/models/crane.dart';
import 'package:repair_station/models/payment.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../models/my_repair_station.dart';
import 'package:http/http.dart' as http;

class DeliveryFormScreen extends StatelessWidget {
  final Order order;
  const DeliveryFormScreen({required this.order, super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "Formulario de Mensajero",
        style: Theme.of(context).textTheme.headline2,
      ),
      centerTitle: true,
      // leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
    ),
    body: FutureBuilder<Cranes>(
      future: Future(
            () async {
          return await Cranes.getCranes();
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
            return DeliveryForm(
              order: order,
              cranes: snapshot.data!,
            );
          }
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    ),
  );
}
}

class DeliveryForm extends StatefulWidget {
  final Order order;
  final Cranes cranes;
  const DeliveryForm({required this.order, required this.cranes, super.key});

@override
DeliveryFormState createState() => DeliveryFormState();
}

class DeliveryFormState extends State<DeliveryForm> {
  bool autoValidate = true;
  final _formKey = GlobalKey<FormBuilderState>();
  late List<String> craneNames;
  late String firstModel;

  void updateDropDowns() {
    craneNames = [];
    for (Crane crane in widget.cranes.cranes) {
      craneNames.add(crane.name);
    }
  }

  @override
  void initState() {
    super.initState();

    updateDropDowns();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              FormBuilder(
                key: _formKey,
                // enabled: false,
                onChanged: () {
                  _formKey.currentState!.save();
                  debugPrint(_formKey.currentState!.value.toString());
                },
                autovalidateMode: AutovalidateMode.always,
                skipDisabled: true,
                child: Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Card(
                            elevation: 4.0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              title: Text("Órden: ${widget.order.orderId}"),
                              subtitle: Text(widget.order.descriptionOrder()),
                              trailing:
                              const Icon(Icons.lock, color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderDropdown<Crane>(
                          name: 'crane',
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          items: widget.cranes.cranes
                              .map(
                                (crane) => DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: crane,
                              child: Text(crane.name),
                            ),
                          )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        debugPrint(_formKey.currentState?.value.toString());

                        String message = "";
                        AlertType alertType = AlertType.info;

                        final Crane chosenCrane =
                        _formKey.currentState?.value["crane"];

                        final Map orderData = {
                          'orderId' : widget.order.orderId,
                          'quantityArticles' : widget.order.totalItems,
                          'totalPrice' : widget.order.totalCost,
                          'totalWeight' : widget.order.totalWeight,
                          'pickupLatitud' : MyRepairStation.latitud,
                          'pickupLongitud' : MyRepairStation.longitud,
                          'pickupName': MyRepairStation.name,
                          'deliveryLatitud' : widget.order.clientLatitud,
                          'deliveryLongitud' : widget.order.clientLongitud,
                          'clientName': widget.order.clientName
                        };

                        String orderBody = json.encode(orderData);
                        debugPrint(orderBody);

                        int? operationResult = await showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => FutureProgressDialog(
                            Future<int?>(
                                  () async {
                                try {
                                  // ask to crane

                                  http.Response response = await http.post(
                                    Uri.parse(chosenCrane.url + '/delivery'),
                                    headers: {"Content-Type": "application/json"},
                                    body: orderBody,);

                                  // Process result
                                  if (response.statusCode == 404) {
                                    message =
                                    "Grúa no se encuentra disponible. Intente con otra";
                                    alertType = AlertType.warning;
                                  } else {
                                    if (response.statusCode != 200) {
                                      message =
                                      "Ocurrió un error con la comunicación con la grúa, intente de nuevo";
                                      alertType = AlertType.error;
                                    } else {
                                      widget.order.delivery = chosenCrane.name;
                                      widget.order.status = true;
                                      widget.order.estado = "true";

                                      bool updateResult =
                                      await Order.updateOrder(
                                          order: widget.order);
                                      message = updateResult
                                          ? "La orden ha sido procesada con éxito. ${chosenCrane.name} se encargará del envío"
                                          : "Ocurrió un error con la comunicación con la grúa, intente de nuevo";
                                      alertType = updateResult
                                          ? AlertType.info
                                          : AlertType.error;
                                    }
                                  }

                                  return 1;
                                } catch (e) {
                                  message =
                                  "Ocurrió un error al crear la petición. Intente de nuevo";
                                  alertType = AlertType.error;
                                  return -1;
                                }
                              },
                            ),
                            message: Text(
                              'Consultando Mensajería...',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        );

                        Alert(
                          context: context,
                          type: alertType,
                          title: "Warning",
                          desc: message,
                          buttons: [
                            DialogButton(
                              onPressed: () {
                                if (operationResult != null &&
                                    operationResult > 0) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(
                                "Cerrar",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                          ],
                        ).show();
                      } else {
                        debugPrint(_formKey.currentState?.value.toString());
                        debugPrint('validation failed');
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white.withOpacity(0.90),
                    ),
                    label: Text(
                      'Submit',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        debugPrint(_formKey.currentState?.value.toString());

                        String message = "";
                        AlertType alertType = AlertType.info;

                        final Crane chosenCrane =
                        _formKey.currentState?.value["crane"];

                        final Map orderData = {
                          'ordenID' : widget.order.orderId,
                        };

                        String orderBody = json.encode(orderData);

                        int? operationResult = await showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => FutureProgressDialog(
                            Future<int?>(
                                  () async {
                                try {
                                  // ask to crane

                                  http.Response response = await http.post(
                                    Uri.parse(chosenCrane.url + '/orden'),
                                    headers: {"Content-Type": "application/json"},
                                    body: orderBody,);

                                  Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);
                                  debugPrint(recvJson.toString());

                                  debugPrint(recvJson.toString());
                                  debugPrint(response.statusCode.toString());

                                  // Process result
                                  if (response.statusCode == 404) {
                                    message =
                                    "Grúa no se encuentra disponible. Intente con otra";
                                    debugPrint(recvJson.toString());
                                    debugPrint(response.statusCode.toString());
                                    alertType = AlertType.warning;
                                  } else {
                                    if (response.statusCode != 200) {
                                      message =
                                      "Ocurrió un error con la comunicación con la grúa, intente de nuevo";
                                      debugPrint(recvJson.toString());
                                      debugPrint(response.statusCode.toString());
                                      alertType = AlertType.error;
                                    } else {
                                      widget.order.deliveryCost = recvJson['costoEnvio'].toString();
                                      widget.order.paymentStatus = recvJson['estado'];
                                      widget.order.deliveryDate = recvJson['fechaEntrega'];
                                      widget.order.deliveryETA = recvJson['ETA'].toString();
                                      widget.order.deliveryServer = recvJson['servidor'];
                                      widget.order.costoTotal = recvJson['costoTotal'].toString();

                                      bool updateResult =
                                      await Order.updateOrder2(
                                          order: widget.order);
                                      message = updateResult
                                          ? "La orden ha sido actualizada con éxito"
                                          : "Ocurrió un error con la comunicación con la grúa, intente de nuevo";
                                      alertType = updateResult
                                          ? AlertType.info
                                          : AlertType.error;
                                    }
                                  }

                                  return 1;
                                } catch (e) {
                                  print(e);
                                  message =
                                  "Ocurrió un error al crear la petición. Intente de nuevo";
                                  alertType = AlertType.error;
                                  return -1;
                                }
                              },
                            ),
                            message: Text(
                              'Consultando Mensajería...',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        );

                        Alert(
                          context: context,
                          type: alertType,
                          title: "Warning",
                          desc: message,
                          buttons: [
                            DialogButton(
                              onPressed: () {
                                if (operationResult != null &&
                                    operationResult > 0) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(
                                "Cerrar",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                          ],
                        ).show();
                      } else {
                        debugPrint(_formKey.currentState?.value.toString());
                        debugPrint('validation failed');
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white.withOpacity(0.90),
                    ),
                    label: Text(
                      'Update Status',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        debugPrint(_formKey.currentState?.value.toString());

                        String message = "";
                        AlertType alertType = AlertType.info;

                        final Crane chosenCrane =
                        _formKey.currentState?.value["crane"];

                        final Map orderData = {
                          'ordenID' : widget.order.orderId,
                        };

                        String orderBody = json.encode(orderData);

                        int? operationResult = await showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => FutureProgressDialog(
                            Future<int?>(
                                  () async {
                                try {
                                  // ask to crane

                                  http.Response response = await http.post(
                                    Uri.parse(chosenCrane.url + '/pago'),
                                    headers: {"Content-Type": "application/json"},
                                    body: orderBody,);

                                  Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);
                                  debugPrint(recvJson.toString());

                                  debugPrint(recvJson.toString());
                                  debugPrint(response.statusCode.toString());

                                  // Process result
                                  if (response.statusCode == 404) {
                                    message =
                                    "Grúa no se encuentra disponible. Intente con otra";
                                    debugPrint(recvJson.toString());
                                    debugPrint(response.statusCode.toString());
                                    alertType = AlertType.warning;
                                  } else {
                                    if (response.statusCode != 200) {
                                      message =
                                      "Ocurrió un error con la comunicación con la grúa, intente de nuevo";
                                      debugPrint(recvJson.toString());
                                      debugPrint(response.statusCode.toString());
                                      alertType = AlertType.error;
                                    } else {
                                      message = "La orden ha sido actualizada con éxito";
                                      alertType = AlertType.info;
                                    }
                                  }

                                  return 1;
                                } catch (e) {
                                  print(e);
                                  message =
                                  "Ocurrió un error al crear la petición. Intente de nuevo";
                                  alertType = AlertType.error;
                                  return -1;
                                }
                              },
                            ),
                            message: Text(
                              'Consultando Mensajería...',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        );

                        Alert(
                          context: context,
                          type: alertType,
                          title: "Warning",
                          desc: message,
                          buttons: [
                            DialogButton(
                              onPressed: () {
                                if (operationResult != null &&
                                    operationResult > 0) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(
                                "Cerrar",
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                          ],
                        ).show();
                      } else {
                        debugPrint(_formKey.currentState?.value.toString());
                        debugPrint('validation failed');
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white.withOpacity(0.90),
                    ),
                    label: Text(
                      'Enviar Pago Orden',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _formKey.currentState?.reset();
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.black,
                    ),
                    label: Text(
                      'Reset',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
