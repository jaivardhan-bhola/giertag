import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';

// Model class for location history data
class LocationPoint {
  final LatLng position;
  final DateTime timestamp;
  final double? speed; // in km/h
  final double? batteryLevel; // percentage

  LocationPoint({
    required this.position,
    required this.timestamp,
    this.speed,
    this.batteryLevel,
  });
}

class Locationhistory extends StatefulWidget {
  const Locationhistory({super.key});

  @override
  State<Locationhistory> createState() => _LocationhistoryState();
}

class _LocationhistoryState extends State<Locationhistory> {
  // Controller for Google Map
  final Completer<GoogleMapController> _controller = Completer();

  // Default camera position
  static final CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  // Selected time period
  String _selectedPeriod = "Today";
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isCustomPeriod = false;

  // Map markers and polylines
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Sample location history data
  final List<LocationPoint> _locationHistory = [
    // Today's data
    LocationPoint(
      position: LatLng(37.42796133580664, -122.085749655962),
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      speed: 0,
      batteryLevel: 85,
    ),
    LocationPoint(
      position: LatLng(37.428561, -122.082652),
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      speed: 5.2,
      batteryLevel: 87,
    ),
    LocationPoint(
      position: LatLng(37.430268, -122.081243),
      timestamp: DateTime.now().subtract(Duration(hours: 3)),
      speed: 4.8,
      batteryLevel: 90,
    ),
    // Yesterday's data
    LocationPoint(
      position: LatLng(37.425642, -122.086258),
      timestamp: DateTime.now().subtract(Duration(days: 1, hours: 2)),
      speed: 1.2,
      batteryLevel: 75,
    ),
    LocationPoint(
      position: LatLng(37.422761, -122.084531),
      timestamp: DateTime.now().subtract(Duration(days: 1, hours: 4)),
      speed: 3.5,
      batteryLevel: 80,
    ),
    // Day before yesterday data
    LocationPoint(
      position: LatLng(37.420691, -122.089874),
      timestamp: DateTime.now().subtract(Duration(days: 2, hours: 3)),
      speed: 2.1,
      batteryLevel: 65,
    ),
  ];

