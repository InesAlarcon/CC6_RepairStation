import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../models/car_line.dart';

class CarLineScreen extends StatelessWidget {
  const CarLineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AutomobileLines>(
      future: Future(
            () async {
          return await AutomobileLines.getLines();
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
              return AutomobilesList(
                automobiles: snapshot.data!,
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

class AutomobilesList extends StatefulWidget {
  final AutomobileLines automobiles;
  const AutomobilesList({required this.automobiles, super.key});

@override
AutomobilesListState createState() => AutomobilesListState();
}

class AutomobilesListState extends State<AutomobilesList> {
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
                    "Líneas de Carros",
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
                            widget.automobiles.lines =
                                (await AutomobileLines.getLines()).lines;
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
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pushNamed(context, "/carlineform",
                        arguments: [null, widget.automobiles]).then(
                          (value) {
                        setState(() {});
                      },
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.white.withOpacity(0.90),
                  ),
                  label: Text(
                    "Añadir Línea de Carro",
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 750,
            child: ListView.builder(
              itemCount: widget.automobiles.lines.length,
              itemBuilder: (context, index) {
                String title =
                    "Marca: ${widget.automobiles.lines[index].brand}";
                String subtitle =
                    "Modelos: ${widget.automobiles.lines[index].formattedModels()}\n";
                print(title);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      title: Text(title),
                      subtitle: Text(subtitle),
                      trailing: IconButton(
                        onPressed: () async {
                          String message = "";
                          AlertType alertType = AlertType.info;

                          bool? result = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => FutureProgressDialog(
                              Future(
                                    () async {
                                  return await CarLine.deleteCarLine(
                                    carLine: widget.automobiles.lines[index],
                                  );
                                },
                              ),
                              message: Text(
                                'Eliminando Línea...',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          );

                          message =
                          result! ? "Línea Eliminada" : "Ocurrió un error";
                          alertType = result ? AlertType.info : AlertType.error;

                          Alert(
                            context: context,
                            type: alertType,
                            title: "Warning",
                            desc: message,
                            buttons: [
                              DialogButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Cerrar",
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ),
                            ],
                          ).show();

                          if (result) {
                            widget.automobiles.lines.removeAt(index);
                            setState(() {});
                          }
                        },
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 35,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pushNamed(context, "/carlineform",
                            arguments: [
                              widget.automobiles.lines[index],
                              widget.automobiles
                            ]).then(
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
