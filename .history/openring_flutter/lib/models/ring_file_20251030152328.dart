import 'package:freezed_annotation/freezed_annotation.dart';

part 'ring_file.freezed.dart';
part 'ring_file.g.dart';

/// 戒指端文件信息
@freezed
class RingFile with _$RingFile {
  const factory RingFile({
    required String fileName,
    required int fileSize,
    required int fileType,
    String? userId,
    String? timestamp,
    String? localPath,
    @Default(false) bool isDownloaded,
  }) = _RingFile;

  factory RingFile.fromJson(Map<String, dynamic> json) =>
      _$RingFileFromJson(json);
}

extension RingFileX on RingFile {
  String get fileTypeDescription {
    switch (fileType) {
      case 1:
        return '3轴数据';
      case 2:
        return '6轴数据';
      case 3:
        return 'PPG IR+Red+3轴 (SpO2)';
      case 4:
        return 'PPG Green';
      case 5:
        return 'PPG IR';
      case 6:
        return '温度 IR';
      case 7:
        return 'IR+Red+Green+Temp+3轴';
      case 8:
        return 'PPG Green+3轴 (HR)';
      default:
        return '未知类型';
    }
  }

  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
