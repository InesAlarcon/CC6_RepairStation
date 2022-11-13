import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:repair_station/models/car_line.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CarLineFormScreen extends StatelessWidget {
  final AutomobileLines automobilesLines;
  final CarLine? carLine;
  const CarLineFormScreen(
  {required this.automobilesLines, this.carLine, super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        "Formulario de Marca de Carro",
        style: Theme.of(context).textTheme.headline2,
      ),
      centerTitle: true,
      // leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
    ),
    body: CarLineForm(
      automobilesLines: automobilesLines,
      carLine: carLine,
    ),
  );
}
}

class CarLineForm extends StatefulWidget {
  final AutomobileLines automobilesLines;
  final CarLine? carLine;
  const CarLineForm({required this.automobilesLines, this.carLine, super.key});

@override
CarLineFormState createState() => CarLineFormState();
}

class CarLineFormState extends State<CarLineForm> {
  bool autoValidate = true;
  bool _brandHasError = false, _modelHasError = false;
  final _formKey = GlobalKey<FormBuilderState>();

  late List<String> carModels;

  @override
  void initState() {
    super.initState();

    carModels = [];
    if (widget.carLine != null) {
      carModels.addAll(widget.carLine!.models);
    }
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
                initialValue: {
                  'brand': widget.carLine?.brand,
                },
                skipDisabled: true,
                child: Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                          name: 'brand',
                          readOnly: widget.carLine != null,
                          decoration: InputDecoration(
                            labelText: 'Nombre Marca',
                            suffixIcon: widget.carLine != null
                                ? const Icon(Icons.lock, color: Colors.green)
                                : _brandHasError
                                ? const Icon(Icons.error, color: Colors.red)
                                : const Icon(Icons.check,
                                color: Colors.green),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _brandHasError = !(_formKey
                                  .currentState?.fields['brand']
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
                        ListTile(
                          title: FormBuilderTextField(
                            name: 'model',
                            decoration: InputDecoration(
                              labelText: 'Modelo Carro',
                              suffixIcon: _modelHasError
                                  ? const Icon(Icons.error, color: Colors.red)
                                  : const Icon(Icons.check,
                                  color: Colors.green),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _modelHasError = !(_formKey
                                    .currentState?.fields['model']
                                    ?.validate() ??
                                    false);
                              });
                            },
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                          ),
                          trailing: ElevatedButton(
                            child: Icon(
                              Icons.add,
                              color: Colors.white.withOpacity(0.90),
                            ),
                            onPressed: () {
                              if (!_modelHasError) {
                                carModels
                                    .add(_formKey.currentState?.value["model"]);
                                _formKey.currentState?.fields["model"]?.reset();
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        SizedBox(
                          height: 750,
                          child: ListView.builder(
                            itemCount: carModels.length,
                            itemBuilder: (context, index) {
                              String title = "Modelo: ${carModels[index]}";
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Card(
                                  elevation: 6.0,
                                  child: ListTile(
                                    title: Text(title),
                                    trailing: IconButton(
                                      onPressed: () {
                                        carModels.removeAt(index);
                                        setState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
                    icon: Icon(
                      Icons.send,
                      color: Colors.white.withOpacity(0.90),
                    ),
                    label: Text(
                      'Submit',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        debugPrint(_formKey.currentState?.value.toString());

                        if (widget.carLine == null) {
                          String message = "";
                          AlertType alertType = AlertType.info;

                          final newCarLine = CarLine(
                            brand: _formKey.currentState?.value["brand"],
                            models: [],
                          );
                          newCarLine.models.addAll(carModels);

                          bool inCarList = false;
                          for (CarLine carLine
                          in widget.automobilesLines.lines) {
                            if (newCarLine.brand == carLine.brand) {
                              inCarList = true;
                              break;
                            }
                          }

                          if (!inCarList) {
                            bool? result = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => FutureProgressDialog(
                                Future(
                                      () async {
                                    return await CarLine.addNewCarLine(
                                        carLine: newCarLine);
                                  },
                                ),
                                message: Text(
                                  'Añadiendo nueva Línea...',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            );

                            message =
                            result! ? "Línea añadida" : "Ocurrió un error";
                            alertType =
                            result ? AlertType.info : AlertType.error;

                            if (result) {
                              widget.automobilesLines.lines.add(newCarLine);
                              carModels.clear();
                              _formKey.currentState?.reset();
                            }
                          } else {
                            message = "Una Línea con la misma marca ya existe";
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
                          widget.carLine?.models = carModels;

                          String message = "";
                          AlertType alertType = AlertType.info;

                          bool? result = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => FutureProgressDialog(
                              Future(
                                    () async {
                                  return await CarLine.updateCarLine(
                                      carLine: widget.carLine!);
                                },
                              ),
                              message: Text(
                                'Actualizando Línea...',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          );

                          message = result!
                              ? "Línea Actualizada"
                              : "Ocurrió un error";
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
