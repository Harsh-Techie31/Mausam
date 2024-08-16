import 'dart:convert';
import "dart:ui";
import 'package:diacritic/diacritic.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mausam/keyfile.dart';
import 'package:mausam/citysearch.dart';
// import 'package:google_fonts/google_fonts.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = 'New Delhi';
  String prevCityName = 'New Delhi';
  Position? _position;

  @override
  void initState() {
    super.initState();
    getCurrentLocation().then((position) {
      setState(() {
        _position = position;
      });
      getCurrentWeather();
    });
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    String url,url2;

    if (_position != null) {
      // Use latitude and longitude if available
      final lat = _position!.latitude;
      final lon = _position!.longitude;
      //print("11111111111111111111111111111111111");
      //url = 'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&appid=$apiKey';
      url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&APPID=$apiKey';
      url2 = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&APPID=$apiKey';
    } else {
      //print("2222222222222222222222222222222");
      // Fallback to default city (New Delhi)
      url = 'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey';
      url2 = 'https://api.openweathermap.org/data/2.5/weather?q=$cityName&APPID=$apiKey';
    }


    try {
      final res = await http.get(Uri.parse(
        url,
      ));
      final name = await http.get(Uri.parse(
        url2,
      ));

      if (res.statusCode == 200 && name.statusCode == 200) {
        final data = jsonDecode(res.body);
        final cityData = jsonDecode(name.body);

        //print(data);

        data['city'] = cityData['name'];
        data['country'] = cityData['sys']['country'];

        if (data['cod'].toString() == '200') {
          prevCityName = cityName; // Update prevCityName with the current cityName
          return data;
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      } else if (res.statusCode == 404 || name.statusCode == 404) {
        // Show error dialog and reset the city name after user presses OK
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, "City not found!");
        });
        throw Exception("City not found. Please check the city name and try again.");
      } else {
        throw Exception("Network Error: ${res.statusCode}");
      }
    } catch (e) {
      // Catch any other errors, like network issues
      throw Exception("Error fetching weather data: ${e.toString()}");
    }
  }



  Future<Position?> getCurrentLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Handle the case when permission is denied permanently
      return null;
    }
  }

  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    Position currentPosition = await Geolocator.getCurrentPosition();
    //print("LOCATIONNNNNNNNNNNNNNNNNNNNNNNN :::::::::::::::: ${currentPosition.latitude} ----- ${currentPosition.longitude}");
    return currentPosition;
  } else {
    // Permission was denied or restricted, handle this case appropriately
    return null;
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
        _position = null;
      });
    }

  }

/*void _showCleanDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // Prevents closing by tapping outside
    builder: (BuildContext context) {
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.of(context).pop(); // Close the dialog after 2 seconds
      });

      return Dialog(
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        backgroundColor:  Colors.transparent,
        child: Container(
          height: 100,
          //padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color:  Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              "Thank you for\nusing the app !",
              style:  TextStyle(color: Colors.white, fontSize: 22,fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    },
  );
}*/
/*void _showCleanDialog(BuildContext context) {
  const snackBar =  SnackBar(
    content:  Text(
      "Thank you for using the app!",
      style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    duration:  Duration(seconds: 1),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}*/
void _showCleanDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // Close the dialog after 2 seconds
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.of(context).pop();
      });

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.pink, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(
                Icons.mood,
                size: 80,
                color: Colors.white,
              ),
               SizedBox(height: 10),
               Text(
                "Thank you for using the app!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
               SizedBox(height: 20),
              // Remove the OK button
            ],
          ),
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
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
              //getCurrentLocation();
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            final error = snapshot.error.toString();
            if (error.contains("City not found")) {
              return Container(
                color: Colors.transparent,
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

          return Padding(
            padding: const EdgeInsets.only(bottom: 0, right: 16, left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: GestureDetector(
                    onTap: () => _navigateAndSearchCity(context),
                    child: AnimatedOpacity(
                      duration: const Duration(seconds: 2),
                      opacity: 1.0,
                      child: Center(
                        child: Text(
                          removeDiacritics("${data['city']} , ${data['country']}"),
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
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "${(currentime - 273.15).round()}°C",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Image.network(
                                'http://openweathermap.org/img/wn/$iconCode@2x.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
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
                const SizedBox(height: 20),
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 2]['main']['temp'];
                      final hourlyTime = DateTime.parse((data['list'][index + 2]['dt_txt']));
                      final forecastIcon = data['list'][index + 2]['weather'][0]['icon'];

                      final str = 'http://openweathermap.org/img/wn/$forecastIcon@2x.png';

                      return RowCard(
                        link: str,
                        time: DateFormat.j().format(hourlyTime).toString(),
                        temp: "${(hourlyForecast - 273.15).round()} °C",
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Additional Information",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.water_drop_sharp,
                            size: 40,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Humidity",
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$humidity%",
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.air,
                            size: 40,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Wind Speed",
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$windSpeed m/s",
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(
                            MdiIcons.waves,
                            size: 40,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Pressure",
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            _showCleanDialog(context);
          },
          child: Container(
            padding: const EdgeInsets.only(left:16),
            child: const Center(
              child: Text(
                'Made by N0VA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
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

  const RowCard({
    super.key,
    required this.link,
    required this.time,
    required this.temp,
  });

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
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
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
              const SizedBox(height: 2),
              Text(
                temp,
                style: const TextStyle(fontSize: 14),
              )
            ],
          ),
        ),
      ),
    );
  }
}
