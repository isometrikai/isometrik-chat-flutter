import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatLocationMessage extends StatelessWidget {
  const IsmChatLocationMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    var latLong = const LatLng(0, 0);
    if (message.body.isValidUrl) {
      latLong = message.body.position;
    } else {
      latLong = LatLng(message.attachments?.first.latitude ?? 0,
          message.attachments?.first.longitude ?? 0);
    }
    final data = IsmChatProperties.chatPageProperties.isShowMessageBlur
        ?.call(context, message);
    return BlurFilter.widget(
      isBlured: data?.shouldBlured ?? false,
      sigmaX: data?.sigmaX ?? 3,
      sigmaY: data?.sigmaY ?? 3,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: (IsmChatResponsive.isWeb(context))
                      ? context.height * .3
                      : context.height * .2,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(IsmChatDimens.ten),
                  child: IgnorePointer(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: latLong,
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('1'),
                          position: latLong,
                          infoWindow:
                              const InfoWindow(title: 'Shared Location'),
                        )
                      },
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      rotateGesturesEnabled: false,
                      scrollGesturesEnabled: false,
                      buildingsEnabled: true,
                      mapToolbarEnabled: false,
                      tiltGesturesEnabled: false,
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: false,
                      trafficEnabled: false,
                    ),
                  ),
                ),
              ),
              IsmChatDimens.boxHeight4,
              Material(
                color: Colors.transparent,
                child: Padding(
                  padding: IsmChatDimens.edgeInsets4_0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.body.isValidUrl
                            ? message.metaData?.locationAddress ?? ''
                            : message.attachments?.first.title ?? '',
                        style: message.style,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        message.body.isValidUrl
                            ? message.metaData?.locationSubAddress ?? ''
                            : message.attachments?.first.address ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        style: (message.sentByMe
                                ? IsmChatStyles.w400White12
                                : IsmChatStyles.w400Black12)
                            .copyWith(
                          color: message.style.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (message.isUploading == true)
            IsmChatUtility.circularProgressBar(
                IsmChatColors.blackColor, IsmChatConfig.chatTheme.primaryColor),
        ],
      ),
    );
  }
}
