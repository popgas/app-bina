import 'package:flutter/material.dart';
import 'dart:async';
import 'package:phone_state_background/phone_state_background.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<String?> phoneStateBackgroundCallbackHandler(PhoneStateBackgroundEvent event, String number, int duration) async {
  switch (event) {
    case PhoneStateBackgroundEvent.incomingstart:
      print('Incoming call start, number: $number, duration: $duration s');
      return extractPhoneNumber(number);
    case PhoneStateBackgroundEvent.incomingmissed:
      print('Incoming call missed, number: $number, duration: $duration s');
      return extractPhoneNumber(number);
    case PhoneStateBackgroundEvent.incomingreceived:
      print('Incoming call received, number: $number, duration: $duration s');
      return extractPhoneNumber(number);
    case PhoneStateBackgroundEvent.incomingend:
      print('Incoming call ended, number: $number, duration $duration s');
      return extractPhoneNumber(number);
    case PhoneStateBackgroundEvent.outgoingstart:
      print('Ougoing call start, number: $number, duration: $duration s');
      return extractPhoneNumber(number);
    case PhoneStateBackgroundEvent.outgoingend:
      print('Ougoing call ended, number: $number, duration: $duration s');
      return extractPhoneNumber(number);
    default:
      return null;
  }
}

String? extractPhoneNumber(String number) {
  if (number.isEmpty) {
    return 'Não foi possível identificar o número';
  }
  print(number);

  enviarNumeroServidor(number);

  return number;
}

Future<void> enviarNumeroServidor(String phoneNumber) async {
  final url = Uri.parse('https://sandbox-api.popgas.com.br/phone-caller-id');

  final headers = {
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    'phone_number': phoneNumber,
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    print('Número enviado com sucesso para o servidor');
  } else {
    print('Falha ao enviar o número para o servidor');
  }
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PopGas Bina',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'PopGas Bina'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? hasPermission;
  String? call;


  @override
  void initState() {
    super.initState();
    _hasPermission();
  }

  Future<void> _hasPermission() async {
    final permission = await PhoneStateBackground.checkPermission();
    print('Permission $permission');
    setState(() => hasPermission = permission);
  }

  Future<void> _requestPermission() async {
    await PhoneStateBackground.requestPermissions();
    await _hasPermission();
  }

  Future<void> _init() async {
    if (hasPermission != true) return;
    await PhoneStateBackground.initialize(phoneStateBackgroundCallbackHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Permissões: $hasPermission',
              style: TextStyle(
                  fontSize: 16,
                  color: hasPermission! ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 20,),
            Text('Número: $call',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () => _requestPermission(),
                child: const Text('Verificar Permissões'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () => _init(),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Background color
                  ),
                  child: const Text('Começar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}