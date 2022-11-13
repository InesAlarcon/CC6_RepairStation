import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../models/crane.dart';

class CraneScreen extends StatelessWidget {
  const CraneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Cranes>(
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
            if (snapshot.data != null) {
              return CranesList(
                cranes: snapshot.data!,
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

class CranesList extends StatefulWidget {
  final Cranes cranes;
  const CranesList({required this.cranes, super.key});

@override
CranesListState createState() => CranesListState();
}

class CranesListState extends State<CranesList> {
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
                    "Grúas",
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
                            widget.cranes.cranes =
                                (await Cranes.getCranes()).cranes;
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
                    Navigator.pushNamed(context, "/craneform",
                        arguments: [null, widget.cranes]).then(
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
                    "Añadir Grúa",
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 750,
            child: ListView.builder(
              itemCount: widget.cranes.cranes.length,
              itemBuilder: (context, index) {
                String title =
                    "Nombre de la Entidad: ${widget.cranes.cranes[index].name}";
                String subtitle =
                    "URL del API:\n${widget.cranes.cranes[index].url}\n";
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
                                  return await Crane.deleteProduct(
                                    crane: widget.cranes.cranes[index],
                                  );
                                },
                              ),
                              message: Text(
                                'Eliminando grúa...',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          );

                          message =
                          result! ? "Grúa Eliminada" : "Ocurrió un error";
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
                            widget.cranes.cranes.removeAt(index);
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
                        Navigator.pushNamed(context, "/craneform", arguments: [
                          widget.cranes.cranes[index],
                          widget.cranes
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
