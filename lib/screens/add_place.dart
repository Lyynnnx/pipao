import 'dart:io';
import 'dart:math';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/providers/user_places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreenState();
  }
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {


  void getLoc(double lat, double long, String address){
    loc = PlaceLocation(latitude: lat, longitude: long, address: address);
    
  }
  PlaceLocation? loc;
  

  File? _pickedImage;
  final _titleController = TextEditingController();

  void _savePlace() {
    final enteredTitle = _titleController.text;

    if (enteredTitle.isEmpty || _pickedImage == null) {
      return;
    }
    if(loc==null){
      return;
    }
    PlaceLocation location=loc!;
    if(loc!=null){
      print("Saving place with location: ${loc!.latitude}, ${loc!.longitude} and address: ${loc!.address}");
    }

    ref.read(userPlacesProvider.notifier).addPlace(enteredTitle, _pickedImage!, location);

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void pickImage() async {
    var photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (photo == null) {
      return;
    }
    setState(() {
      _pickedImage = File(photo.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: double.infinity,
                child: _pickedImage == null
                    ? TextButton.icon(
                        icon: Icon(Icons.camera),
                        onPressed: () {
                          pickImage();
                        },
                        label: const Text("Take Picture"))
                    : Image.file(_pickedImage!, scale: 2)),
                    LocationInput(getLoc: getLoc),
            ElevatedButton.icon(
              onPressed: _savePlace,
              icon: const Icon(Icons.add),
              label: const Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}