  int _currentTimelineIndex = 0;
  Marker? _highlightedMarker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMapForSelectedPeriod();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header and title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.01,
              ),
              child: Text(
                'Location History',
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Time period selection
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      value: _selectedPeriod,
                      buttonStyleData: ButtonStyleData(
                        height: screenHeight * 0.05,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: screenHeight * 0.3,
                        width: screenWidth * 0.9 -
                            screenWidth * 0.05 * 2, // Match parent width
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        offset: const Offset(0, 0), // Shows directly below
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: MaterialStateProperty.all<double>(6),
                          thumbVisibility:
                              MaterialStateProperty.all<bool>(true),
                        ),
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        height: screenHeight * 0.05,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                      ),
                      iconStyleData: IconStyleData(
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: screenHeight * 0.03,
                        iconEnabledColor:
                            Theme.of(context).colorScheme.onSurface,
                      ),
                      items: <String>[
                        "Last Hour",
                        "Last 3 Hours",
                        "Today",
                        "Yesterday",
                        "Last 24 Hours",
                        "This Week",
                        "Custom"
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPeriod = newValue;
                            _isCustomPeriod = newValue == "Custom";
                            if (!_isCustomPeriod) {
                              _updateMapForSelectedPeriod();
                            }
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (_isCustomPeriod)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.calendar_today,
                                size: screenHeight * 0.02),
                            label: Text(
                              _customStartDate != null
                                  ? "${_customStartDate!.day.toString().padLeft(2, '0')}/${_customStartDate!.month.toString().padLeft(2, '0')}/${_customStartDate!.year}"
                                  : "Start Date",
                              style: TextStyle(fontSize: screenHeight * 0.011),
                            ),
                            onPressed: () => _selectDate(true),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.calendar_today,
                                size: screenHeight * 0.02),
                            label: Text(
                              _customEndDate != null
                                  ? "${_customEndDate!.day.toString().padLeft(2, '0')}/${_customEndDate!.month.toString().padLeft(2, '0')}/${_customEndDate!.year}"
                                  : "End Date",
                              style: TextStyle(fontSize: screenHeight * 0.011),
                            ),
                            onPressed: () => _selectDate(false),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        ElevatedButton(
                          child: Text("Apply"),
                          onPressed: () {
                            if (_customStartDate != null &&
                                _customEndDate != null) {
                              setState(() {
                                _updateMapForSelectedPeriod();
                                _currentTimelineIndex = 0;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Please select both dates")),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            SizedBox(
              height: screenHeight * 0.42,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: _filteredLocations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: screenHeight * 0.08,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "No location data available for the selected period",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: _defaultPosition,
                          markers: _markers,
                          polylines: _polylines,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                ),
              ),
            ),

            // Location details panel

            // Timeline scrubber
            if (_filteredLocations.isNotEmpty)
              Container(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.25),
                width: screenWidth,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _timelineInfoItem(
                            Icons.access_time,
                            "Time",
                            _formatDateTime(
                                _filteredLocations[_currentTimelineIndex]
                                    .timestamp)),
                        SizedBox(width: screenWidth * 0.05),
                        _timelineInfoItem(Icons.speed, "Speed",
                            "${_filteredLocations[_currentTimelineIndex].speed?.toStringAsFixed(1) ?? 'N/A'} km/h"),
                        SizedBox(width: screenWidth * 0.05),
                        _timelineInfoItem(
                            Icons.battery_charging_full,
                            "Battery",
                            "${_filteredLocations[_currentTimelineIndex].batteryLevel?.toStringAsFixed(0) ?? 'N/A'}%"),
                      ],
                    ),
                     SizedBox(height: screenHeight * 0.01),
                     LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(
                                _formatTimeOnly(
                                    _filteredLocations.last.timestamp),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                  trackHeight: 2,
                                ),
                                child: Slider(
                                  value: _currentTimelineIndex.toDouble(),
                                  min: 0,
                                  max: (_filteredLocations.length - 1)
                                      .toDouble(),
                                  divisions: _filteredLocations.length > 1
                                      ? _filteredLocations.length - 1
                                      : 1,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentTimelineIndex = value.toInt();
                                      _highlightLocationPoint(
                                          _currentTimelineIndex);
                                    });
                                  },
                                ),
                              ),
                            ),
                            Container(
                              width: 50,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _formatTimeOnly(
                                    _filteredLocations.first.timestamp),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(icon,
            size: screenHeight * 0.025,
            color: Theme.of(context).colorScheme.primary),
        SizedBox(width: screenWidth * 0.001),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: screenHeight * 0.016,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _timelineInfoItem(IconData icon, String label, String value) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Icon(icon,
            size: screenHeight * 0.025,
            color: Theme.of(context).colorScheme.primary),
        SizedBox(height: screenHeight * 0.005),
        Text(label,
            style: TextStyle(
                fontSize: screenHeight * 0.016,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<LocationPoint> get _filteredLocations {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    switch (_selectedPeriod) {
      case "Today":
        return _locationHistory
            .where((loc) => loc.timestamp.isAfter(today))
            .toList();

      case "Yesterday":
        return _locationHistory
            .where((loc) =>
                loc.timestamp.isAfter(yesterday) &&
                loc.timestamp.isBefore(today))
            .toList();

      case "Last 24 Hours":
        final last24Hours = now.subtract(Duration(hours: 24));
        return _locationHistory
            .where((loc) => loc.timestamp.isAfter(last24Hours))
            .toList();

      case "This Week":
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return _locationHistory
            .where((loc) => loc.timestamp.isAfter(startOfWeek))
            .toList();

      case "Last Hour":
        final lastHour = now.subtract(Duration(hours: 1));
        return _locationHistory
            .where((loc) => loc.timestamp.isAfter(lastHour))
            .toList();

      case "Last 3 Hours":
        final last3Hours = now.subtract(Duration(hours: 3));
        return _locationHistory
            .where((loc) => loc.timestamp.isAfter(last3Hours))
            .toList();

      case "Custom":
        if (_customStartDate != null && _customEndDate != null) {
          final endOfDay = DateTime(_customEndDate!.year, _customEndDate!.month,
              _customEndDate!.day, 23, 59, 59);

          return _locationHistory
              .where((loc) =>
                  loc.timestamp.isAfter(_customStartDate!) &&
                  loc.timestamp.isBefore(endOfDay))
              .toList();
        }
        return [];

      default:
        return _locationHistory;
    }
  }

  void _updateMapForSelectedPeriod() {
    final filteredData = _filteredLocations;

    if (filteredData.isEmpty) {
      setState(() {
        _markers = {};
        _polylines = {};
      });
      return;
    }

    filteredData.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _markers = {};
      _polylines = {};

      _markers.add(
        Marker(
          markerId: MarkerId('start'),
          position: filteredData.last.position,
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _formatDateTime(filteredData.last.timestamp),
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('end'),
          position: filteredData.first.position,
          infoWindow: InfoWindow(
            title: 'Current',
            snippet: _formatDateTime(filteredData.first.timestamp),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      List<LatLng> polylineCoordinates =
          filteredData.map((loc) => loc.position).toList();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('path'),
          points: polylineCoordinates,
          color: Theme.of(context).colorScheme.primary,
          width: 5,
        ),
      );
    });

    _fitMapToLocations(filteredData);
  }

  Future<void> _fitMapToLocations(List<LocationPoint> locations) async {
    if (locations.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var loc in locations) {
      if (loc.position.latitude < minLat) minLat = loc.position.latitude;
      if (loc.position.latitude > maxLat) maxLat = loc.position.latitude;
      if (loc.position.longitude < minLng) minLng = loc.position.longitude;
      if (loc.position.longitude > maxLng) maxLng = loc.position.longitude;
    }

    final padding = 0.01;
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_customStartDate ?? DateTime.now())
          : (_customEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _customStartDate = picked;
          if (_customEndDate != null &&
              _customEndDate!.isBefore(_customStartDate!)) {
            _customEndDate = _customStartDate;
          }
        } else {
          _customEndDate = picked;
          if (_customStartDate != null &&
              _customStartDate!.isAfter(_customEndDate!)) {
            _customStartDate = _customEndDate;
          }
        }
      });
    }
  }

  void _highlightLocationPoint(int index) async {
    final location = _filteredLocations[index];

    setState(() {
      if (_highlightedMarker != null) {
        _markers.remove(_highlightedMarker);
      }

      _highlightedMarker = Marker(
        markerId: MarkerId('highlighted'),
        position: location.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(
          title: 'Point ${index + 1}',
          snippet:
              '${_formatDateTime(location.timestamp)} - ${location.speed?.toStringAsFixed(1) ?? 'N/A'} km/h',
        ),
      );

      _markers.add(_highlightedMarker!);
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(location.position));
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String _formatTimeOnly(DateTime dt) {
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
