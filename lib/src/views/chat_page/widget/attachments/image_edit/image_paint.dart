import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_painter/image_painter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:path_provider/path_provider.dart';

class IsmChatImagePainterWidget extends StatefulWidget {
  const IsmChatImagePainterWidget({super.key, required this.file});

  final File file;

  @override
  State<IsmChatImagePainterWidget> createState() => _ImagePainterWidgetState();
}

class _ImagePainterWidgetState extends State<IsmChatImagePainterWidget> {
  final ImagePainterController _controller = ImagePainterController(
    color: IsmChatColors.primaryColorLight,
    strokeWidth: 4,
    mode: PaintMode.line,
  );
  final _key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) => Scaffold(
        key: _key,
        appBar: AppBar(
          leading: InkWell(
            child: const Icon(
              Icons.arrow_back,
              color: IsmChatColors.whiteColor,
            ),
            onTap: () {
              Get.back<File>(result: widget.file);
            },
          ),
          backgroundColor: IsmChatConfig.chatTheme.primaryColor,
          actions: [
            TextButton(
              onPressed: () async {
                IsmChatUtility.showLoader();
                final image = await _controller.exportImage();

                final pathSplite = widget.file.path.split('/').last;
                final extensionSplite = pathSplite.split('.');

                final extension = extensionSplite.last;

                final directory =
                    (await getApplicationDocumentsDirectory()).path;
                await Directory('$directory/sample').create(recursive: true);
                final fullPath =
                    '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.$extension';

                final imgFile = File(fullPath);
                imgFile.writeAsBytesSync(image ?? Uint8List(0));
                IsmChatUtility.closeLoader();
                Get.back<File>(result: imgFile);
                IsmChatLog.success('Image edit file $imgFile');
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
          File(widget.file.path),
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
