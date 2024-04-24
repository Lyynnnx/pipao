import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation{
  PlaceLocation({required this.latitude, required this.longitude, required this.address});
  final double latitude;
  final double longitude;
  final String address;
}

class Place {
  Place({required this.title, required this.photo, required this.location}) : id = uuid.v4();

  final String id;
  final String title;
  File photo;
  final PlaceLocation location;
}
