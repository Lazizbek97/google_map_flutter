import 'package:flutter/material.dart';
import 'package:google_map_app/data/restaurants_data.dart';
import 'package:google_map_app/screens/home_screen.dart';
import 'package:google_map_app/screens/search_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Google Map',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeMenu());
  }
}

class HomeMenu extends StatelessWidget {
  const HomeMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Best Restaurants in Tashkent',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () async {
              //
              // generate a new token here
              final sessionToken = const Uuid().v4();
              final result = (await showSearch(
                context: context,
                delegate: AddressSearch(sessionToken, 'cafe|restaurant|bar'),
              ));

              if (result != null) {
                // ignore: use_build_context_synchronously
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('On Map'),
                        elevation: 0,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      body: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: LatLng(result.latitude, result.longitude),
                            zoom: 18.5),
                        markers: {
                          Marker(
                            markerId: const MarkerId("marker id"),
                            visible: true,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                            position: LatLng(result.latitude, result.longitude),
                          ),
                        },
                      ),
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: LocalData.restaurants.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        latlng: LatLng(
                          LocalData.restaurants[index]['lat'],
                          LocalData.restaurants[index]['long'],
                        ),
                        name: LocalData.restaurants[index]['name'],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(LocalData.restaurants[index]['img']),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2,
                        spreadRadius: 4,
                        color: Colors.grey.shade300,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 40,
                child: Text(
                  LocalData.restaurants[index]['name'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
