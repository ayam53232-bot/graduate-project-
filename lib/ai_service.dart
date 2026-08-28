import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  static const String apiKey =
      'AQ.Ab8RN6LJ1CD9CN2i5Xw3oYmgM9lRRL4GT_pGDTOjeoaPUeHwJQ';

  static const String model =
      'gemini-2.0-flash-lite';

  Future<String> sendMessage(
      String message,
      ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': message,
              },
            ],
          },
        ],
      }),
    );

    debugPrint(
      'STATUS CODE: ${response.statusCode}',
    );

    debugPrint(
      'RESPONSE: ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini Error: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final text =
    data['candidates']?[0]?['content']?['parts']?[0]?['text'];

    if (text == null) {
      throw Exception(
        'No response from Gemini',
      );
    }

    return text.toString();
  }
}