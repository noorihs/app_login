
import 'dart:io';
import 'faceplusplus_service.dart';

class FaceRecognitionService {
  static Future<bool> compare({
    required String referenceUrl,
    required File loginImage,
  }) async {
    return await FacePlusPlusService.compareFaces(loginImage, referenceUrl);
  }
}