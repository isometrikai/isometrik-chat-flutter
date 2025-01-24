import 'package:flutter/material.dart';

class IsmChatMessageConstraints {
  IsmChatMessageConstraints({
    this.textConstraints,
    this.imageConstraints,
    this.videoConstraints,
    this.audioConstraints,
    this.locationConstraints,
    this.contactConstraints,
    this.fileConstraints,
  });
  final BoxConstraints? textConstraints;
  final BoxConstraints? imageConstraints;
  final BoxConstraints? videoConstraints;
  final BoxConstraints? audioConstraints;
  final BoxConstraints? fileConstraints;
  final BoxConstraints? locationConstraints;
  final BoxConstraints? contactConstraints;
}
