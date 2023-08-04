import 'dart:io';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/interCity_controller.dart';
import 'package:customer/model/conversation_model.dart';
import 'package:customer/model/intercity_order_model.dart';
import 'package:customer/model/intercity_service_model.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/order/positions.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InterCityScreen extends StatelessWidget {
  const InterCityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<InterCityController>(
      init: InterCityController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: controller.isLoading.value
              ? Constant.loader()
              : Column(
                  children: [
                    SizedBox(
                      height: Responsive.width(4, context),
                      width: Responsive.width(100, context),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        await Utils().handlePressButton(context).then((cityValue) {
                                          if (cityValue != null) {
                                            Utils.showPlacePickerWithLatLong(context, LatLng(cityValue.result.geometry!.location.lat, cityValue.result.geometry!.location.lng)).then((value) {
                                              if (value != null) {
                                                controller.sourceCityController.value.text = cityValue.result.vicinity.toString();

                                                controller.sourceLocationController.value.text = value.formattedAddress.toString();
                                                controller.sourceLocationLAtLng.value = LocationLatLng(latitude: value.latLng!.latitude, longitude: value.latLng!.longitude);

                                                controller.calculateAmount();
                                              } else {
                                                ShowToastDialog.showToast("Please select address");
                                              }
                                            });
                                          } else {
                                            ShowToastDialog.showToast("Please select city");
                                          }
                                        });
                                      },
                                      child: TextFieldThem.buildTextFiled(
                                        context,
                                        hintText: 'From',
                                        controller: controller.sourceLocationController.value,
                                        enable: false,
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        await Utils().handlePressButton(context).then((cityValue) {
                                          if (cityValue != null) {
                                            Utils.showPlacePickerWithLatLong(context, LatLng(cityValue.result.geometry!.location.lat, cityValue.result.geometry!.location.lng)).then((value) {
                                              if (value != null) {
                                                controller.destinationCityController.value.text = cityValue.result.vicinity.toString();

                                                controller.destinationLocationController.value.text = value.formattedAddress.toString();
                                                controller.destinationLocationLAtLng.value = LocationLatLng(latitude: value.latLng!.latitude, longitude: value.latLng!.longitude);

                                                controller.calculateAmount();
                                              } else {
                                                ShowToastDialog.showToast("Please select address");
                                              }
                                            });
                                          } else {
                                            ShowToastDialog.showToast("Please select city");
                                          }
                                        });
                                      },
                                      child: TextFieldThem.buildTextFiled(
                                        context,
                                        hintText: 'To',
                                        controller: controller.destinationLocationController.value,
                                        enable: false,
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Select Option", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, letterSpacing: 1)),
                                  const SizedBox(
                                    height: 05,
                                  ),
                                  SizedBox(
                                    height: Responsive.height(18, context),
                                    child: ListView.builder(
                                      itemCount: controller.intercityService.length,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        IntercityServiceModel serviceModel = controller.intercityService[index];
                                        return Obx(
                                          () => InkWell(
                                            onTap: () {
                                              controller.selectedInterCityType.value = serviceModel;
                                              controller.calculateAmount();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: Container(
                                                width: Responsive.width(28, context),
                                                decoration: BoxDecoration(
                                                    color: controller.selectedInterCityType.value == serviceModel
                                                        ? themeChange.getThem()
                                                            ? AppColors.darkModePrimary
                                                            : AppColors.primary
                                                        : themeChange.getThem()
                                                            ? AppColors.darkService
                                                            : controller.colors[index % controller.colors.length],
                                                    borderRadius: const BorderRadius.all(
                                                      Radius.circular(20),
                                                    )),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(context).colorScheme.background,
                                                          borderRadius: const BorderRadius.all(
                                                            Radius.circular(20),
                                                          )),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: CachedNetworkImage(
                                                          imageUrl: serviceModel.image.toString(),
                                                          fit: BoxFit.contain,
                                                          height: Responsive.height(8, context),
                                                          width: Responsive.width(18, context),
                                                          placeholder: (context, url) => Constant.loader(),
                                                          errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(serviceModel.name.toString(),
                                                        style: GoogleFonts.poppins(
                                                            color: controller.selectedInterCityType.value == serviceModel
                                                                ? themeChange.getThem()
                                                                    ? Colors.black
                                                                    : Colors.white
                                                                : themeChange.getThem()
                                                                    ? Colors.white
                                                                    : Colors.black)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        BottomPicker.dateTime(
                                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          onSubmit: (index) {
                                            controller.dateAndTime = index;
                                            DateFormat dateFormat = DateFormat("EEE dd MMMM , HH:mm aa");
                                            String string = dateFormat.format(index);

                                            controller.whenController.value.text = string;
                                          },
                                          minDateTime: DateTime.now(),
                                          buttonAlignement: MainAxisAlignment.center,
                                          displayButtonIcon: false,
                                          displaySubmitButton: true,
                                          title: '',
                                          buttonText: 'Confirm',
                                          buttonSingleColor: AppColors.primary,
                                          buttonTextStyle: const TextStyle(color: Colors.white),
                                        ).show(context);
                                      },
                                      child: TextFieldThem.buildTextFiled(
                                        context,
                                        hintText: 'When',
                                        controller: controller.whenController.value,
                                        enable: false,
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  controller.selectedInterCityType.value.id == "647f350983ba2"
                                      ? Column(
                                          children: [
                                            TextFieldThem.buildTextFiled(
                                              context,
                                              hintText: 'Parcel weight (In Kg.)',
                                              controller: controller.parcelWeight.value,
                                              keyBoardType: TextInputType.number,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextFieldThem.buildTextFiled(
                                              context,
                                              hintText: 'Parcel dimension(In ft.)',
                                              controller: controller.parcelDimension.value,
                                              keyBoardType: TextInputType.number,
                                            ),
                                            parcelImageWidget(context, controller),
                                          ],
                                        )
                                      : TextFieldThem.buildTextFiled(
                                          context,
                                          hintText: 'Number of Passengers',
                                          controller: controller.noOfPassengers.value,
                                          keyBoardType: TextInputType.number,
                                        ),
                                  Obx(
                                    () => controller.sourceLocationLAtLng.value.latitude != null && controller.destinationLocationLAtLng.value.latitude != null
                                        ? Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                child: Container(
                                                  decoration: const BoxDecoration(color: AppColors.gray, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                  child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      child: Center(
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text: 'Recommended Price ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}',
                                                              style: GoogleFonts.poppins(color: Colors.black),
                                                              children: [
                                                                TextSpan(
                                                                    text: controller.selectedInterCityType.value.offerRate == true ? '. Enter your rate' : '',
                                                                    style: GoogleFonts.poppins(color: Colors.black))
                                                              ]),
                                                        ),
                                                      )),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                  Visibility(
                                    visible: controller.selectedInterCityType.value.offerRate == true,
                                    child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: TextFieldThem.buildTextFiledWithPrefixIcon(
                                          context,
                                          hintText: "Enter your offer rate",
                                          controller: controller.offerYourRateController.value,
                                          prefix: Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Text(Constant.currencyModel!.symbol.toString()),
                                          ),
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFieldThem.buildTextFiled(
                                    context,
                                    hintText: 'Comments',
                                    controller: controller.commentsController.value,
                                    keyBoardType: TextInputType.text,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      paymentMethodDialog(context, controller);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        border: Border.all(color: AppColors.textFieldBorder, width: 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/ic_payment.svg',
                                              width: 26,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                                child: Text(
                                              controller.selectedPaymentMethod.value.isNotEmpty ? controller.selectedPaymentMethod.value : "Select Payment type",
                                              style: GoogleFonts.poppins(),
                                            )),
                                            const Icon(Icons.arrow_drop_down_outlined)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ButtonThem.buildButton(
                                    context,
                                    title: "Ride Placed",
                                    btnWidthRatio: Responsive.width(100, context),
                                    onPress: () async {
                                      if (controller.selectedInterCityType.value.id == "647f350983ba2") {
                                        if (controller.sourceLocationController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please select source location");
                                        }else if (controller.destinationLocationController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please select destination location");
                                        }else if (controller.selectedPaymentMethod.value.isEmpty) {
                                          ShowToastDialog.showToast("Please select Payment Method");
                                        }else if (controller.parcelDimension.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please select date and time");
                                        } else if (controller.selectedInterCityType.value.offerRate == true && controller.offerYourRateController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please Enter offer rate");
                                        } else {
                                          ShowToastDialog.showLoader("Please wait");

                                          List<dynamic> parcelImages = [];
                                          if (controller.images != null) {
                                            for (var element in controller.images!) {
                                              Url url = await Constant().uploadChatImageToFireStorage(File(element.path));
                                              parcelImages.add(url.url);
                                            }
                                          }

                                          InterCityOrderModel intercityOrderModel = InterCityOrderModel();
                                          intercityOrderModel.id = Constant.getUuid();
                                          intercityOrderModel.userId = FireStoreUtils.getCurrentUid();
                                          intercityOrderModel.sourceLocationName = controller.sourceLocationController.value.text;
                                          intercityOrderModel.sourceCity = controller.sourceCityController.value.text;
                                          intercityOrderModel.sourceLocationLAtLng = controller.sourceLocationLAtLng.value;

                                          intercityOrderModel.parcelImage = parcelImages;
                                          intercityOrderModel.parcelWeight = controller.parcelWeight.value.text;
                                          intercityOrderModel.parcelDimension = controller.parcelDimension.value.text;

                                          intercityOrderModel.destinationLocationName = controller.destinationLocationController.value.text;
                                          intercityOrderModel.destinationCity = controller.destinationCityController.value.text;
                                          intercityOrderModel.destinationLocationLAtLng = controller.destinationLocationLAtLng.value;
                                          intercityOrderModel.distance = controller.distance.value;
                                          intercityOrderModel.offerRate =
                                          controller.selectedInterCityType.value.offerRate == true ? controller.offerYourRateController.value.text : controller.amount.value;
                                          intercityOrderModel.intercityServiceId = controller.selectedInterCityType.value.id;
                                          intercityOrderModel.intercityService = controller.selectedInterCityType.value;
                                          GeoFirePoint position =
                                          GeoFlutterFire().point(latitude: controller.sourceLocationLAtLng.value.latitude!, longitude: controller.sourceLocationLAtLng.value.longitude!);

                                          intercityOrderModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
                                          intercityOrderModel.createdDate = Timestamp.now();
                                          intercityOrderModel.status = Constant.ridePlaced;
                                          intercityOrderModel.paymentType = controller.selectedPaymentMethod.value;
                                          intercityOrderModel.paymentStatus = false;
                                          intercityOrderModel.whenTime = DateFormat("HH:mm").format(controller.dateAndTime!);
                                          intercityOrderModel.whenDates = DateFormat("dd-MMM-yyyy").format(controller.dateAndTime!);
                                          intercityOrderModel.numberOfPassenger = controller.noOfPassengers.value.text;
                                          intercityOrderModel.comments = controller.commentsController.value.text;
                                          intercityOrderModel.otp = Constant.getReferralCode();
                                          intercityOrderModel.taxList = Constant.taxList;
                                          intercityOrderModel.adminCommission = Constant.adminCommission;
                                          intercityOrderModel.distanceType = Constant.distanceType;
                                          FireStoreUtils.setInterCityOrder(intercityOrderModel).then((value) {
                                            ShowToastDialog.closeLoader();
                                            if (value == true) {
                                              ShowToastDialog.showToast("Ride Placed successfully");
                                              controller.dashboardController.selectedDrawerIndex(3);
                                            }
                                          });
                                        }
                                      } else {
                                        if (controller.sourceLocationController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please select source location");
                                        }else if (controller.destinationLocationController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please select destination location");
                                        }else if (controller.selectedPaymentMethod.value.isEmpty) {
                                          ShowToastDialog.showToast("Please select Payment Method");
                                        } else if (controller.noOfPassengers.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please enter Number of passenger");
                                        } else if (controller.whenController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please select date and time");
                                        } else if (controller.selectedInterCityType.value.offerRate == true && controller.offerYourRateController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please Enter offer rate");
                                        } else {
                                          ShowToastDialog.showLoader("Please wait");
                                          InterCityOrderModel intercityOrderModel = InterCityOrderModel();
                                          intercityOrderModel.id = Constant.getUuid();
                                          intercityOrderModel.userId = FireStoreUtils.getCurrentUid();
                                          intercityOrderModel.sourceLocationName = controller.sourceLocationController.value.text;
                                          intercityOrderModel.sourceCity = controller.sourceCityController.value.text;
                                          intercityOrderModel.sourceLocationLAtLng = controller.sourceLocationLAtLng.value;

                                          intercityOrderModel.destinationLocationName = controller.destinationLocationController.value.text;
                                          intercityOrderModel.destinationCity = controller.destinationCityController.value.text;
                                          intercityOrderModel.destinationLocationLAtLng = controller.destinationLocationLAtLng.value;
                                          intercityOrderModel.distance = controller.distance.value;
                                          intercityOrderModel.offerRate =
                                          controller.selectedInterCityType.value.offerRate == true ? controller.offerYourRateController.value.text : controller.amount.value;
                                          intercityOrderModel.intercityServiceId = controller.selectedInterCityType.value.id;
                                          intercityOrderModel.intercityService = controller.selectedInterCityType.value;
                                          GeoFirePoint position =
                                          GeoFlutterFire().point(latitude: controller.sourceLocationLAtLng.value.latitude!, longitude: controller.sourceLocationLAtLng.value.longitude!);

                                          intercityOrderModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
                                          intercityOrderModel.createdDate = Timestamp.now();
                                          intercityOrderModel.status = Constant.ridePlaced;
                                          intercityOrderModel.paymentType = controller.selectedPaymentMethod.value;
                                          intercityOrderModel.paymentStatus = false;
                                          intercityOrderModel.whenTime = DateFormat("HH:mm").format(controller.dateAndTime!);
                                          intercityOrderModel.whenDates = DateFormat("dd-MMM-yyyy").format(controller.dateAndTime!);
                                          intercityOrderModel.numberOfPassenger = controller.noOfPassengers.value.text;
                                          intercityOrderModel.comments = controller.commentsController.value.text;
                                          intercityOrderModel.otp = Constant.getReferralCode();
                                          intercityOrderModel.taxList = Constant.taxList;
                                          intercityOrderModel.adminCommission = Constant.adminCommission;
                                          intercityOrderModel.distanceType = Constant.distanceType;
                                          FireStoreUtils.setInterCityOrder(intercityOrderModel).then((value) {
                                            ShowToastDialog.closeLoader();
                                            if (value == true) {
                                              ShowToastDialog.showToast("Ride Placed successfully");
                                              controller.dashboardController.selectedDrawerIndex(3);
                                            }
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  paymentMethodDialog(BuildContext context, InterCityController controller) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: StatefulBuilder(builder: (context1, setState) {
              return Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: const Icon(Icons.arrow_back_ios)),
                            const Expanded(
                                child: Center(
                                    child: Text(
                              "Select Payment Method",
                            ))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Visibility(
                                visible: controller.paymentModel.value.cash!.enable == true,
                                child: Obx(
                                  () => Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.cash!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.cash!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(Icons.money, color: Colors.black),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.cash!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.cash!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.cash!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.wallet!.enable == true,
                                child: Obx(
                                  () => Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.wallet!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.wallet!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SvgPicture.asset('assets/icons/ic_wallet.svg', color: AppColors.primary),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.wallet!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.wallet!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.wallet!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.strip!.enable == true,
                                child: Obx(
                                  () => Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.strip!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/stripe.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.strip!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.strip!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.paypal!.enable == true,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(
                                              color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paypal!.name.toString()
                                                  ? themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary
                                                  : AppColors.textFieldBorder,
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 80,
                                                decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset('assets/images/paypal.png'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  controller.paymentModel.value.paypal!.name.toString(),
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                              Radio(
                                                value: controller.paymentModel.value.paypal!.name.toString(),
                                                groupValue: controller.selectedPaymentMethod.value,
                                                activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                onChanged: (value) {
                                                  controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.payStack!.enable == true,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(
                                              color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payStack!.name.toString()
                                                  ? themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary
                                                  : AppColors.textFieldBorder,
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 80,
                                                decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset('assets/images/paystack.png'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  controller.paymentModel.value.payStack!.name.toString(),
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                              Radio(
                                                value: controller.paymentModel.value.payStack!.name.toString(),
                                                groupValue: controller.selectedPaymentMethod.value,
                                                activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                onChanged: (value) {
                                                  controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.mercadoPago!.enable == true,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(
                                              color: controller.selectedPaymentMethod.value == controller.paymentModel.value.mercadoPago!.name.toString()
                                                  ? themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary
                                                  : AppColors.textFieldBorder,
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 80,
                                                decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset('assets/images/mercadopago.png'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  controller.paymentModel.value.mercadoPago!.name.toString(),
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                              Radio(
                                                value: controller.paymentModel.value.mercadoPago!.name.toString(),
                                                groupValue: controller.selectedPaymentMethod.value,
                                                activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                onChanged: (value) {
                                                  controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.flutterWave!.enable == true,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(
                                              color: controller.selectedPaymentMethod.value == controller.paymentModel.value.flutterWave!.name.toString()
                                                  ? themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary
                                                  : AppColors.textFieldBorder,
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 80,
                                                decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset('assets/images/flutterwave.png'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  controller.paymentModel.value.flutterWave!.name.toString(),
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                              Radio(
                                                value: controller.paymentModel.value.flutterWave!.name.toString(),
                                                groupValue: controller.selectedPaymentMethod.value,
                                                activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                onChanged: (value) {
                                                  controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.payfast!.enable == true,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(
                                              color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payfast!.name.toString()
                                                  ? themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary
                                                  : AppColors.textFieldBorder,
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 80,
                                                decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset('assets/images/payfast.png'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  controller.paymentModel.value.payfast!.name.toString(),
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                              Radio(
                                                value: controller.paymentModel.value.payfast!.name.toString(),
                                                groupValue: controller.selectedPaymentMethod.value,
                                                activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                onChanged: (value) {
                                                  controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.paytm!.enable == true,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(
                                              color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paytm!.name.toString()
                                                  ? themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary
                                                  : AppColors.textFieldBorder,
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 80,
                                                decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset('assets/images/paytam.png'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  controller.paymentModel.value.paytm!.name.toString(),
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                              Radio(
                                                value: controller.paymentModel.value.paytm!.name.toString(),
                                                groupValue: controller.selectedPaymentMethod.value,
                                                activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                onChanged: (value) {
                                                  controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: controller.paymentModel.value.razorpay!.enable == true,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(
                                              color: controller.selectedPaymentMethod.value == controller.paymentModel.value.razorpay!.name.toString()
                                                  ? themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary
                                                  : AppColors.textFieldBorder,
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 80,
                                                decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Image.asset('assets/images/razorpay.png'),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  controller.paymentModel.value.razorpay!.name.toString(),
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                              Radio(
                                                value: controller.paymentModel.value.razorpay!.name.toString(),
                                                groupValue: controller.selectedPaymentMethod.value,
                                                activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                onChanged: (value) {
                                                  controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonThem.buildButton(
                        context,
                        title: "Pay",
                        onPress: () async {
                          Get.back();
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  parcelImageWidget(BuildContext context, InterCityController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
      child: SizedBox(
        height: 100,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ListView.builder(
                itemCount: controller.images!.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      width: 100,
                      height: 100.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(fit: BoxFit.cover, image: FileImage(File(controller.images![index].path))),
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: InkWell(
                          onTap: () {
                            controller.images!.removeAt(index);
                          },
                          child: const Icon(
                            Icons.remove_circle,
                            size: 30,
                          )),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: () {
                    _onCameraClick(context, controller);
                  },
                  child: Image.asset(
                    'assets/images/parcel_add_image.png',
                    height: 100,
                    width: 100,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onCameraClick(BuildContext context, InterCityController controller) {
    final action = CupertinoActionSheet(
      message: const Text(
        'Add your parcel image.',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            await ImagePicker().pickMultiImage().then((value) {
              value.forEach((element) {
                controller.images!.add(element);
              });
            });
          },
          child: const Text('Choose image from gallery'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Get.back();
            final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
            if (photo != null) {
              controller.images!.add(photo);
            }
          },
          child: const Text('Take a picture'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ),
        onPressed: () {
          Get.back();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
