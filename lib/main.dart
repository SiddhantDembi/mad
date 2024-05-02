// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_key_in_widget_constructors

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
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _cityController = TextEditingController();
  String _weatherData = "";

  Future<Map<String, dynamic>> _getCityCoordinates(String city) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$openWeatherApiKey'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final double lat = data['coord']['lat'];
      final double lon = data['coord']['lon'];
      return {'lat': lat, 'lon': lon};
    } else {
      throw Exception('City not found or invalid');
    }
  }

  Future<Map<String, dynamic>> _getWeatherData(
    String openWeatherApiKey, double lat, double lon) async {
    final weatherResponse = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$openWeatherApiKey'));
    final airQualityResponse = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$openWeatherApiKey'));

    if (weatherResponse.statusCode == 200 &&
        airQualityResponse.statusCode == 200) {
      final Map<String, dynamic> weatherData =
          json.decode(weatherResponse.body);
      final Map<String, dynamic> airQualityData =
          json.decode(airQualityResponse.body);

      final String description = weatherData['weather'][0]['description'];
      final double temperatureInKelvin = weatherData['main']['temp'];
      final double temperatureInCelsius = temperatureInKelvin - 273.15;
      final int airQualityIndex = airQualityData['list'][0]['main']['aqi'];

      final int timezoneSeconds = weatherData['timezone'];
      final int timezoneHours = (timezoneSeconds / 3600).truncate();
      final int timezoneMinutes = ((timezoneSeconds % 3600) ~/ 60).abs();
      final String timezoneFormatted =
          '${timezoneHours >= 0 ? '+' : '-'}${timezoneHours.abs()}:${timezoneMinutes.toString().padLeft(2, '0')}';

      final int cloudiness = weatherData['clouds']['all'];
      final double windSpeed = weatherData['wind']['speed'];
      final int windDirection = weatherData['wind']['deg'];
      final double pressure = weatherData['main']['pressure'];
      final int humidity = weatherData['main']['humidity'];

      return {
        'description': description,
        'temperature': temperatureInCelsius.toStringAsFixed(1),
        'airQuality': airQualityIndex,
        'timezone': timezoneFormatted,
        'cloudiness': cloudiness,
        'windSpeed': windSpeed,
        'windDirection': windDirection,
        'pressure': pressure,
        'humidity': humidity,
      };
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          Text(
            'Weather App',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
        ],
      ),
    ),
    

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String city = _cityController.text;
                try {
                  Map<String, dynamic> coordinates =
                      await _getCityCoordinates(city);
                  double lat = coordinates['lat'];
                  double lon = coordinates['lon'];
                  Map<String, dynamic> weatherData =
                      await _getWeatherData(openWeatherApiKey, lat, lon);
                  setState(() {
                    _weatherData =
                        'Latitude: $lat\nLongitude: $lon\nDescription: ${weatherData['description']}\nTemperature: ${weatherData['temperature']} °C\nAir Quality: ${weatherData['airQuality']}\nTimezone: ${weatherData['timezone']}\nCloudiness: ${weatherData['cloudiness']}%\nWind Speed: ${weatherData['windSpeed']} m/s\nWind Direction: ${weatherData['windDirection']}°\nPressure: ${weatherData['pressure']} hPa\nHumidity: ${weatherData['humidity']}%';
                  });
                } catch (error) {
                  setState(() {
                    _weatherData = 'Error: $error';
                  });
                }
              },
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 20),
            Text(
              _weatherData,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
