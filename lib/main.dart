import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() async {

  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amberAccent,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white))),
      )));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double real;
  double dolar;
  double euro;

  final realController = TextEditingController();  
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String txt){
    double real = double.parse(txt);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (euro/dolar).toStringAsFixed(2);
  }

  void _dolarChanged(String txt){
    double dolar = double.parse(txt);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar/ euro).toStringAsFixed(2);
  }

  void _euroChanged(String txt){
    double euro = double.parse(txt);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro)/ dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
          onPressed: (){
            realController.text = "";
            dolarController.text = "";
            euroController.text = "";
          },
          icon: Icon(Icons.refresh),
          )
        ],
        backgroundColor: Colors.amber,
        title: Text("\$Conversor\$"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao Carregar Dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 200, color: Colors.amber),
                        builderTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        builderTextField("Dólares", "\$", dolarController, _dolarChanged),
                        Divider(),
                        builderTextField("Euro", "€", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget builderTextField(String txt, String prefix, TextEditingController ctrl, Function fnc) {
  return TextField(
    controller: ctrl,
    decoration: InputDecoration(
      labelText: txt,
      prefixText: prefix,
      border: OutlineInputBorder(),
    ),
    style: TextStyle(color: Colors.amberAccent, fontSize: 25.0),
    onChanged: fnc,
    keyboardType: TextInputType.number,
  );
}
