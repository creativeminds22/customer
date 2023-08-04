import 'package:customer/constant/constant.dart';
import 'package:customer/controller/dash_board_controller.dart';
import 'package:customer/model/intercity_service_model.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/payment_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class InterCityController extends GetxController {
  DashBoardController dashboardController = Get.put(DashBoardController());

  Rx<TextEditingController> sourceCityController = TextEditingController().obs;
  Rx<TextEditingController> sourceLocationController = TextEditingController().obs;
  Rx<LocationLatLng> sourceLocationLAtLng = LocationLatLng().obs;

  Rx<TextEditingController> destinationCityController = TextEditingController().obs;
  Rx<TextEditingController> destinationLocationController = TextEditingController().obs;
  Rx<LocationLatLng> destinationLocationLAtLng = LocationLatLng().obs;

  Rx<TextEditingController> parcelWeight = TextEditingController().obs;
  Rx<TextEditingController> parcelDimension = TextEditingController().obs;

  Rx<TextEditingController> noOfPassengers = TextEditingController().obs;
  Rx<TextEditingController> offerYourRateController = TextEditingController().obs;
  Rx<TextEditingController> whenController = TextEditingController().obs;
  Rx<TextEditingController> commentsController = TextEditingController().obs;

  RxList<IntercityServiceModel> intercityService = <IntercityServiceModel>[].obs;
  Rx<IntercityServiceModel> selectedInterCityType = IntercityServiceModel().obs;

  DateTime? dateAndTime;

  List<XFile>? images = [];

  var colors = [
    AppColors.serviceColor1,
    AppColors.serviceColor2,
    AppColors.serviceColor3,
  ];

  @override
  void onInit() {
    // TODO: implement onInit
    getPaymentData();
    getIntercityService();

    super.onInit();
  }

  RxBool isLoading = true.obs;

  getIntercityService() async {
    await FireStoreUtils.getIntercityService().then((value) {
      intercityService.value = value;
      if (intercityService.isNotEmpty) {
        selectedInterCityType.value = intercityService.first;
      }
      isLoading.value = false;
    });
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
            amount.value = Constant.amountCalculate(selectedInterCityType.value.kmCharge.toString(), distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
            offerYourRateController.value.text = Constant.amountCalculate(selectedInterCityType.value.kmCharge.toString(), distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
          } else {
            distance.value = (value.rows!.first.elements!.first.distance!.value!.toInt() / 1609.34).toString();
            amount.value = Constant.amountCalculate(selectedInterCityType.value.kmCharge.toString(), distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
            offerYourRateController.value.text = Constant.amountCalculate(selectedInterCityType.value.kmCharge.toString(), distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
          }
        }
      });
    }
  }
}
