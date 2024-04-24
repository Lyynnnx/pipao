import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
   LocationInput({super.key, required this.getLoc});
  Function (double lat, double long, String address) getLoc;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  bool isGettingLocation = false; //это для крутилки
  double? locationLongitude; //долгота, где я живу
  double? locationLatitude; //широта, где я живу
  List<LatLng> polylineCoordinates = []; //тут хранятся координаты для маршрута
  String? address;

  List<Marker> markers = [ //это маркеры, которые мы добавляем на карту
    Marker(
      point: LatLng(48.211845, 11.6355484),
      child: Icon(Icons.location_pin, color: Colors.green, size: 50),)
  ];

  void getLocation() async { //узнать координаты своего устройства
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        //это все дает разрешение на использование локации
        return;
      }
    }
    setState(() {
      isGettingLocation = true; //это для крутилки
    });
    locationData = await location.getLocation(); //важная строчка, она именно получает локацию
    setState(() {
      locationLatitude = locationData.latitude;
      locationLongitude = locationData.longitude;
    });
    print("${locationData.latitude} +" "${locationData.longitude}");
    setState(() {
      isGettingLocation = false; //это для крутилки
    });
    printAdress(); //так же выведет нормальный адрес
  }

  @override
  void initState() {
    super.initState();
    _getRoute();
    getLocation();
  }

  Widget content() { //это сама карта
    return FlutterMap(
      options: MapOptions(
        onTap: (TapPosition dontcare, LatLng point) {
          //эта функция позволяет при нажатии на карту, добавить маркер, там, где мы хотим и при этом сохранить эти координаты в наш массив
          setState(() {
            markers.add(Marker(
                child: const Icon(Icons.person_pin_sharp,
                    color: Colors.blue, size: 50),
                point: point));
          });
        },
        initialCenter: (locationLatitude == null || locationLongitude == null)
            ? LatLng(1.2878, 103.8666)
            : LatLng(locationLatitude!, locationLongitude!),
        initialZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: ~InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(//создает само фото карты
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        PolylineLayer( //создает маршрут на базе гугля для двух точек
          polylines: [
            Polyline(
                points: polylineCoordinates,
                color: Colors.blue,
                strokeWidth: 5.0),
          ],
        ),
        MarkerLayer(// маркеры будут показывать места на карте
          markers: [
            Marker(
                point: (locationLatitude == null)
                    ? LatLng(60.751244, 37.618423)
                    : LatLng(locationLatitude!, locationLongitude!),
                // child: Image.network(
                //     "https://i.kym-cdn.com/photos/images/original/002/018/144/1f8.png"),
                child: const Icon(Icons.location_pin,
                    color: Colors.green, size: 50),
                width: 50,
                height: 50,
                alignment: Alignment.center),
            ...markers
          ],
        )
      ],
    );
  }

  void _getRoute() async { //эта функция берет из гугла много точек, добавляет их в массив polylineCoordinates и рисует маршрут
    final LatLng startPoint = markers[0].point!;
    final LatLng endPoint =
        LatLng(markers[0].point.latitude + 1, markers[0].point.longitude + 1);
    String url =
        'https://router.project-osrm.org/route/v1/driving/${startPoint.longitude},${startPoint.latitude};${endPoint.longitude},${endPoint.latitude}?overview=full&geometries=geojson';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    List<dynamic> routes = data['routes'];
    if (routes.isNotEmpty) {
      List<dynamic> geometry = routes[0]['geometry']['coordinates'];
      setState(() {
        polylineCoordinates = geometry
            .map((coordinate) => LatLng(coordinate[1], coordinate[0]))
            .toList();
      });
    }
  }

  void openMapnow(BuildContext context) {
    //это функция, которая открывает карту
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) =>
          Scaffold(appBar: AppBar(title: Text("hell yeah")), body: content()),
    );
  }
//6acbfa74460d464e8ea7eff8269ee223-08593a0ed79c9f0651237c2ab505a5fa


  void printAdress()async{
    final url =  Uri.parse('https://api.exoapi.dev/reverse-geocoding');
    final headers = {'Authorization': 'Bearer 6acbfa74460d464e8ea7eff8269ee223-08593a0ed79c9f0651237c2ab505a5fa'};
    final params = {
    'lat': '$locationLatitude',
    'lon': '$locationLongitude',
    'locale': 'en-GB'
  };
  final resonse = await http.post(url, headers:headers, body:params);
  if(resonse.statusCode == 200){
    final data = json.decode(resonse.body);
    final adress= data['address'];
    address = adress;
    widget.getLoc(locationLatitude!, locationLongitude!, address!);
  }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContet = Text('No Location chosen',
        style: Theme.of(context).textTheme.titleMedium);
    if (isGettingLocation) {
      previewContet = CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
            ),
            // child: previewContet,
            child: content() //заменяем запихнули карту в экран
            ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          TextButton.icon(
            icon: const Icon(
              Icons.location_on,
            ),
            onPressed: () {
              getLocation();
            },
            label: const Text("Get current location"),
          ),
          TextButton.icon(
              onPressed: () {
                openMapnow(context);
              },
              icon: const Icon(Icons.map),
              label: const Text("select on map")),
        ]),
      ],
    );
  }
}
