// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart' as core_patch hide double;
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
// import 'dart:typed_data';
import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart' as core_patch;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';

import 'package:http/http.dart' as http;


import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  // late double temp;//late is used to tell the compiler that we will initialize it later 
  //basically u have a contract that u need to assign it before using it in the build function
  //if not using in the build function late doesn't really care


  // double temp=0;
  // bool isLoading=false;

  // @override
  // void initState() {
  //   super.initState();
  //   getCurrentWeather();
  //   // print('init state');
  // }

  late Future<Map<String,dynamic>>weather;

  Future<Map<String,dynamic>>getCurrentWeather() async{//in api we are getting an object of string(lhs) and string/int/double(rhs)
    // print('fn called');
    try{
      // setState(() {
      //   isLoading=true;
      // });

    String cityName = 'Delhi';
    final res= await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName,india&APPID=$openWeatherAPIKey'),
      );//now this api call will take some time u have to retrive the data from the web that will take some time depend on internet connection
      //but while it is waiting,we have already executed the build fn beacuse that's how async stuff works,it won't wait for it to complete
      //it said hey complete it in the  fututre i'll just go ahead and do my stuff
      //so it called the build fn and it tried to access the temp variable but it is not initialized yet-that's the problem


      // print('api called');

      final data=jsonDecode(res.body);

      // if(int.parse(data['cod'])!=200){
      //   throw data['message'];
      // }
      //same as below

      if(data['cod']!='200'){
        throw 'An unexpected error occured hehe';
        // throw data['message'];
      }
      return data;
      // temp=data['list'][0]['main']['temp'];//u r reassigning the value afterthe build fn is called-to solve this we use setstate

      
    // setState(() {
      //temp=data['list'][0]['main']['temp'];
    //   isLoading=false;
    // });
    }catch(e){
      throw e.toString();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weather = getCurrentWeather();///initialsed the late variable here
  }

  @override
  Widget build(BuildContext context) {
    // print('build fn called');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              //set state is there for 1 single statful widget--cannot manage the widget in 2 to 3 different screens
              //it only rebuilds the current screen
              setState(() {//when i presss it rebuilds the entire scaffold again
                weather = getCurrentWeather();
              });//this is the local state mangement
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // body: isLoading //or temp==0
      // ?const CircularProgressIndicator()
      // : 
        body:FutureBuilder(//now future builder correctly identifies that it will take map of string,dynamic-rivaan r 8:18:00
          future:weather,//now this doesnt work since we are just calling the variable and not the function
          //when we are calling the variable it is not rebuilding again so we need to call the function again
          //that's why whenever the build fxn would rebuild it would call the function again and that's why set state worked earlier
          //that's why fxn reran and we got new values
          //initially we were just calling the variable so it was not rerunning the function
          //set state now doesnt call the fxn again it just calls the variable which has been already been assigned a value
          //so we have to call the fxn again in set state and reinitialise the variable
          //now no differnce bw weather and getCurrentWeather() written after future in a simple app
          //but in a bigger app it would make a differnce--in inherited widget--when we talk about state management
          //build fxn will get called even when set state is not called
          //even set state is kind of a state management 
          //in 2 or more unrealated screens things like inherited widget and riverpod comes into picture         
          builder: (context,snapshot) {
            print(snapshot);

            if(snapshot.connectionState==ConnectionState.waiting){
              return const Center(
                child:  CircularProgressIndicator()
                );
            }//handled loading state

            if(snapshot.hasError){
              return Center(child: Text(snapshot.error.toString()));
            }//handled error state

            if (!snapshot.hasData || snapshot.data == null) {
      // Data is null or not present
              return Text('No data available');
            }//handled no data state

            //snapshot data has nulllable option since it still think that maybe theres still an error or loading state but we have already handled the error
            final data=snapshot.data!;//so we use ! to tell the compiler that we have already handled the error and loading state


            
          final currentWeatherData = data['list'][0];

          final currentTemp = double.parse((currentWeatherData['main']['temp'] - 273.15).toStringAsFixed(2));
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          
            
            return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //main card
          
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation:10,
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child:   Padding(
                        padding:  const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '$currentTemp C',
                              style:const  TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const  SizedBox(
                              height: 16,
                            ),
                            Icon(
                              currentSky=='Clouds'||currentSky=='Rain'?Icons.cloud:Icons.sunny,
                              size: 64,
                            ),
                            const  SizedBox(
                              height: 16,
                            ),
                            Text(
                              currentSky,
                              style:const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          
              //weather forecast cards
          
              const SizedBox(
                height: 25,
              ),
          
              // Align(
              //   alignment:Alignment.centerLeft ,
              //   child: const Text('Weather Forecast',
              //     style: TextStyle(
              //       fontSize: 24,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),we used cross axis alignment instead of this
          
              const Text('Weather Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          
              const SizedBox(height:16),
          
              //  SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [

              //       for(int i=0;i<5;i++)
              //         HourlyForecastItem(
              //           time:data['list'][i+1]['dt'].toString(),
              //           icon: data['list'][i+1]['weather'][0]['main']=='Clouds'||data['list'][i+1]['weather'][0]['main']=='Rain'?Icons.cloud:Icons.sunny ,
              //           temperature:data['list'][i+1]['main']['temp'].toString(),
              //         ),
                                  
              //     ],
              //   ),
              // ),

              //for lazy loading we use listview.builder-better approach

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder:  (context,index) {
                    final hourlySky=data['list'][index+1]['weather'][0]['main'];
                    final hourlyForecast=data['list'][index+1];
                    final time=DateTime.parse(hourlyForecast['dt_txt']);//converted this string to datetime object
                    return HourlyForecastItem(
                      //00:00,3:00 ,6:00
                      time:DateFormat.j().format(time)  ,   //Hm is hour follwed by minute
                      //format requires a datetime object so we use date time.parse to convert string to datetime object which is why created it above
                      temperature:(hourlyForecast['main']['temp']-273.15).toStringAsFixed(2),
                      icon: hourlySky=='Clouds'||hourlySky=='Rain'
                      ?Icons.cloud
                      :Icons.sunny ,
                    );
                  },
                  ),
              ),
          
          
             
          
              const SizedBox(
                height: 25,
              ),
          
              //additional information
          
              const Text('Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                height: 10,
              ),
          
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),                  
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: currentSpeed.toString(),
                    ),                  
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),                  
                  
                  ],
                )
          
            ],
          ),
                ); 
          },
        ),
    );
  }
}




