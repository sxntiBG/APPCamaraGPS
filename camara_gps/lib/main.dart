import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              child: const Text('Cámara'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationScreen()),
                );
              },
              child: const Text('Geolocalización'),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _takePicture() async {
    // Solicitar permiso de cámara
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }

    // Tomar la foto si se concede el permiso
    if (await Permission.camera.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      setState(() {
        _imageFile = image != null ? File(image.path) : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asociamos el GlobalKey al Scaffold
      appBar: AppBar(
        title: const Text('Pantalla de Cámara'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _takePicture,
            child: const Text('Tomar Foto'),
          ),
          if (_imageFile != null)
            Column(
              children: [
                const SizedBox(height: 20),
                const Text('La foto tomada es:'),
                Image.file(_imageFile!),
              ],
            ),
        ],
      ),
    );
  }
}

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  Future<void> _getLocation(BuildContext context) async {
    // Solicitar permiso de ubicación
    var status = await Permission.location.status;
    if (status.isDenied) {
      // Si los permisos están denegados, solicitarlos
      var result = await Permission.location.request();
      if (result.isDenied) {
        // Si el usuario deniega los permisos, mostrar un mensaje
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Se requieren permisos de ubicación para obtener la información de ubicación.'),
        ));
        return;
      }
    }

    // Obtener la ubicación si se concede el permiso
    if (await Permission.location.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final String locationInfo =
            'Latitud: ${position.latitude}, Longitud: ${position.longitude}';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(locationInfo),
        ));
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error: no se puede obtener la ubicación.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla de Geolocalización'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _getLocation(context),
            child: const Text('Obtener Geolocalización'),
          ),
        ],
      ),
    );
  }
}
