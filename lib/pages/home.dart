import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
   
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band(id: '1', name: 'Beatles', votes: 5),
    // Band(id: '2', name: 'ACDC', votes: 7),
    // Band(id: '3', name: 'Pink Floyd', votes: 3),
    // Band(id: '4', name: 'Queen', votes: 3)
  ];

  @override
  void initState() {
    // TODO: implement initState

    final socketService = Provider.of<SocketService>(context, listen: false);

    if(socketService.socket != null){
      socketService.socket!.on('active-bands', _handleActiveBands); //Se manda la referencia unicamente
    }

    super.initState();
  }

  _handleActiveBands(dynamic payload) { //Y esto lo recibe por referencia
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList(); //Se castea para que sea un List
    setState(() {
      
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context, listen: false);

    if(socketService.socket != null){
      socketService.socket!.off('active-bands'); //Hacer la limpieza una vez que se deshace el widget
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('CHART MUSICAL', style: TextStyle(color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online) ?  Icon(Icons.bolt_outlined, color: Colors.blue[200]) : Icon(Icons.offline_bolt, color: Colors.red)
          )
        ],
      ),
      body: (bands.length) > 0 ? Container(
        color: Colors.white,
        child: Column(
          children: [
            _showGraph(),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Expanded( //Se usa un expanden porque por defecto el listview tiene un espacio infinito que no sabe interptretar la columna
              child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) => _bandTile(bands[index])
              ),
            ),
          ],
        ),
      ) : SingleChildScrollView(
        child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/nobands.svg', alignment: Alignment.center, height: 500),
                  Container(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Aún no hay bandas agregadas', style: TextStyle(color: Colors.black.withOpacity(0.87), fontWeight: FontWeight.w600, fontSize: 19), textAlign: TextAlign.center,)),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[300],
        elevation: 1,
        onPressed: addNewBand, //Solo se manda la referencia de la funcion
      ),
    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);
    
    return Container(
      padding: EdgeInsets.only(top: 7),
      child: Dismissible(
        key: Key(band.id ?? DateTime.now().toString()), //Un identificador unico
        direction: DismissDirection.startToEnd,
        onDismissed: ( DismissDirection direction ) { //Evento que se dispara cuando la animacion se termina
          //Llamar el borrado en el server
          if(socketService.socket != null) {
            socketService.socket!.emit('delete-band', { 'id' : band.id });
          }
        },
        background: Container(
          padding: EdgeInsets.only(left: 25),
          color: Colors.red[400],
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.delete, color: Colors.white)
          ),
        ), //Widget que aparece atras del elemento
        child: ListTile(
          leading: CircleAvatar(
            child: Text(band.name != null ? band.name!.substring(0,2).toUpperCase() : '', style: TextStyle(color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w600)),
            backgroundColor: Colors.blue[100],
          ),
          title: Text(band.name ?? '', style: TextStyle(color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w500),),
          trailing: Text('${band.votes}', style: TextStyle(fontSize: 21, color: (band.votes! > 0) ? Colors.blue[300] : Colors.red[400], fontWeight: FontWeight.w600)),
          onTap: () {
            if(socketService.socket != null){
              socketService.socket!.emit('vote-band', { 'id': band.id });
            }
          },
        ),
      ),
    );
  }

  addNewBand() {
    //En un statefulWidget el context está de manera global en el widget y por eso no es necesario mandarlo en funciones
    
    final TextEditingController textController = TextEditingController();

    //Usar el platform de dart:io, no de dart:html
    if(Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('AGREGA UNA BANDA', textAlign: TextAlign.center, style: TextStyle(color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w500)),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              
            ),
          ),
          actions: [
            MaterialButton(
              child: Text('AGREGAR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500),),
              elevation: 5,
              textColor: Colors.blue[300],
              onPressed: () => addBandToList(textController.text),
            )
          ],
        )
      );
    }
    else {
      return showCupertinoDialog(
        context: context, 
        builder: (_) => CupertinoAlertDialog(
          title: Text('AGREGA UNA BANDA', textAlign: TextAlign.center, style: TextStyle(color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w500)),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true, //Si presiona enter (solo en dispositivo fisico) se ejecuta el boton
              child: Text('AGREGAR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500),),
              onPressed: () => addBandToList(textController.text), //En IOS no se cierra aun con el navigator que está dentro del metodo. Por eso se crea otro boton exclusivo para cerrar
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, //Si presiona enter (solo en dispositivo fisico) se ejecuta el boton
              child: Text('CANCELAR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500),),
              onPressed: () => Navigator.pop(context)
            )
          ],
        )
      );
    }
    
  }

  void addBandToList(String name) {

    if(name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      // this.bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      // setState(() {});
      if(socketService.socket != null){
        socketService.socket!.emit('add-band', { 'name': name }); //En dart, las llaves de un mapa son en string
      }
    }
    Navigator.pop(context); //Para cerrar el dialogo
  }

  //Mostrar gráfica
  Widget _showGraph() {

    // Map<String, double> dataMap = {
    //   "Flutter": 0,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };

    Map<String, double> dataMap = {};

    this.bands.forEach((band){
      dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble()); //Añade un nuevo par de clave valor
    });

    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(dataMap: dataMap)
    ) ;
  }

}