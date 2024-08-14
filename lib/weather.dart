import 'dart:convert';
import "dart:ui";
import 'package:diacritic/diacritic.dart';
import 'package:intl/intl.dart';

import "package:flutter/material.dart";
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mausam/keyfile.dart';
import 'package:mausam/citysearch.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = 'New Delhi';
  String prevCityName = 'New Delhi';
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey',
      ));
      final name = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&APPID=$apiKey',
      ));

      if (res.statusCode == 200 && name.statusCode == 200) {
        final data = jsonDecode(res.body);
        final cityData = jsonDecode(name.body);

        data['city'] = cityData['name'];
        data['country'] = cityData['sys']['country'];

        if (data['cod'].toString() == '200') {
          prevCityName =
              cityName; // Update prevCityName with the current cityName

          return data;
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      } else if (res.statusCode == 404 || name.statusCode == 404) {
        // Show error dialog and reset the city name after user presses OK
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, "City not found!");
        });

        throw Exception(
            "City not found. Please check the city name and try again.");
      } else {
        throw Exception("Network Error: ${res.statusCode}");
      }
    } catch (e) {
      // Catch any other errors, like network issues
      throw Exception("Error fetching weather data: ${e.toString()}");
    }
  }

  Future<void> _navigateAndSearchCity(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitySearchScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        cityName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,

        // backgroundColor: Colors.red,
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_sharp),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          //print(snapshot.data);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            //print("$snapshot.error  ---ERORRRRRRRRR");
            final error = snapshot.error.toString();
            if (error.contains("City not found")) {
              return Container(
                color: Colors.transparent, // or any other color
              );
            } else {
              return Center(child: Text(snapshot.error.toString()));
            }
          }

          final data = snapshot.data!;
          final currentime = data['list'][0]['main']['temp'];
          final currentstatus = data['list'][0]['weather'][0]['description'];
          final iconCode = data['list'][0]['weather'][0]['icon'];

          final pres = data['list'][0]['main']['pressure'];
          final windSpeed = data['list'][0]['wind']['speed'];
          final humidity = data['list'][0]['main']['humidity'];

          //  print("Collecting info for ${data['city']} , ${data['country']}");

          return Padding(
            padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const SizedBox(
                //  height: 10,
                //),

                /*Container(
                  /*decoration: BoxDecoration(
                        border: Border.all(
                        color: Colors.blue, // Border color
                        width: 3.0,        // Border width
                        ),
                        borderRadius: BorderRadius.circular(8.0), // Optional: Border radius
                  ),*/
                  //height: 40,
                  width: double.infinity,
                  child :  Center(child: Text("${data['city']} , ${data['country']}", style: const TextStyle(
                    fontSize: 40,fontWeight: FontWeight.w200
                  ),)),
                ),*/
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                  ), // Adds space from the top
                  child: GestureDetector(
                    onTap: () => _navigateAndSearchCity(context),
                    child: AnimatedOpacity(
                      duration: const Duration(seconds: 2),
                      opacity: 1.0, // Start with 0.0 and animate to 1.0
                      child: Center(
                        child: Text(
                          removeDiacritics(
                              "${data['city']} , ${data['country']}"),
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w200,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: <Color>[Colors.blue, Colors.red],
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                              ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //MAIN CARD

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    //color: Colors.brown,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                //"28°ᶜ",
                                //"${(double.parse(currentime)-273.15).toString()} K",
                                "${(currentime - 273.15).round()}°C",
                                //"${(currentime - 273.15)}°C",

                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              //const SizedBox(
                              //   height: 10,
                              //),
                              Image.network(
                                'http://openweathermap.org/img/wn/$iconCode@2x.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    // If loading is complete, show the image
                                    return child;
                                  } else {
                                    // While the image is loading, show a CircularProgressIndicator
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                                  }
                                },
                              ),

                              // const SizedBox(
                              //  height: 10,
                              //),
                              Text(
                                currentstatus,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //FORECAST
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                /*const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      RowCard(
                        icon: MdiIcons.weatherCloudy,
                        time: "02:00 AM",
                        temp: "18°ᶜ",
                      ),
                      RowCard(
                        icon: MdiIcons.weatherRainy,
                        time: "04:00 AM",
                        temp: "14°ᶜ",
                      ),
                      RowCard(
                        icon: MdiIcons.weatherSnowyHeavy,
                        time: "06:00 AM",
                        temp: "4°ᶜ",
                      ),
                      RowCard(
                        icon: MdiIcons.weatherLightning,
                        time: "08:00 AM",
                        temp: "10°ᶜ",
                      ),
                      RowCard(
                        icon: MdiIcons.weatherSunny,
                        time: "10:00 AM",
                        temp: "25°ᶜ",
                      ),
                    ],
                  ),
                ),*/

                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast =
                          data['list'][index + 2]['main']['temp'];
                      final hourlyTime =
                          DateTime.parse((data['list'][index + 2]['dt_txt']));
                      final forecastIcon =
                          data['list'][index + 2]['weather'][0]['icon'];

                      final str =
                          'http://openweathermap.org/img/wn/$forecastIcon@2x.png';

                      return RowCard(
                          link: str,
                          time: DateFormat.j().format(hourlyTime).toString(),
                          temp: "${(hourlyForecast - 273.15).round()} °C");
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Additional Information",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //ADDITIONAL INFO - HUMIDITY
                      Column(
                        children: [
                          const Icon(
                            Icons.water_drop_sharp,
                            size: 40,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "Humidity",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            //"94",
                            "$humidity%",
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      //SizedBox(width: 70,),
                      //ADDITOINAL INFO - WIND SPEED
                      Column(
                        children: [
                          const Icon(
                            Icons.air,
                            size: 40,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "Wind Speed",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            //"7.67",
                            "$windSpeed m/s",
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      //SizedBox(width: 70,),
                      //ADDITOINAL INFO - PRESSURE
                      Column(
                        children: [
                          const Icon(
                            // Icons.beach_access,
                            //MdiIcons.speedometer,
                            MdiIcons.waves,
                            size: 40,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "Pressure",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            //"1006",
                            "$pres hPa",
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // Restore the previous valid city name
                  cityName = prevCityName;
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class RowCard extends StatelessWidget {
  final String time;
  final String temp;
  final String link;
  //final Image.network photo;

  const RowCard(
      {super.key, required this.link, required this.time, required this.temp}
      //required
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 115,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.network(
                link,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    // If loading is complete, show the image
                    return child;
                  } else {
                    // While the image is loading, show a CircularProgressIndicator
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                temp,
                style: const TextStyle(
                  fontSize: 14,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
