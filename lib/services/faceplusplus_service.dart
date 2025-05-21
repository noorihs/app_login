
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class FacePlusPlusService {
  static const String apiKey = 'QhOyjCfmxw-BLFoWKiPtLdT0AVO6kmzS';
  static const String apiSecret = 'FmG-wJpxoKO6ytfTaMD4xJbjPeiWXeBy';

  static Future<bool> compareFaces(File loginImage, String referenceImageUrl) async {
    final uri = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/compare');

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['api_secret'] = apiSecret
      ..fields['image_url2'] = referenceImageUrl
      ..files.add(await http.MultipartFile.fromPath(
        'image_file1',
        loginImage.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      print("❌ Erreur API Face++ : \${response.body}");
      return false;
    }

    final data = jsonDecode(response.body);
    final confidence = data['confidence'] ?? 0;
    print("🎯 Similarité Face++ : \$confidence");

    // Seuil recommandé par Face++ : >70 pour être confiant
    return confidence >= 80;
  }
}