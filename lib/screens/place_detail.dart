import 'package:flutter/material.dart';

import 'package:favorite_places/models/place.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Center(
        child: Column(
          children: [
            Image.file(place.photo),
            MediaQuery.of(context).size.height > 600
                ? Text(
                    place.location.address,
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                : Text(
                    place.location.address,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
          ],
        ),
        
      ),
    );
  }
}
