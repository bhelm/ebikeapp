import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:collection';
import 'dart:async' show Future;
import 'package:numberpicker/numberpicker.dart';

class EBikeConfigurationMenu extends StatefulWidget {
    EBikeConfigurationMenu({Key key, this.config, this.title}) : super(key: key);

    final config;
    final title;

    @override
    _EBikeConfigurationMenuState createState() => _EBikeConfigurationMenuState();

    @override
    Widget build(BuildContext context) {}
}

Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/config.json');
}

class _EBikeConfigurationMenuState extends State<EBikeConfigurationMenu> {
    var _configuration = [];

    @protected
    @mustCallSuper
    void initState() {
        log("init!");
        if (widget.config != null) {
            setState(() {
                _configuration = widget.config;
            });
        } else {
            loadAsset(context).then((value) {
                log(value);
                setState(() {
                    _configuration = json.decode(value)['config'];
                });
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        // This method is rerun every time setState is called, for instance as done
        // by the _incrementCounter method above.
        //
        // The Flutter framework has been optimized to make rerunning build methods
        // fast, so that you can just rebuild anything that needs updating rather
        // than having to individually change instances of widgets.
        return Scaffold(
            appBar: AppBar(
                title: Text(widget.title),
            ),
            body: Center(child: _buildConfigScreen(_configuration)),
        );
    }

    Widget _buildConfigScreen(var configuration) {
        return ListView.builder(
                itemCount: configuration.length,
                itemBuilder: (BuildContext ctxt, int index) {
                    var itm = _configuration[index];

                    return Row(
                        children: [
                            _getDescriptionWidget(itm),
                            Expanded(
                                child: _getSubWidget(itm),
                            ),
                        ],
                    );
                });
    }

    Widget _getDescriptionWidget(var subwidget) {
        if (subwidget['info'] != null) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipOval(
                    child: Material(
                        color: Colors.black12, // button color
                        child: InkWell(
                            splashColor: Colors.red, // inkwell color
                            child: SizedBox(
                                    width: 40, height: 40, child: Icon(Icons.description)),
                            onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                        // return object of type Dialog
                                        return AlertDialog(
                                            title: new Text(subwidget['label']),
                                            content: new Text(subwidget['info']),
                                            actions: <Widget>[
                                                // usually buttons at the bottom of the dialog
                                                new FlatButton(
                                                    child: new Text("Close"),
                                                    onPressed: () {
                                                        Navigator.of(context).pop();
                                                    },
                                                ),
                                            ],
                                        );
                                    },
                                );
                            },
                        ),
                    ),
                ),
            );
        }
        return Padding(
            padding: const EdgeInsets.only(left: 55),
        );
    }

    Widget _getSubWidget(var subwidgetInfo) {
        if (subwidgetInfo['type'] == 'menu') {
            return _build_menu(subwidgetInfo);
        } else if (subwidgetInfo['type'] == 'text') {
            return _build_text(subwidgetInfo);
        } else if (subwidgetInfo['type'] == 'title') {
            return _build_title(subwidgetInfo);
        } else if (subwidgetInfo['type'] == 'bool') {
            return _build_bool(subwidgetInfo);
        } else if (subwidgetInfo['type'] == 'enum') {
            return _build_enum(subwidgetInfo);
        } else if (subwidgetInfo['type'] == 'number') {
            return _build_number(subwidgetInfo);
        }
        return new Text('unknown type ' + subwidgetInfo['type']);
    }

    Widget _build_text(var text) {
        return Center(child: Text(text['label']));
    }

    Widget _build_title(var text) {
        return Center(child: Text(
                text['label'],
                style: TextStyle(fontWeight: FontWeight.bold)
        ));
    }

    Widget _build_bool(var element) {
        return Row(children: [
            Expanded(child: Text(element['label'])),
            Switch(
                value: element['value'] == true,
                onChanged: (bool value) {
                    setState(() {
                        element['value'] = value;
                    });
                },
            )
        ]);
    }

    Widget _build_enum(var element) {
        return Row(children: [
            Expanded(child: Text(element['label'])),
            DropdownButton<String>(
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.blue),
                underline: Container(
                    height: 2,
                    color: Colors.blue,
                ),
                onChanged: (String newValue) {
                    setState(() {
                        element['value'] = newValue;
                    });
                },
                items: LinkedHashMap.of(element['choices'])
                        .entries
                        .map<DropdownMenuItem<String>>((dynamic entry) {
                    return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                    );
                }).toList(),
                value: element['value'],
            )
        ]);
    }

    Widget _build_number(var element) {
        return Row(
            children: [
                Expanded(child: Text(element['label'])),
                RaisedButton(
                        onPressed: () {
                            log("pressed");
                            showDialog<dynamic>(
                                    context: context,
                                    builder: (BuildContext context) {
                                        if(element['decimal'] == null || element['decimal'] == 0) {
                                            return new NumberPickerDialog.integer(
                                                    minValue: element['min'],
                                                    maxValue: element['max'],
                                                    title: Text(element['label']),
                                                    initialIntegerValue: element['value'].toInt(),
                                                    step: element['step'] ?? 1
                                            );

                                        }else{
                                            return new NumberPickerDialog.decimal(
                                                minValue: element['min'],
                                                maxValue: element['max'],
                                                title: Text(element['label']),
                                                initialDoubleValue: element['value'],
                                                decimalPlaces: element['decimal'],
                                            );
                                        }

                                    }
                            ).then((dynamic value) {
                                if (value != null) {
                                    setState(() => element['value'] = value);
                                }
                            });
                        },
                        child: Text(element['value'].toString()))
            ],
        );
    }

    Widget _build_menu(var menu) {
        return RaisedButton(
                onPressed: () {
                    log("pressed");
                    if (menu['children'] != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                    builder: (context) => EBikeConfigurationMenu(
                                            title: menu['label'], config: menu['children'])),
                        );
                    }
                },
                child: Text(menu['label']));
    }
}
