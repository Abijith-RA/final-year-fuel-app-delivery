import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'conform_list.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isOnDuty = false;
  String? _userId;
  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Timer? _locationUpdateTimer;
  bool _isLoading = true;
  bool _mapLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    await Future.wait([_getUserId(), _checkLocationStatus()]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail');
      if (userEmail == null) return;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('Rapidboy')
              .where('email', isEqualTo: userEmail)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty && mounted) {
        setState(() => _userId = snapshot.docs.first.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting user: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkLocationStatus() async {
    try {
      if (_userId == null) return;
      final doc =
          await FirebaseFirestore.instance
              .collection('Rapidboy')
              .doc(_userId)
              .get();

      if (doc.exists && doc.data()?['status'] == 'on_duty' && mounted) {
        _startLocationUpdates();
        setState(() => _isOnDuty = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking status: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _goOnDuty() async {
    if (_userId == null || !mounted) return;
    setState(() => _mapLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        setState(() => _mapLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() => _mapLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
        setState(() => _mapLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      await _updateLocationInFirebase(position, true);
      _startLocationUpdates();

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isOnDuty = true;
          _mapLoading = false;
          _updateMap(position);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _mapLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error going on duty: ${e.toString()}')),
        );
      }
    }
  }

  void _startLocationUpdates() {
    _positionStream?.cancel();
    _locationUpdateTimer?.cancel();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _updateLocationInFirebase(position, false);
      _updateMap(position);
    });

    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        Position position = await Geolocator.getCurrentPosition();
        _updateLocationInFirebase(position, false);
        _updateMap(position);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating location: ${e.toString()}')),
        );
      }
    });
  }

  Future<void> _updateLocationInFirebase(
    Position position,
    bool updateStatus,
  ) async {
    if (_userId == null || !mounted) return;

    try {
      final updateData = {
        'deliveryboylocation': GeoPoint(position.latitude, position.longitude),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (updateStatus) {
        updateData['status'] = 'on_duty';
      }

      await FirebaseFirestore.instance
          .collection('Rapidboy')
          .doc(_userId)
          .update(updateData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating location: ${e.toString()}')),
      );
    }
  }

  void _updateMap(Position position) {
    if (!mounted) return;

    final marker = Marker(
      markerId: const MarkerId('delivery_boy'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(title: 'Your Location'),
    );

    setState(() {
      _markers.clear();
      _markers.add(marker);
      _currentPosition = position;
    });

    _mapController.future.then((controller) {
      if (!mounted) return;
      controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    });
  }

  Future<void> _goOffDuty() async {
    if (_userId == null || !mounted) return;
    setState(() => _mapLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('Rapidboy')
          .doc(_userId)
          .update({
            'status': 'offline',
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      _positionStream?.cancel();
      _locationUpdateTimer?.cancel();

      if (mounted) {
        setState(() {
          _isOnDuty = false;
          _mapLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _mapLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error going off duty: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'Delivery Dashboard',
                style: TextStyle(color: Colors.orange),
              ),
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.orange),
            ),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              )
            else
              Expanded(
                child:
                    _currentPosition == null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Enable location to view map',
                                style: TextStyle(color: Colors.orange),
                              ),
                              if (_mapLoading)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
                                ),
                            ],
                          ),
                        )
                        : Stack(
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 15,
                              ),
                              markers: _markers,
                              onMapCreated: (GoogleMapController controller) {
                                _mapController.complete(controller);
                              },
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                            ),
                            if (_mapLoading)
                              Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
              ),
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child:
                    _isOnDuty
                        ? Column(
                          children: [
                            Text(
                              'Status: ON DUTY',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ConformList(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'VIEW ORDERS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: _goOffDuty,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child:
                                  _mapLoading
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.red,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'GO OFF DUTY',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ],
                        )
                        : ElevatedButton(
                          onPressed: _goOnDuty,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              _mapLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'GO ON DUTY',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
              ),
          ],
        ),
      ),
    );
  }
}
