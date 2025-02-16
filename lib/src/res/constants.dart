class IsmChatAssets {
  const IsmChatAssets._();

  static const String _base = 'packages/isometrik_chat_flutter/assets';

  static const String _svgBase = '$_base/svg';
  static const String _imageBase = '$_base/images';
  static const String backgroundImages = '$_base/background_images';

  static const String noImage = '$_imageBase/noperson.png';

  static const String pdfSvg = '$_svgBase/pdf.svg';
  static const String txtSvg = '$_svgBase/txt.svg';
  static const String xlsSvg = '$_svgBase/xls.svg';

  static const String gallarySvg = '$_svgBase/gallary.svg';
  static const String placeHolderSvg = '$_svgBase/placeholder.svg';
  static const String publicGroupSvg = '$_svgBase/public_group.svg';
}

class IsmChatConstants {
  const IsmChatConstants._();

  static const Duration transitionDuration = Duration(milliseconds: 300);
  static const Duration swipeDuration = Duration(milliseconds: 300);
  static const Duration bottomSheetDuration = Duration(milliseconds: 200);
  static const int keepAlivePeriod = 60;

  static const int attachmentHight = 130;

  static const int attachmentShowLine = 3;

  static const String profileUrl =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

  static const String mapAPIKey = 'AIzaSyC2YXqs5H8QSfN1NVsZKsP11XLZhfGVGPI';

  /// Video Type List For Every Platform
  static List<String> videoExtensions = [
    'mp4',
    'MP4',
    'webm',
    'mkv',
    'flv',
    'vob',
    'ogv',
    'ogg',
    'rrc',
    'gifv',
    'mng',
    'mov',
    'avi',
    'qt',
    'wmv',
    'yuv',
    'rm',
    'asf',
    'amv',
    'mp4',
    'MP4',
    'm4p',
    'm4v',
    'mpg',
    'mp2',
    'mpeg',
    'mpe',
    'mpv',
    'm4v',
    'svi',
    '3gp',
    '3g2',
    'mxf',
    'roq',
    'nsv',
    'flv',
    'f4v',
    'f4p',
    'f4a',
    'f4b',
    'mod',
  ];

  /// Image Type List For Every Platform
  static List<String> imageExtensions = [
    'ase',
    'art',
    'bmp',
    'blp',
    'cd5',
    'cit',
    'cpt',
    'cr2',
    'cut',
    'dds',
    'dib',
    'djvu',
    'egt',
    'exif',
    'gif',
    'gpl',
    'grf',
    'icns',
    'ico',
    'iff',
    'jng',
    'jpeg',
    'jpg',
    'jfif',
    'jp2',
    'jps',
    'lbm',
    'max',
    'miff',
    'mng',
    'msp',
    'nitf',
    'ota',
    'pbm',
    'pc1',
    'pc2',
    'pc3',
    'pcf',
    'pcx',
    'pdn',
    'pgm',
    'PI1',
    'PI2',
    'PI3',
    'pict',
    'pct',
    'pnm',
    'pns',
    'ppm',
    'psb',
    'psd',
    'pdd',
    'psp',
    'px',
    'pxm',
    'pxr',
    'qfx',
    'raw',
    'rle',
    'sct',
    'sgi',
    'rgb',
    'int',
    'bw',
    'tga',
    'tiff',
    'tif',
    'vtf',
    'xbm',
    'xcf',
    'xpm',
    '3dv',
    'amf',
    'ai',
    'awg',
    'cgm',
    'cdr',
    'cmx',
    'dxf',
    'e2d',
    'egt',
    'eps',
    'fs',
    'gbr',
    'odg',
    'stl',
    'vrml',
    'x3d',
    'sxd',
    'v2d',
    'vnd',
    'wmf',
    'emf',
    'art',
    'xar',
    'png',
    'webp',
    'jxr',
    'hdp',
    'wdp',
    'cur',
    'ecw',
    'iff',
    'lbm',
    'liff',
    'nrrd',
    'pam',
    'pcx',
    'pgf',
    'sgi',
    'rgb',
    'rgba',
    'bw',
    'int',
    'inta',
    'sid',
    'ras',
    'sun',
    'tga'
  ];

  /// File Type List For Every Platform
  static List<String> audioExtensions = [
    'm4a',
    'mp3',
    'flac',
    'mp4',
    'wav',
    'wma',
    'aac',
    'pcm',
    'aiff',
    'alac',
  ];

  /// File Type List For Every Platform
  static List<String> fileExtensions = [
    'pdf',
    'xlsx',
    'xlsm',
    'xlsb',
    'xltx',
    'xltm',
    'xls',
    'xlt',
    'xml',
    'xlam',
    'xla',
    'xlw',
    'xlr',
    'prn',
    'txt',
    'csv',
    'dif',
    'slk',
    'dbf',
    'ods',
    'xps',
    'wmf',
    'emf',
    'bmp',
    'rtf',
    'gif',
    'jpg',
    'doc',
    'mht',
    'mhtml',
    'htm',
    'html',
    'xlc',
    'wk1',
    'wk2',
    'wk3',
    'wk4',
    'wks',
    'wq1',
    'wb1',
    'wb3',
    'dsn',
    'mde',
    'odc',
    'udl',
  ];
}
