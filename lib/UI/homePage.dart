import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_weather_application/Api/consts.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import '../Api/connectivity.dart';
import 'package:connectivity/connectivity.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf=WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  final cityName=TextEditingController();
  String ctyName='Lahore';
  bool isConnected= false;
  StreamSubscription<ConnectivityResult>? subscription;


  @override
  void initState() {
    _wf.currentWeatherByCityName(ctyName).then((w){
      setState(() {
        _weather=w;

      });
    });
    super.initState();
    checkConnectivity();
    subscription= ConnectivityHelper.connectivityStream().listen((result){
      setState(() {
        isConnected=result!=ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose(){
    subscription?.cancel();
    super.dispose();
  }

  Future<bool> checkConnectivity() async{
    bool connection= await ConnectivityHelper.isConnected();
    setState(() {
      isConnected=connection;
    });
    return isConnected;
  }

  void fetchWeatherData(){
    _wf.currentWeatherByCityName(ctyName).then((w){
      setState(() {
        _weather=w;
      });
    });
  }

  Widget buildUI(){
    if(_weather==null){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    else{
      return Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.pink, Colors.purpleAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.02,
            ),
            addCity(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.06,
            ),
            locationHeader(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.06,
            ),
            dateTimeInfo(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.02,
            ),
            weatherIcon(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.02,
            ),
            _currTemp(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.02,
            ),
            extraInfo(),
          ],
        ),
      );
    }
  }

  Widget extraInfo(){
    return Container(
      width:MediaQuery.sizeOf(context).width*0.75,
      height: MediaQuery.sizeOf(context).height*0.15,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),),
              Text("Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
              style:const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),)
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Wind: ${_weather?.windSpeed?.toStringAsFixed(0)} mps",
              style:const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),),
              Text("Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),)
            ],
          )
        ],
      ),
    );
  }

  Widget weatherIcon(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height*0.15,
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage('https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png'))
          ),
        ),
        Text(_weather?.weatherDescription.toString()??"",
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),),

      ],
    );
  }

  Widget dateTimeInfo(){
    DateTime now= _weather?.date as DateTime;
    return Column(
      children: [
        Text(DateFormat('h:mm a').format(now).toString(),
        style:const TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold
        ),
        ),
        const SizedBox(height: 10,),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(DateFormat('EEEE').format(now).toString()),
            const SizedBox(width: 10,),
            Text(DateFormat('d.m.y').format(now).toString()),
            const SizedBox(height: 10,),
          ],
        )
      ],
    );
  }
  Widget locationHeader(){
    return Text(
      _weather?.areaName as String ??"",
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  Widget _currTemp(){
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)} ° C",
      style:const TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget addCity(){
    return Container(
      width: MediaQuery.sizeOf(context).width*0.75,
      height: MediaQuery.sizeOf(context).height*0.125,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color.fromARGB(22, 22, 22, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration:const  InputDecoration(labelText: "City Name", icon: Icon(Icons.search)),
        controller: cityName,
        keyboardType: TextInputType.text,
        onSubmitted: (value){
          setState(() {
            ctyName=value;
          });
          fetchWeatherData();
        },
      ),
    );
  }
  Widget notConnected(){
    return Container(
      height: MediaQuery.sizeOf(context).height*1,
      width: MediaQuery.sizeOf(context).width*1,
      decoration:const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.pink, Colors.purpleAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter)
      ),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height*0.45,),
          Icon(Icons.wifi_off_rounded, size: 45, color: Colors.black,),
          SizedBox(height: MediaQuery.sizeOf(context).height*0.04,),
          Text("Check your internet connection.", style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),)
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: isConnected? ListView(children: [buildUI()]): notConnected(),
      ),


    );
  }
}
