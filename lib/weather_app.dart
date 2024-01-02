import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  @override
  void initState() {
    super.initState();
    getWeatherInfo();
  }

  Future<Map<String, dynamic>> getWeatherInfo() async {
    String city = 'London,uk';
    String apiKey = '46928cb6ca03d5fa7e4cae8937cffdb9';
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=${city}&APPID=${apiKey}'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'unexpected error occured';
      }
      return data;
      //double
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(),
        ),
      ),
      body: FutureBuilder(
        future: getWeatherInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) throw 'undexpected error occured';
          final data = snapshot.data!;
          final currentData = data['list'][0];
          final currentTemp = currentData['main']["temp"];
          final currentWeather = currentData['weather'][0]['main'];
          final currentPressure = currentData['main']['pressure'];
          final currentHumidity = currentData['main']['humidity'];
          final currentWindSpeed = currentData['wind']['speed'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card`
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: SizedBox(
                    width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp k',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Icon(
                                currentWeather == 'Clouds' ||
                                        currentWeather == 'rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '$currentWeather',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                
                const SizedBox(
                  height: 20,
                ),
                //weather forcast cards
                const Text(
                  'Hourly Forcast',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                // const SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                      
                //         HourlyForcastCard(
                //           icon: Icons.sunny,
                //           time: '',
                //           temp: "27",
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky =
                          data['list'][index + 1]['weather'][0]['main'];
                      final hourlyTemp =
                          hourlyForecast['main']['temp'].toString();
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForcastCard(
                        time: DateFormat.j().format(time),
                        temp: hourlyTemp,
                        icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                //additional information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AdditionalInformationItem(
                        icon: Icons.water,
                        lable: "Humidity",
                        value: currentHumidity.toString()),
                    AdditionalInformationItem(
                        icon: Icons.air,
                        lable: "Pressure",
                        value: currentPressure.toString()),
                    AdditionalInformationItem(
                        icon: Icons.speed,
                        lable: "Wind Speed",
                        value: currentWindSpeed.toString()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          setState(() {
            
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class HourlyForcastCard extends StatelessWidget {
  final IconData icon;
  final String time;
  final String temp;
  const HourlyForcastCard({
    super.key,
    required this.icon,
    required this.temp,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(time),
            const SizedBox(height: 8),
            Text(temp),
          ],
        ),
      ),
    );
  }
}

class AdditionalInformationItem extends StatelessWidget {
  final IconData icon;
  final String lable;
  final String value;
  const AdditionalInformationItem({
    super.key,
    required this.icon,
    required this.lable,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
        ),
        const SizedBox(height: 5),
        Text(
          lable,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
