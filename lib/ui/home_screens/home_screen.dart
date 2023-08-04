import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/home_controller.dart';
import 'package:customer/model/banner_model.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/order/positions.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/service_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: controller.isLoading.value
                ? Constant.loader()
                : Column(
                    children: [
                      SizedBox(
                        height: Responsive.width(22, context),
                        width: Responsive.width(100, context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FutureBuilder<UserModel?>(
                              future: FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Constant.loader();
                                  case ConnectionState.done:
                                    if (snapshot.hasError) {
                                      return Text(snapshot.error.toString());
                                    } else {
                                      UserModel userModel = snapshot.data!;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(userModel.fullName.toString(), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18, letterSpacing: 1)),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            children: [
                                              SvgPicture.asset('assets/icons/ic_location.svg', width: 16),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(child: Text(controller.currentLocation.value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400))),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                  default:
                                    return const Text('Error');
                                }
                              }),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration:
                              BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      visible: controller.bannerList.isNotEmpty,
                                      child: SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.20,
                                          child: PageView.builder(
                                              padEnds: false,
                                              itemCount: controller.bannerList.length,
                                              scrollDirection: Axis.horizontal,
                                              controller: controller.pageController,
                                              itemBuilder: (context, index) {
                                                BannerModel bannerModel = controller.bannerList[index];
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  child: CachedNetworkImage(
                                                    imageUrl: bannerModel.image.toString(),
                                                    imageBuilder: (context, imageProvider) => Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    color: Colors.black.withOpacity(0.5),
                                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              })),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text("Where you want to go?", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 1)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    controller.sourceLocationLAtLng.value.latitude == null
                                        ? InkWell(
                                            onTap: () async {
                                              LocationResult? result = await Utils.showPlacePicker(context);
                                              if (result != null) {
                                                controller.sourceLocationController.value.text = result.formattedAddress.toString();
                                                controller.sourceLocationLAtLng.value = LocationLatLng(latitude: result.latLng!.latitude, longitude: result.latLng!.longitude);
                                                controller.calculateAmount();
                                              }
                                            },
                                            child: TextFieldThem.buildTextFiled(context, hintText: 'Enter Location', controller: controller.sourceLocationController.value, enable: false))
                                        : Row(
                                            children: [
                                              Column(
                                                children: [
                                                  SvgPicture.asset(themeChange.getThem() ? 'assets/icons/ic_source_dark.svg' : 'assets/icons/ic_source.svg', width: 18),
                                                  Dash(direction: Axis.vertical, length: Responsive.height(6, context), dashLength: 12, dashColor: AppColors.dottedDivider),
                                                  SvgPicture.asset(themeChange.getThem() ? 'assets/icons/ic_destination_dark.svg' : 'assets/icons/ic_destination.svg', width: 20),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 18,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                        onTap: () async {
                                                          LocationResult? result = await Utils.showPlacePicker(context);
                                                          if (result != null) {
                                                            controller.sourceLocationController.value.text = result.formattedAddress.toString();
                                                            controller.sourceLocationLAtLng.value = LocationLatLng(latitude: result.latLng!.latitude, longitude: result.latLng!.longitude);
                                                            controller.calculateAmount();
                                                          }
                                                        },
                                                        child: TextFieldThem.buildTextFiled(context, hintText: 'Enter Location', controller: controller.sourceLocationController.value, enable: false)),
                                                    SizedBox(height: Responsive.height(1, context)),
                                                    InkWell(
                                                        onTap: () async {
                                                          LocationResult? result = await Utils.showPlacePicker(context);
                                                          if (result != null) {
                                                            controller.destinationLocationController.value.text = result.formattedAddress.toString();
                                                            controller.destinationLocationLAtLng.value = LocationLatLng(latitude: result.latLng!.latitude, longitude: result.latLng!.longitude);
                                                            controller.calculateAmount();
                                                          }
                                                        },
                                                        child: TextFieldThem.buildTextFiled(context,
                                                            hintText: 'Enter destination Location', controller: controller.destinationLocationController.value, enable: false)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text("Select Vehicle", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, letterSpacing: 1)),
                                    const SizedBox(
                                      height: 05,
                                    ),
                                    SizedBox(
                                      height: Responsive.height(18, context),
                                      child: ListView.builder(
                                        itemCount: controller.serviceList.length,
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          ServiceModel serviceModel = controller.serviceList[index];
                                          return Obx(
                                            () => InkWell(
                                              onTap: () {
                                                controller.selectedType.value = serviceModel;
                                                controller.calculateAmount();
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(6.0),
                                                child: Container(
                                                  width: Responsive.width(28, context),
                                                  decoration: BoxDecoration(
                                                      color: controller.selectedType.value == serviceModel
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
                                                      Text(serviceModel.title.toString(),
                                                          style: GoogleFonts.poppins(
                                                              color: controller.selectedType.value == serviceModel
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
                                                    width: Responsive.width(100, context),
                                                    decoration: const BoxDecoration(color: AppColors.gray, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                    child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                        child: Center(
                                                          child: controller.selectedType.value.offerRate == true
                                                              ? RichText(
                                                                  text: TextSpan(
                                                                    text:
                                                                        'Recommended Price is ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}',
                                                                    style: GoogleFonts.poppins(color: Colors.black),
                                                                  ),
                                                                )
                                                              : RichText(
                                                                  text: TextSpan(
                                                                      text:
                                                                          'Your Price is ${Constant.amountShow(amount: controller.amount.value)}. Approx time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}',
                                                                      style: GoogleFonts.poppins(color: Colors.black)),
                                                                ),
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible: controller.selectedType.value.offerRate == true,
                                      child: TextFieldThem.buildTextFiledWithPrefixIcon(
                                        context,
                                        hintText: "Enter your offer rate",
                                        controller: controller.offerYourRateController.value,
                                        prefix: Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: Text(Constant.currencyModel!.symbol.toString()),
                                        ),
                                      ),
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
                                      title: "Book Ride",
                                      btnWidthRatio: Responsive.width(100, context),
                                      onPress: () async {
                                        if (controller.selectedPaymentMethod.value.isEmpty) {
                                          ShowToastDialog.showToast("Please select Payment Method");
                                        } else if (controller.sourceLocationController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please select source location");
                                        } else if (controller.destinationLocationController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please select destination location");
                                        } else if (double.parse(controller.distance.value) <= 2) {
                                          ShowToastDialog.showToast("Please select more than two ${Constant.distanceType} location");
                                        } else if (controller.selectedType.value.offerRate == true && controller.offerYourRateController.value.text.isEmpty) {
                                          ShowToastDialog.showToast("Please Enter offer rate");
                                        } else {
                                          // ShowToastDialog.showLoader("Please wait");
                                          OrderModel orderModel = OrderModel();
                                          orderModel.id = Constant.getUuid();
                                          orderModel.userId = FireStoreUtils.getCurrentUid();
                                          orderModel.sourceLocationName = controller.sourceLocationController.value.text;
                                          orderModel.destinationLocationName = controller.destinationLocationController.value.text;
                                          orderModel.sourceLocationLAtLng = controller.sourceLocationLAtLng.value;
                                          orderModel.destinationLocationLAtLng = controller.destinationLocationLAtLng.value;
                                          orderModel.distance = controller.distance.value;
                                          orderModel.distanceType = Constant.distanceType;
                                          orderModel.offerRate = controller.selectedType.value.offerRate == true ? controller.offerYourRateController.value.text : controller.amount.value;
                                          orderModel.serviceId = controller.selectedType.value.id;
                                          GeoFirePoint position =
                                              GeoFlutterFire().point(latitude: controller.sourceLocationLAtLng.value.latitude!, longitude: controller.sourceLocationLAtLng.value.longitude!);

                                          orderModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
                                          orderModel.createdDate = Timestamp.now();
                                          orderModel.status = Constant.ridePlaced;
                                          orderModel.paymentType = controller.selectedPaymentMethod.value;
                                          orderModel.paymentStatus = false;
                                          orderModel.service = controller.selectedType.value;
                                          orderModel.adminCommission = Constant.adminCommission;
                                          orderModel.otp = Constant.getReferralCode();
                                          orderModel.taxList = Constant.taxList;

                                          // FireStoreUtils().startStream();
                                          FireStoreUtils().sendOrderData(orderModel).listen((event) {
                                            print("111");
                                            print("${event.length}");
                                            event.forEach((element) async {
                                              if (element.fcmToken != null) {
                                                await SendNotification.sendOneNotification(
                                                    token: element.fcmToken.toString(), title: 'New Ride Available', body: 'A customer has placed an ride near your location.', payload: {});
                                              }
                                            });
                                            FireStoreUtils().closeStream();
                                          });
                                          await FireStoreUtils.setOrder(orderModel).then((value) {
                                            ShowToastDialog.showToast("Ride Placed successfully");
                                            controller.dashboardController.selectedDrawerIndex(2);
                                            ShowToastDialog.closeLoader();
                                          });
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
        });
  }

  paymentMethodDialog(BuildContext context, HomeController controller) {
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
}
