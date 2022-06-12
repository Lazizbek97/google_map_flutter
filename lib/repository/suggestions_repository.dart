import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

// For storing our result
class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  static const String androidKey = 'AIzaSyA58QFhsr2qSp2tqnk5DN9gwvQS39CfJZ8';
  static const String iosKey = 'AIzaSyA58QFhsr2qSp2tqnk5DN9gwvQS39CfJZ8';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(
      String input, String lang, String queryType) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=$queryType&language=$lang&components=country:uz&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
