import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier{

  //Hay que recordar que cada conexion y desconexion del servidor socket crear un nuevo id de dispositivo

  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket? _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket? get socket => this._socket;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
  
    // Dart client
    this._socket = IO.io('https://willy-socket-io-server.herokuapp.com/', { //Opciona, poner mi_ip o poner 10.0.2.2
      'transports': ['websocket'], //Comunicacion a traves de protocolo websockets
      'autoConnect': true
    });
    this._socket?.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      this.notifyListeners();
      // this._socket.emit('msg', 'test');
    });
    this._socket?.on('nuevo-mensaje', (payload) { //Esuchcar mensaje (on)
      print('Nuevo mensaje: $payload');
    });
    this._socket?.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      this.notifyListeners();
    });
    // this._socket.on('fromServer', (_) => print(_));
  
  }

}