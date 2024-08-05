import 'dart:async';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:isometrik_flutter_chat/src/res/properties/chat_properties.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// show the Forward Message View
class IsmChatLocationWidget extends StatefulWidget {
  const IsmChatLocationWidget({super.key});

  static const String route = IsmPageRoutes.location;

  @override
  State<IsmChatLocationWidget> createState() => _IsmLocationWidgetViewState();
}

class _IsmLocationWidgetViewState extends State<IsmChatLocationWidget> {
  final Completer<GoogleMapController> mapController = Completer();
  final ismChatPageController = Get.find<IsmChatPageController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.7046, 76.7179),
    zoom: 14,
  );

  LatLng? latLng;

  final List<Marker> _markers = <Marker>[];

  Future<void> loadData() async => getUserCurrentLocation().then((value) async {
        _markers.add(
          Marker(
              markerId: const MarkerId('2'),
              position: LatLng(value.latitude, value.longitude),
              infoWindow: const InfoWindow(title: 'Current Location')),
        );

        var cameraPosition = CameraPosition(
            zoom: 14, target: LatLng(value.latitude, value.longitude));

        final controller = await mapController.future;
        await controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        await ismChatPageController.getLocation(
            latitude: value.latitude.toString(),
            longitude: value.longitude.toString());
        setState(() {});
      });

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {});
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => Scaffold(
          backgroundColor: IsmChatColors.whiteColor,
          appBar: AppBar(
            backgroundColor: IsmChatConfig.chatTheme.primaryColor,
            titleSpacing: 0,
            actions: <Widget>[
              IconButton(
                icon: controller.isSearchSelect
                    ? const Icon(
                        Icons.close,
                        color: IsmChatColors.whiteColor,
                      )
                    : const Icon(
                        Icons.search,
                        color: IsmChatColors.whiteColor,
                      ),
                onPressed: () async {
                  controller.isSearchSelect = !controller.isSearchSelect;
                  controller.textEditingController.clear();

                  if (!controller.isSearchSelect) {
                    await controller.getLocation(
                        latitude: latLng!.latitude.toString(),
                        longitude: latLng!.longitude.toString());
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: IsmChatColors.whiteColor,
                ),
                onPressed: () async {
                  if (controller.textEditingController.text.isNotEmpty) {
                    controller.isSearchSelect = !controller.isSearchSelect;
                    controller.textEditingController.clear();
                  }

                  await controller.getLocation(
                      latitude: latLng!.latitude.toString(),
                      longitude: latLng!.longitude.toString());
                },
              ),
            ],
            centerTitle: false,
            title: Row(
              children: [
                IsmChatDimens.boxWidth16,
                controller.isSearchSelect
                    ? Flexible(
                        child: IsmChatInputField(
                        fillColor: IsmChatConfig.chatTheme.primaryColor,
                        onFieldSubmitted: (input) async {
                          await controller.getLocation(
                              searchKeyword: input,
                              latitude: latLng!.latitude.toString(),
                              longitude: latLng!.longitude.toString());
                        },
                        onChanged: (value) {
                          controller.ismChatDebounce.run(
                            () async {
                              await controller.getLocation(
                                  searchKeyword: value.isNotEmpty ? value : '',
                                  latitude: latLng!.latitude.toString(),
                                  longitude: latLng!.longitude.toString());
                            },
                          );
                        },
                        controller: controller.textEditingController,
                        textInputAction: TextInputAction.search,
                        autofocus: true,
                        cursorColor: IsmChatColors.whiteColor,
                        style: IsmChatStyles.w500White16,
                        hint: 'Search',
                        hintStyle: IsmChatStyles.w600White16,
                      ))
                    : Text(
                        'Send location',
                        style: controller.isSearchSelect
                            ? IsmChatStyles.w600Black16
                            : IsmChatStyles.w600White16,
                      ),
              ],
            ),
            leading: IconButton(
              onPressed: () {
                controller.isSearchSelect
                    ? controller.isSearchSelect = false
                    : Get.back<void>();
              },
              icon: Icon(
                Icons.adaptive.arrow_back,
                color: IsmChatColors.whiteColor,
              ),
            ),
            automaticallyImplyLeading: false,
            elevation: 1,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                SizedBox(
                    height: IsmChatDimens.percentHeight(.35),
                    width: Get.width,
                    child: GoogleMap(
                      initialCameraPosition: _kGooglePlex,
                      markers: Set<Marker>.of(_markers),
                      onMapCreated: mapController.complete,
                      myLocationButtonEnabled: false,
                      onCameraMove: (position) {
                        controller.ismChatDebounce.run(() async {
                          latLng = LatLng(position.target.latitude,
                              position.target.longitude);
                          setState(() {});
                        });
                      },
                    )),
                Positioned(
                  right: IsmChatDimens.twenty,
                  top: IsmChatDimens.twenty,
                  child: Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () async {
                          await loadData();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.8),
                          ),
                          height: IsmChatDimens.thirtyFive,
                          width: IsmChatDimens.thirtyFive,
                          child: Icon(
                            Icons.my_location,
                            color: Colors.grey,
                            size: IsmChatDimens.twenty,
                          ),
                        ),
                      )),
                ),
              ]),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IsmChatDimens.boxHeight16,
                      Padding(
                        padding: EdgeInsets.only(left: IsmChatDimens.ten),
                        child: Text(
                          'Nearby Places',
                          style: IsmChatStyles.w400Grey10,
                        ),
                      ),
                      IsmChatDimens.boxHeight16,
                      if (controller.predictionList.isNotEmpty)
                        Padding(
                          padding: IsmChatDimens.edgeInsets10_0,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.my_location,
                                color: Colors.teal,
                              ),
                              IsmChatDimens.boxWidth8,
                              IsmChatTapHandler(
                                onTap: () async {
                                  IsmChatUtility.showLoader();
                                  final addresses = await GeocodingPlatform
                                      .instance
                                      ?.placemarkFromCoordinates(
                                    latLng?.latitude ?? 0,
                                    latLng?.longitude ?? 0,
                                  );
                                  if (addresses == null) return;
                                  if (addresses.isEmpty) return;
                                  controller.sendLocation(
                                    conversationId: controller
                                            .conversation?.conversationId ??
                                        '',
                                    userId: controller.conversation
                                            ?.opponentDetails?.userId ??
                                        '',
                                    latitude: latLng!.latitude,
                                    longitude: latLng!.longitude,
                                    placeId: '',
                                    locationName: '${addresses.first.name}',
                                    locationSubName:
                                        '${addresses.first.subLocality} ${addresses.first.subAdministrativeArea}',
                                  );

                                  IsmChatUtility.closeLoader();
                                  Get.back<void>();
                                  if (await IsmChatProperties.chatPageProperties
                                          .messageAllowedConfig?.isMessgeAllowed
                                          ?.call(
                                              Get.context!,
                                              Get.find<IsmChatPageController>()
                                                  .conversation!) ??
                                      true) {}
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Send your current location',
                                    ),
                                    Text(
                                      'Accurate to 12 meters',
                                      style: IsmChatStyles.w400Grey10,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (controller.predictionList.isEmpty) ...[
                        const SizedBox(
                          height: 100,
                        ),
                        if (controller.isLocaionSearch || _markers.isEmpty) ...[
                          const IsmChatLoadingDialog(),
                        ] else ...[
                          Center(
                            child: Text(
                              IsmChatStrings.noDataFound,
                              style: IsmChatStyles.w500Black14,
                            ),
                          )
                        ]
                      ] else ...[
                        ListView.builder(
                            shrinkWrap: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            physics: const ScrollPhysics(),
                            itemCount: controller.predictionList.length,
                            itemBuilder: (context, index) {
                              var prediction = controller.predictionList[index];

                              return IsmChatTapHandler(
                                onTap: () async {
                                  Get.back<void>();
                                  if (await IsmChatProperties.chatPageProperties
                                          .messageAllowedConfig?.isMessgeAllowed
                                          ?.call(
                                              Get.context!,
                                              Get.find<IsmChatPageController>()
                                                  .conversation!) ??
                                      true) {
                                    controller.sendLocation(
                                        conversationId: controller
                                                .conversation?.conversationId ??
                                            '',
                                        userId: controller.conversation
                                                ?.opponentDetails?.userId ??
                                            '',
                                        latitude: controller
                                                .predictionList[index]
                                                .geometry
                                                ?.location
                                                ?.lat ??
                                            0,
                                        longitude: controller
                                                .predictionList[index]
                                                .geometry
                                                ?.location
                                                ?.lng ??
                                            0,
                                        placeId:
                                            controller.predictionList[index].placeId ?? '',
                                        locationName: controller.predictionList[index].name ?? '',
                                        locationSubName: controller.predictionList[index].vicinity ?? '');
                                  }
                                },
                                child: ListTile(
                                  minLeadingWidth: 0,
                                  leading: const Icon(
                                    Icons.house_siding,
                                  ),
                                  title: SizedBox(
                                    width: Get.width - 100,
                                    child: Text(
                                      prediction.name ?? '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  subtitle: Text(
                                    prediction.vicinity ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            })
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).withUnfocusGestureDetctor(context),
      );
}
