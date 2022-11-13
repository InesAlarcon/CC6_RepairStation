import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:repair_station/models/crane.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CraneFormScreen extends StatelessWidget {
  final Cranes cranes;
  final Crane? crane;
  const CraneFormScreen({required this.cranes, this.crane, super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "Formulario de Grúa",
        style: Theme.of(context).textTheme.headline2,
      ),
      centerTitle: true,
      // leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
    ),
    body: CraneForm(
      cranes: cranes,
      crane: crane,
    ),
  );
}
}

class CraneForm extends StatefulWidget {
  final Cranes cranes;
  final Crane? crane;
  const CraneForm({required this.cranes, this.crane, super.key});

@override
CraneFormState createState() => CraneFormState();
}

class CraneFormState extends State<CraneForm> {
  bool autoValidate = true;
  bool _nameHasError = false, _urlHasError = false;
  final _formKey = GlobalKey<FormBuilderState>();

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
                initialValue: {
                  'name': widget.crane?.name,
                  'url': widget.crane?.url,
                },
                skipDisabled: true,
                child: Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                          name: 'name',
                          readOnly: widget.crane != null,
                          decoration: InputDecoration(
                            labelText: 'Nombre Entidad',
                            suffixIcon: widget.crane != null
                                ? const Icon(Icons.lock, color: Colors.green)
                                : _nameHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check,
                                color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _nameHasError = !(_formKey
                                  .currentState?.fields['name']
                                  ?.validate() ??
                                  false);
                            });
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FormBuilderTextField(
                          name: 'url',
                          decoration: InputDecoration(
                            labelText: 'URL API',
                            suffixIcon: _urlHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check, color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _urlHasError = !(_formKey
                                  .currentState?.fields['url']
                                  ?.validate() ??
                                  false);
                            });
                          },
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.url(),
                          ]),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
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

                        if (widget.crane == null) {
                          String message = "";
                          AlertType alertType = AlertType.info;

                          final newCrane = Crane(
                            name: _formKey.currentState?.value["name"],
                            url: _formKey.currentState?.value["url"],
                          );

                          bool inCatalog = false;
                          for (Crane crane in widget.cranes.cranes) {
                            if (crane.name == newCrane.name) {
                              inCatalog = true;
                              break;
                            }
                          }

                          if (!inCatalog) {
                            bool? result = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => FutureProgressDialog(
                                Future(
                                      () async {
                                    return await Crane.addNewProduct(
                                        crane: newCrane);
                                  },
                                ),
                                message: Text(
                                  'Añadiendo grúa...',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            );

                            message =
                            result! ? "Grúa añadida" : "Ocurrió un error";
                            alertType =
                            result ? AlertType.info : AlertType.error;

                            if (result) {
                              widget.cranes.cranes.add(newCrane);
                              _formKey.currentState?.reset();
                            }
                          } else {
                            message = "Una Grúa con el mismo nombre ya existe";
                            alertType = AlertType.error;
                          }

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
                        } else {
                          widget.crane?.url =
                          _formKey.currentState?.value["url"];

                          String message = "";
                          AlertType alertType = AlertType.info;

                          bool? result = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => FutureProgressDialog(
                              Future(
                                    () async {
                                  return await Crane.updateProduct(
                                      crane: widget.crane!);
                                },
                              ),
                              message: Text(
                                'Actualizando Grúa...',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          );

                          message =
                          result! ? "Grúa Actualizada" : "Ocurrió un error";
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
                        }
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
