import 'package:customer/constant/constant.dart';
import 'package:customer/controller/dash_board_controller.dart';
import 'package:customer/model/banner_model.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/payment_model.dart';
import 'package:customer/model/service_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  DashBoardController dashboardController = Get.put(DashBoardController());

  Rx<TextEditingController> sourceLocationController = TextEditingController().obs;
  Rx<TextEditingController> destinationLocationController = TextEditingController().obs;
  Rx<TextEditingController> offerYourRateController = TextEditingController().obs;
  Rx<ServiceModel> selectedType = ServiceModel().obs;

  Rx<LocationLatLng> sourceLocationLAtLng = LocationLatLng().obs;
  Rx<LocationLatLng> destinationLocationLAtLng = LocationLatLng().obs;

  RxString currentLocation = "".obs;
  RxBool isLoading = true.obs;
  RxList serviceList = <ServiceModel>[].obs;
  RxList bannerList = <BannerModel>[].obs;
  final PageController pageController = PageController(viewportFraction: 0.96, keepPage: true);

  var colors = [
    AppColors.serviceColor1,
    AppColors.serviceColor2,
    AppColors.serviceColor3,
  ];

  @override
  void onInit() {
    // TODO: implement onInit
    getServiceType();
    getPaymentData();
    super.onInit();
  }

  getServiceType() async {
    await FireStoreUtils.getService().then((value) {
      serviceList.value = value;
      if (serviceList.isNotEmpty) {
        selectedType.value = serviceList.first;
      }
    });

    await FireStoreUtils.getBanner().then((value) {
      bannerList.value = value;
    });

    isLoading.value = false;

    await Utils.getCurrentLocation().then((value) {
      Constant.currentLocation = value;
    });
    await placemarkFromCoordinates(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude).then((value) {
      Placemark placeMark = value[0];

      currentLocation.value = "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
    }).catchError((error) {
      debugPrint("------>${error.toString()}");
    });
  }

  RxString duration = "".obs;
  RxString distance = "".obs;
  RxString amount = "".obs;

  calculateAmount() async {
    if (sourceLocationLAtLng.value.latitude != null && destinationLocationLAtLng.value.latitude != null) {
      await Constant.getDurationDistance(
              LatLng(sourceLocationLAtLng.value.latitude!, sourceLocationLAtLng.value.longitude!), LatLng(destinationLocationLAtLng.value.latitude!, destinationLocationLAtLng.value.longitude!))
          .then((value) {
        if (value != null) {
          duration.value = value.rows!.first.elements!.first.duration!.text.toString();
          if (Constant.distanceType == "Km") {
            distance.value = (value.rows!.first.elements!.first.distance!.value!.toInt() / 1000).toString();
            amount.value = Constant.amountCalculate(selectedType.value.kmCharge.toString(), distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
          } else {
            distance.value = (value.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toString();
            amount.value = Constant.amountCalculate(selectedType.value.kmCharge.toString(), distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
          }
        }
      });
    }
  }

  Rx<PaymentModel> paymentModel = PaymentModel().obs;

  RxString selectedPaymentMethod = "".obs;

  getPaymentData() async {
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
      }
    });
  }
}
