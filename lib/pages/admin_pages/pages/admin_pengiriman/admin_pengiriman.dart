import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/admin_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class AdminPengiriman extends StatefulWidget {
  const AdminPengiriman({super.key});

  @override
  State<AdminPengiriman> createState() => _AdminPengirimanState();
}

class _AdminPengirimanState extends State<AdminPengiriman> {
  bool isSharing = false;
  Timer? timer;

  List<IDOrderan> listOrderan = [];
  List<IDOrderan> selectedOrderans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final orders = await IDOrderan.fetchIDOrderan();
      setState(() {
        listOrderan = orders;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal fetch ID orderan: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> startShareLocation() async {
    if (selectedOrderans.isEmpty) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
    }

    timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      for (var order in selectedOrderans) {
        final response = await http.post(
          Uri.parse('http://192.168.1.96:3000/api/update-location'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id_orderan': order.id,
            'lat': position.latitude,
            'lng': position.longitude,
          }),
        );
        debugPrint(
          "Lokasi dikirim ke ID ${order.id}: ${position.latitude}, ${position.longitude}",
        );
      }
    });
  }

  void stopShareLocation() {
    timer?.cancel();
    setState(() {
      isSharing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Share Lokasi')),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Pilih ID Orderan yang ingin dikirimi lokasi:"),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView(
                        children:
                            listOrderan.map((order) {
                              return CheckboxListTile(
                                title: Text(
                                  "ID ${order.id} - ${order.statusPengiriman}",
                                ),
                                value: selectedOrderans.contains(order),
                                onChanged:
                                    isSharing
                                        ? null
                                        : (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedOrderans.add(order);
                                            } else {
                                              selectedOrderans.remove(order);
                                            }
                                          });
                                        },
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Icon(
                      isSharing ? Icons.location_on : Icons.location_off,
                      size: 100,
                      color: isSharing ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isSharing
                          ? "Lokasi sedang dibagikan ke ${selectedOrderans.length} orderan"
                          : "Lokasi tidak dibagikan",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          selectedOrderans.isEmpty
                              ? null
                              : () {
                                if (!isSharing) {
                                  startShareLocation();
                                } else {
                                  stopShareLocation();
                                }
                                setState(() => isSharing = !isSharing);
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSharing ? Colors.red : Colors.green,
                      ),
                      child: Text(
                        isSharing ? 'Stop Share Lokasi' : 'Start Share Lokasi',
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
