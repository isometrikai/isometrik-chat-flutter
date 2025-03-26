import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_painter/image_painter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:path_provider/path_provider.dart';

class IsmChatImagePaintView extends StatelessWidget {
  IsmChatImagePaintView({super.key});

  static const String route = IsmPageRoutes.imagePaint;

  final ImagePainterController _controller = ImagePainterController(
    color: IsmChatColors.primaryColorLight,
    strokeWidth: 4,
    mode: PaintMode.line,
  );

  final file = Get.arguments['file'] as XFile? ?? XFile('');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: InkWell(
            child: const Icon(
              Icons.arrow_back,
              color: IsmChatColors.whiteColor,
            ),
            onTap: () {
              Get.back<XFile>(result: XFile(file.path));
            },
          ),
          backgroundColor: IsmChatConfig.chatTheme.primaryColor,
          actions: [
            TextButton(
              onPressed: () async {
                IsmChatUtility.showLoader();
                final image = await _controller.exportImage();
                final pathSplite = file.path.split('/').last;
                final extension = pathSplite.split('.').last;
                final directory =
                    (await getApplicationDocumentsDirectory()).path;
                await Directory('$directory/sample').create(recursive: true);
                final fullPath =
                    '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.$extension';
                final imgFile = File(fullPath);
                imgFile.writeAsBytesSync(image ?? Uint8List(0));
                IsmChatUtility.closeLoader();
                Get.back<XFile>(result: XFile(imgFile.path));
              },
              style: ButtonStyle(
                  side: const WidgetStatePropertyAll(
                    BorderSide(
                      color: IsmChatColors.whiteColor,
                    ),
                  ),
                  padding: WidgetStatePropertyAll(IsmChatDimens.edgeInsets10),
                  textStyle:
                      WidgetStateProperty.all(IsmChatStyles.w400White16)),
              child: Text(
                'Done',
                style: IsmChatStyles.w600White16,
              ),
            ),
            IsmChatDimens.boxWidth20,
          ],
        ),
        backgroundColor: IsmChatColors.blackColor,
        body: ImagePainter.file(
          File(file.path),
          // key: _imageKey,
          controller: _controller,
          scalable: true,
          // initialStrokeWidth: 2,
          // textDelegate: DutchTextDelegate(),
          // initialColor: Colors.red,
          // initialPaintMode: PaintMode.line,
          controlsAtTop: false,
          // width: ,

          // clearAllIcon: ,
        ),
      );
}
