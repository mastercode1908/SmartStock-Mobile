import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:5246/api/inventory-counts/mobile'));
    print('Status: \${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        print(json.encode(data.first));
      } else {
        print('Empty array');
      }
    } else {
      print(response.body);
    }
  } catch (e) {
    print(e);
  }
}
