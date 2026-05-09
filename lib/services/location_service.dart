import 'package:latlong2/latlong.dart';

abstract class LocationService {
  Future<LatLng?> getCurrentLocation();

  Future<String?> getPlacemarkFromLocation(LatLng location);
}
