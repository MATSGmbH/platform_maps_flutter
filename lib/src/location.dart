part of platform_maps_flutter;

/// A pair of latitude and longitude coordinates, stored as degrees.
class LatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  /// The latitude is clamped to the inclusive interval from -90.0 to +90.0.
  ///
  /// The longitude is normalized to the half-open interval from -180.0
  /// (inclusive) to +180.0 (exclusive)
  const LatLng(double latitude, double longitude)
      : latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  @override
  String toString() => '$runtimeType($latitude, $longitude)';

  static LatLng _fromAppleLatLng(appleMaps.LatLng latLng) =>
      LatLng(latLng.latitude, latLng.longitude);

  static LatLng _fromGoogleLatLng(googleMaps.LatLng latLng) =>
      LatLng(latLng.latitude, latLng.longitude);

  appleMaps.LatLng get appleLatLng => appleMaps.LatLng(
        this.latitude,
        this.longitude,
      );

  googleMaps.LatLng get googleLatLng => googleMaps.LatLng(
        this.latitude,
        this.longitude,
      );

  static List<googleMaps.LatLng> googleMapsLatLngsFromList(
      List<LatLng> latlngs) {
    List<googleMaps.LatLng> googleMapsLatLngs = [];
    latlngs.forEach((LatLng latlng) {
      googleMapsLatLngs.add(latlng.googleLatLng);
    });
    return googleMapsLatLngs;
  }

  static List<appleMaps.LatLng> appleMapsLatLngsFromList(List<LatLng> latlngs) {
    List<appleMaps.LatLng> appleMapsLatLngs = [];
    latlngs.forEach((LatLng latlng) {
      appleMapsLatLngs.add(latlng.appleLatLng);
    });
    return appleMapsLatLngs;
  }

  @override
  bool operator ==(Object other) {
    return other is LatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }
}

class LatLngBounds {
  /// Creates geographical bounding box with the specified corners.
  ///
  /// The latitude of the southwest corner cannot be larger than the
  /// latitude of the northeast corner.
  LatLngBounds({required this.southwest, required this.northeast})
      : assert(southwest.latitude <= northeast.latitude);

  static LatLngBounds _fromAppleLatLngBounds(appleMaps.LatLngBounds bounds) =>
      LatLngBounds(
        southwest: LatLng._fromAppleLatLng(bounds.southwest),
        northeast: LatLng._fromAppleLatLng(bounds.northeast),
      );

  static LatLngBounds _fromGoogleLatLngBounds(googleMaps.LatLngBounds bounds) =>
      LatLngBounds(
        southwest: LatLng._fromGoogleLatLng(bounds.southwest),
        northeast: LatLng._fromGoogleLatLng(bounds.northeast),
      );

  /// The southwest corner of the rectangle.
  final LatLng southwest;

  /// The northeast corner of the rectangle.
  final LatLng northeast;

  appleMaps.LatLngBounds get appleLatLngBounds => appleMaps.LatLngBounds(
        southwest: this.southwest.appleLatLng,
        northeast: this.northeast.appleLatLng,
      );

  googleMaps.LatLngBounds get googleLatLngBounds => googleMaps.LatLngBounds(
        southwest: this.southwest.googleLatLng,
        northeast: this.northeast.googleLatLng,
      );

  bool contains(LatLng point) {
    return _containsLatitude(point.latitude) &&
        _containsLongitude(point.longitude);
  }

  bool _containsLatitude(double lat) {
    return (southwest.latitude <= lat) && (lat <= northeast.latitude);
  }

  bool _containsLongitude(double lng) {
    if (southwest.longitude <= northeast.longitude) {
      return southwest.longitude <= lng && lng <= northeast.longitude;
    } else {
      return southwest.longitude <= lng || lng <= northeast.longitude;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is LatLngBounds &&
        other.northeast == northeast &&
        other.southwest == southwest;
  }

  LatLngBounds pad(double bufferRatio) {
    final heightBuffer =
        (southwest.latitude - northeast.latitude).abs() * bufferRatio;
    final widthBuffer =
        (southwest.longitude - northeast.longitude).abs() * bufferRatio;

    return LatLngBounds(
        southwest: LatLng(southwest.latitude - heightBuffer,
            southwest.longitude - widthBuffer),
        northeast: LatLng(northeast.latitude + heightBuffer,
            northeast.longitude + widthBuffer));
  }

  factory LatLngBounds.fromPoints(List<LatLng> points) {
    if (points.isNotEmpty) {
      num? minX;
      num? maxX;
      num? minY;
      num? maxY;

      for (final point in points) {
        final num x = degToRadian(point.longitude);
        final num y = degToRadian(point.latitude);

        if (minX == null || minX > x) {
          minX = x;
        }

        if (minY == null || minY > y) {
          minY = y;
        }

        if (maxX == null || maxX < x) {
          maxX = x;
        }

        if (maxY == null || maxY < y) {
          maxY = y;
        }
      }

      final _sw =
          LatLng(radianToDeg(minY as double), radianToDeg(minX as double));
      final _ne =
          LatLng(radianToDeg(maxY as double), radianToDeg(maxX as double));
      return LatLngBounds(southwest: _sw, northeast: _ne);
    } else {
      throw Exception();
    }
  }
}

double degToRadian(final double deg) => deg * (pi / 180.0);

double radianToDeg(final double rad) => rad * (180.0 / pi);
