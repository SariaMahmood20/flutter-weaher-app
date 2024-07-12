import 'package:connectivity/connectivity.dart';

class ConnectivityHelper{
  static Future<ConnectivityResult> getConnectivityStatus() async {
    var connectivutyResult = await Connectivity().checkConnectivity();
    return connectivutyResult;
  }
  static Stream<ConnectivityResult> connectivityStream(){
    return Connectivity().onConnectivityChanged;
  }

  static Future<bool> isConnected()async{
    var connectivityResult= await getConnectivityStatus();
    return connectivityResult!=ConnectivityResult.none;
  }
  static Future<bool> isWifi() async{
    var connectivityResult= await getConnectivityStatus();
    return connectivityResult==ConnectivityResult.wifi;
  }
  static Future<bool> isMobile() async{
    var connectivityResult=await getConnectivityStatus();
    return connectivityResult==ConnectivityResult.mobile;
  }
}