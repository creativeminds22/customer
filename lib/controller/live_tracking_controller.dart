import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/intercity_order_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTrackingController extends GetxController {
  GoogleMapController? mapController;

  @override
  void onInit() {
    // TODO: implement onInit
    addMarkerSetup();
    getArgument();
    super.onInit();
  }

  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<InterCityOrderModel> intercityOrderModel = InterCityOrderModel().obs;

  RxBool isLoading = true.obs;
  RxString type = "".obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      type.value = argumentData['type'];

      if (type.value == "orderModel") {
        OrderModel argumentOrderModel = argumentData['orderModel'];
        FirebaseFirestore.instance.collection(CollectionName.orders).doc(argumentOrderModel.id).snapshots().listen((event) {
          if (event.data() != null) {
            OrderModel orderModelStream = OrderModel.fromJson(event.data()!);
            log(orderModelStream.status.toString());
            orderModel.value = orderModelStream;
            FirebaseFirestore.instance.collection(CollectionName.driverUsers).doc(argumentOrderModel.driverId).snapshots().listen((event) {
              if (event.data() != null) {
                driverUserModel.value = DriverUserModel.fromJson(event.data()!);
                if (orderModel.value.status == Constant.rideInProgress) {
                  getPolyline(
                      sourceLatitude: driverUserModel.value.location!.latitude,
                      sourceLongitude: driverUserModel.value.location!.longitude,
                      destinationLatitude: orderModel.value.destinationLocationLAtLng!.latitude,
                      destinationLongitude: orderModel.value.destinationLocationLAtLng!.longitude);
                } else {
                  getPolyline(
                      sourceLatitude: driverUserModel.value.location!.latitude,
                      sourceLongitude: driverUserModel.value.location!.longitude,
                      destinationLatitude: orderModel.value.sourceLocationLAtLng!.latitude,
                      destinationLongitude: orderModel.value.sourceLocationLAtLng!.longitude);
                }
              }
            });

            if (orderModel.value.status == Constant.rideComplete) {
              Get.back();
            }
          }
        });
      } else {
        InterCityOrderModel argumentOrderModel = argumentData['interCityOrderModel'];
        FirebaseFirestore.instance.collection(CollectionName.ordersIntercity).doc(argumentOrderModel.id).snapshots().listen((event) {
          if (event.data() != null) {
            InterCityOrderModel orderModelStream = InterCityOrderModel.fromJson(event.data()!);
            log(orderModelStream.status.toString());
            intercityOrderModel.value = orderModelStream;
            FirebaseFirestore.instance.collection(CollectionName.driverUsers).doc(argumentOrderModel.driverId).snapshots().listen((event) {
              if (event.data() != null) {
                driverUserModel.value = DriverUserModel.fromJson(event.data()!);
                if (intercityOrderModel.value.status == Constant.rideInProgress) {
                  getPolyline(
                      sourceLatitude: driverUserModel.value.location!.latitude,
                      sourceLongitude: driverUserModel.value.location!.longitude,
                      destinationLatitude: intercityOrderModel.value.destinationLocationLAtLng!.latitude,
                      destinationLongitude: intercityOrderModel.value.destinationLocationLAtLng!.longitude);
                } else {
                  getPolyline(
                      sourceLatitude: driverUserModel.value.location!.latitude,
                      sourceLongitude: driverUserModel.value.location!.longitude,
                      destinationLatitude: intercityOrderModel.value.sourceLocationLAtLng!.latitude,
                      destinationLongitude: intercityOrderModel.value.sourceLocationLAtLng!.longitude);
                }
              }
            });

            if (intercityOrderModel.value.status == Constant.rideComplete) {
              Get.back();
            }
          }
        });

      }

    }
    isLoading.value = false;
    update();
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  void getPolyline({required double? sourceLatitude, required double? sourceLongitude, required double? destinationLatitude, required double? destinationLongitude}) async {
    if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Constant.mapAPIKey,
        PointLatLng(sourceLatitude, sourceLongitude),
        PointLatLng(destinationLatitude, destinationLongitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        log(result.errorMessage.toString());
      }

      if (type.value == "orderModel") {
        addMarker(latitude: orderModel.value.sourceLocationLAtLng!.latitude,
            longitude: orderModel.value.sourceLocationLAtLng!.longitude,
            id: "Departure",
            descriptor: departureIcon!,
            rotation: 0.0);
        addMarker(
            latitude: orderModel.value.destinationLocationLAtLng!.latitude,
            longitude: orderModel.value.destinationLocationLAtLng!.longitude,
            id: "Destination",
            descriptor: destinationIcon!,
            rotation: 0.0);
        addMarker(latitude: driverUserModel.value.location!.latitude,
            longitude: driverUserModel.value.location!.longitude,
            id: "Driver",
            descriptor: driverIcon!,
            rotation: driverUserModel.value.rotation);

        _addPolyLine(polylineCoordinates);
      } else {
        addMarker(latitude: intercityOrderModel.value.sourceLocationLAtLng!.latitude,
            longitude: intercityOrderModel.value.sourceLocationLAtLng!.longitude,
            id: "Departure",
            descriptor: departureIcon!,
            rotation: 0.0);
        addMarker(
            latitude: intercityOrderModel.value.destinationLocationLAtLng!.latitude,
            longitude: intercityOrderModel.value.destinationLocationLAtLng!.longitude,
            id: "Destination",
            descriptor: destinationIcon!,
            rotation: 0.0);
        addMarker(latitude: driverUserModel.value.location!.latitude,
            longitude: driverUserModel.value.location!.longitude,
            id: "Driver",
            descriptor: driverIcon!,
            rotation: driverUserModel.value.rotation);

        _addPolyLine(polylineCoordinates);
      }
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  addMarkerSetup() async {

    final Uint8List departure = await Constant().getBytesFromAsset('assets/images/pickup.png', 100);
    final Uint8List destination = await Constant().getBytesFromAsset('assets/images/dropoff.png', 100);
    final Uint8List driver = await Constant().getBytesFromAsset('assets/images/ic_cab.png', 50);
    departureIcon =  BitmapDescriptor.fromBytes(departure);
    destinationIcon =  BitmapDescriptor.fromBytes(destination);
    driverIcon =  BitmapDescriptor.fromBytes(driver);
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints();

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      startCap:Cap.roundCap ,
      width: 6,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, mapController);
  }

  Future<void> updateCameraLocation(
      LatLng source,
      LatLng destination,
      GoogleMapController? mapController,
      ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }
}
