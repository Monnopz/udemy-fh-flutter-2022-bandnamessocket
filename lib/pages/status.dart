import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_names/services/socket_service.dart';

import 'package:flutter_svg/flutter_svg.dart';

class StatusPage extends StatelessWidget {
   
  const StatusPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Server Status: ${socketService.serverStatus}')
          ],
         )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          if(socketService.socket != null) {
            socketService.socket!.emit('emitir-mensaje', { 'nombre': 'Willy', 'mensaje': 'Hola desde Flutter' });
          }
        },
      ),
    );
    // return Scaffold(
    //   body: Container(
    //     padding: EdgeInsets.symmetric(horizontal: 13),
    //     child: Column(
    //      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //      children: [
    //        SvgPicture.asset('assets/nobands.svg'),
    //        Text('Pulsa el botón + y comienza a agregar bandas', style: TextStyle(color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w600, fontSize: 21), textAlign: TextAlign.center,)
    //      ],
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     child: Icon(Icons.message),
    //     onPressed: () {
    //       if(socketService.socket != null) {
    //         socketService.socket!.emit('emitir-mensaje', { 'nombre': 'Willy', 'mensaje': 'Hola desde Flutter' });
    //       }
    //     },
    //   ),
    // );
  }
}