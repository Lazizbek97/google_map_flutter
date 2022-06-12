import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_app/models/directions_model.dart';
import 'package:google_map_app/repository/direction_repository.dart';
import 'package:google_map_app/screens/search_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.latlng, required this.name})
      : super(key: key);

  LatLng latlng;
  String name;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;

  LatLng? myCurLocation;

  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(37.773972, -122.431297), zoom: 11.5);
  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _distination;
  Directions? _info;

  @override
  void initState() {
    super.initState();

    _initialCameraPosition = CameraPosition(target: widget.latlng, zoom: 14.5);

    _origin = Marker(
      markerId: const MarkerId("origin"),
      infoWindow: InfoWindow(title: widget.name),
      visible: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: widget.latlng,
    );
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    myCurLocation = LatLng(
      position.latitude,
      position.longitude,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: const Text(
          "Google Map",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () async {
                await getCurrentLocation();
                if (myCurLocation != null) {
                  _distination = Marker(
                    markerId: const MarkerId("distination"),
                    infoWindow: const InfoWindow(title: "Distination"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueCyan),
                    position: myCurLocation!,
                  );

                  final directions = await DirectionRerpository().getDirections(
                    origin: _origin!.position,
                    destination: myCurLocation!,
                  );
                  setState(() {
                    _info = directions;
                  });

                  _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: myCurLocation!,
                        zoom: 14.5,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.route_outlined,
                color: Colors.black,
              )),
          IconButton(
            onPressed: () async {
              // generate a new token here
              final sessionToken = const Uuid().v4();
              final result = (await showSearch(
                context: context,
                delegate: AddressSearch(sessionToken, 'address'),
              ));
              setNewLocation(LatLng(result!.latitude, result.longitude));
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) => _googleMapController = controller,
              markers: {
                if (_origin != null)
                  _origin ?? const Marker(markerId: MarkerId("value")),
                if (_distination != null)
                  _distination ?? const Marker(markerId: MarkerId("value1")),
              },
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: const PolylineId("overview_polyline"),
                    color: Colors.green,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              },
              onLongPress: (pos) async {
                setState(() {
                  _distination = Marker(
                    markerId: const MarkerId("distination"),
                    infoWindow: const InfoWindow(title: "Distination"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                    position: pos,
                  );
                });

                final directions = await DirectionRerpository()
                    .getDirections(origin: _origin!.position, destination: pos);
                setState(() {
                  _info = directions;
                });
              }),
          if (_info != null)
            Positioned(
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Text('${_info!.totalDistance} / '),
                    Text(_info!.totalDurations),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  setNewLocation(LatLng myCurLocation) async {
    _distination = Marker(
      markerId: const MarkerId("distination"),
      infoWindow: const InfoWindow(title: "Distination"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      position: myCurLocation,
    );

    final directions = await DirectionRerpository().getDirections(
      origin: _origin!.position,
      destination: myCurLocation,
    );
    setState(() {
      _info = directions;
    });

    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: myCurLocation,
          zoom: 14.5,
        ),
      ),
    );
  }
}
