import 'dart:async';

import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:place_picker/place_picker.dart';

class Utils {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static Future<LocationResult?> showPlacePicker(BuildContext context) async {
    LocationResult? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlacePicker(Constant.mapAPIKey)));
    return result;
  }

  static Future<LocationResult?> showPlacePickerWithLatLong(BuildContext context, LatLng latLng) async {
    LocationResult? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              Constant.mapAPIKey,
              displayLocation: latLng,
            )));
    return result;
  }

  Future<PlacesDetailsResponse?> handlePressButton(BuildContext context) async {
    void onError(response) {
      ShowToastDialog.showToast(response.errorMessage ?? 'Unknown error');
    }

    // show input autocomplete with selected mode
    // then get the Prediction selected
    final p = await PlacesAutocomplete.show(
        context: context, apiKey: Constant.mapAPIKey, onError: onError, mode: Mode.overlay, language: 'fr', components: [], resultTextStyle: Theme.of(context).textTheme.titleMedium);

    if (p == null) {
      return null;
    }
    ShowToastDialog.showLoader("Please wait..");

    // get detail (lat/lng)
    final places = GoogleMapsPlaces(
      apiKey: Constant.mapAPIKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    final detail = await places.getDetailsByPlaceId(p.placeId!);
    ShowToastDialog.closeLoader();
    return detail;
  }
}
