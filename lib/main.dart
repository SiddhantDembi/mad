import 'dart:convert';
import 'api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _cityController = TextEditingController();
  String _weatherData = "";

Future<String> _getWeatherData(String apiKey, String city) async {
  final response = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final String description = data['weather'][0]['description'];
    final double temperatureInKelvin = data['main']['temp'];
    final double temperatureInCelsius = temperatureInKelvin - 273.15;
    return 'Description: $description\nTemperature: ${temperatureInCelsius.toStringAsFixed(1)} °C';
  } else {
    throw Exception('Failed to load weather data');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String city = _cityController.text;
                String weatherData =
                    await _getWeatherData(openWeatherApiKey, city);
                setState(() {
                  _weatherData = weatherData;
                });
              },
              child: Text('Get Weather'),
            ),
            SizedBox(height: 20),
            Text(
              _weatherData,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
