import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

// Model for device information
class TrackedDevice {
  final String id;
  final String name;
  final bool isOnline;
  final LatLng position;
  final String locationAccuracy; // GPS, Wi-Fi, Cellular
  final DateTime lastOnline;
  final bool doNotDisturb;
  final String? profileImageUrl;

  TrackedDevice({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.position,
    required this.locationAccuracy,
    required this.lastOnline,
    this.doNotDisturb = false,
    this.profileImageUrl,
  });
}

class Mainlocation extends StatefulWidget {
  const Mainlocation({super.key});

  @override
  State<Mainlocation> createState() => _MainlocationState();
}

class _MainlocationState extends State<Mainlocation> {
  // Google Maps controller
  final Completer<GoogleMapController> _controller = Completer();

  // Default camera position
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  // Refresh timer
  Timer? _refreshTimer;

  // Map markers
  Set<Marker> _markers = {};

  // Currently selected device
  String? _selectedDeviceId;

  // Mock devices data (in a real app, this would come from an API)
  final List<TrackedDevice> _devices = [
    TrackedDevice(
      id: "device1",
      name: "Emma's GierTag",
      isOnline: true,
      position: LatLng(37.42196133580664, -122.081749655962),
      locationAccuracy: "GPS",
      lastOnline: DateTime.now().subtract(Duration(minutes: 5)),
      profileImageUrl: "https://randomuser.me/api/portraits/women/32.jpg",
    ),
    TrackedDevice(
        id: "device2",
        name: "School Bag Tracker",
        isOnline: false,
        position: LatLng(37.43296133580664, -122.089749655962),
        locationAccuracy: "Cellular",
        lastOnline: DateTime.now().subtract(Duration(hours: 2)),
        doNotDisturb: true,
        profileImageUrl: "https://randomuser.me/api/portraits/men/27.jpg"),
  ];

  // Loading state
  bool _isLoading = false;

  // Add these properties
  LatLng? _myLocation;
  Marker? _myLocationMarker;
  BitmapDescriptor? _myLocationIcon;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
    _startAutoRefresh();
    _loadMyLocationMarkerIcon();

    // Start location tracking (for demo, we'll just use the default position)
    _myLocation = _defaultPosition.target;
    _updateMyLocationMarker();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Start auto-refresh timer
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _refreshDeviceLocations();
    });
  }

  // Refresh device locations
  Future<void> _refreshDeviceLocations() async {
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    // In a real app, you would fetch updated location data here
    // For this example, we'll simulate a network delay
    await Future.delayed(Duration(seconds: 1));

    // Simulate device movement for demo purposes
    setState(() {
      // Move the devices slightly to simulate movement
      for (int i = 0; i < _devices.length; i++) {
        final device = _devices[i];
        final newPosition = LatLng(
          device.position.latitude +
              (i == 0 ? 0.0001 : -0.0001) * (DateTime.now().second % 3),
          device.position.longitude +
              (i == 0 ? 0.0002 : -0.0002) * (DateTime.now().second % 2),
        );

        _devices[i] = TrackedDevice(
          id: device.id,
          name: device.name,
          isOnline: device.isOnline,
          position: newPosition,
          locationAccuracy: device.locationAccuracy,
          lastOnline: device.isOnline ? DateTime.now() : device.lastOnline,
          doNotDisturb: device.doNotDisturb,
          profileImageUrl: device.profileImageUrl,
        );
      }

      _updateMarkers();
      _isLoading = false;
    });

    // If a device is selected, center the map on it
    if (_selectedDeviceId != null) {
      final selectedDevice = _findDeviceById(_selectedDeviceId!);
      if (selectedDevice != null) {
        _centerMapOnLocation(selectedDevice.position);
      }
    }
  }

  // Load custom marker icon from assets
  Future<void> _loadMyLocationMarkerIcon() async {
    try {
      final ByteData data = await rootBundle.load('assets/icons/appIcon.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes,
          targetWidth: 100, targetHeight: 100);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image image = fi.image;

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final size = 120.0;

      // Draw circular shadow (for consistency with other markers)
      final shadowPaint = Paint()
        ..color = Colors.black.withAlpha(0x40)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawCircle(
        Offset(size / 2, size / 2),
        size / 3.2,
        shadowPaint,
      );

      // Draw circular background
      final paint = Paint()
        ..color = Color(0xFF1e1e1e) // Keep your dark color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size / 2, size / 2 - 4),
        size / 3.5,
        paint,
      );

      // Draw app icon image
      final src =
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final dst =
          Rect.fromLTWH(size * 0.23, size * 0.23 - 4, size * 0.54, size * 0.54);

      // Create circular clip for image (optional based on your app icon)
      final clipPath = Path()
        ..addOval(Rect.fromLTWH(
            size * 0.23, size * 0.23 - 4, size * 0.54, size * 0.54));

      canvas.clipPath(clipPath);
      canvas.drawImageRect(image, src, dst, Paint());

      // Convert to marker icon
      final picture = pictureRecorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      setState(() {
        _myLocationIcon =
            BitmapDescriptor.fromBytes(pngBytes!.buffer.asUint8List());
        _updateMyLocationMarker();
      });
    } catch (e) {
      // Fallback to default marker if loading fails
      _myLocationIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      _updateMyLocationMarker();
    }
  }

  // Update the user location marker
  void _updateMyLocationMarker() {
    if (_myLocation == null) return;

    final markerIcon = _myLocationIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

    final marker = Marker(
      markerId: MarkerId('my_location'),
      position: _myLocation!,
      icon: markerIcon,
      zIndex: 2, // To ensure it displays above other markers
      infoWindow: InfoWindow(title: 'My Location'),
    );

    setState(() {
      _myLocationMarker = marker;
      _updateMarkers(); // This will include the new marker
    });
  }

  // Update map markers (modified to include user location)
  void _updateMarkers() async {
    final Set<Marker> markers = {};

    // Add user location marker if available
    if (_myLocationMarker != null) {
      markers.add(_myLocationMarker!);
    }

    for (final device in _devices) {
      BitmapDescriptor markerIcon;

      // Create custom marker with profile image if available
      if (device.profileImageUrl != null) {
        try {
          // Load network image and convert to custom marker
          final Uint8List markerImageBytes =
              await _createCustomMarkerFromNetwork(
            device.profileImageUrl!,
            device.isOnline,
          );
          markerIcon = BitmapDescriptor.fromBytes(markerImageBytes);
        } catch (e) {
          // Fallback to default marker if image loading fails
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(device.isOnline
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed);
        }
      } else {
        // Use default marker for devices without profile image
        markerIcon = BitmapDescriptor.defaultMarkerWithHue(device.isOnline
            ? BitmapDescriptor.hueGreen
            : BitmapDescriptor.hueRed);
      }

      markers.add(
        Marker(
          markerId: MarkerId(device.id),
          position: device.position,
          icon: markerIcon,
          infoWindow: InfoWindow(title: device.name),
          onTap: () => _onDeviceSelected(device.id),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  // Create custom marker from network image
  Future<Uint8List> _createCustomMarkerFromNetwork(
      String imageUrl, bool isOnline) async {
    // Get network image
    final NetworkImage image = NetworkImage(imageUrl);
    final ImageStream stream = image.resolve(ImageConfiguration());
    final Completer<ui.Image> imageCompleter = Completer<ui.Image>();

    final listener = ImageStreamListener((ImageInfo info, bool _) {
      imageCompleter.complete(info.image);
    }, onError: (dynamic error, StackTrace? stackTrace) {
      imageCompleter.completeError(error);
    });

    stream.addListener(listener);
    final ui.Image uiImage = await imageCompleter.future;
    stream.removeListener(listener);

    // Create custom marker
    final size = 120.0; // Marker size
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Draw circular shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 3.2,
      shadowPaint,
    );

    // Draw white circle background
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size / 2, size / 2 - 4),
      size / 3.5,
      paint,
    );

    // Draw profile image in circle
    final src = Rect.fromLTWH(
        0, 0, uiImage.width.toDouble(), uiImage.height.toDouble());
    final dst =
        Rect.fromLTWH(size * 0.23, size * 0.23 - 4, size * 0.54, size * 0.54);

    // Create circular clip for image
    final clipPath = Path()
      ..addOval(Rect.fromLTWH(
          size * 0.23, size * 0.23 - 4, size * 0.54, size * 0.54));

    canvas.clipPath(clipPath);
    canvas.drawImageRect(uiImage, src, dst, Paint());

    // Reset clip
    canvas.restore();
    canvas.save();

    // Draw status indicator circle
    final statusPaint = Paint()
      ..color = isOnline ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size * 0.7, size * 0.3),
      size / 12,
      statusPaint,
    );

    // Convert to marker icon
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  // Find device by ID
  TrackedDevice? _findDeviceById(String id) {
    try {
      return _devices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  // Handle device selection
  void _onDeviceSelected(String deviceId) {
    final device = _findDeviceById(deviceId);
    if (device == null) return;

    setState(() {
      _selectedDeviceId = deviceId;
    });

    _centerMapOnLocation(device.position);
    _showDeviceDetails(device);
  }

  // Center map on location
  Future<void> _centerMapOnLocation(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  // Show device details
  void _showDeviceDetails(TrackedDevice device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Calculate the height constraint
        final screenHeight = MediaQuery.of(context).size.height;
        final maxHeight = screenHeight * 0.7;

        return Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: _buildDeviceDetailsPanel(device, context),
          ),
        );
      },
    );
  }

  // Build device details panel
  Widget _buildDeviceDetailsPanel(TrackedDevice device, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Keep this to minimize vertical size
        children: [
          Row(
            children: [
              if (device.profileImageUrl != null)
                CircleAvatar(
                  radius: screenWidth * 0.1,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  backgroundImage: NetworkImage(device.profileImageUrl!),
                )
              else
                CircleAvatar(
                  radius: screenWidth * 0.1,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: screenWidth * 0.1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              SizedBox(width: screenWidth * 0.05),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.025,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: screenHeight * 0.02,
                          color: device.isOnline
                              ? Colors.green
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4),
                        Text(
                          device.isOnline ? "Online" : "Offline",
                          style: TextStyle(
                            color: device.isOnline
                                ? Colors.green
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: screenHeight * 0.03),
          // Status information
          _buildStatusRow(
            Icons.location_on,
            "Location Accuracy",
            device.locationAccuracy,
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildStatusRow(
            Icons.access_time,
            "Last Online",
            _formatLastOnline(device.lastOnline),
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildStatusRow(
            Icons.do_not_disturb_on,
            "Do Not Disturb",
            device.doNotDisturb ? "On" : "Off",
            valueColor: device.doNotDisturb ? Colors.red : Colors.grey,
          ),
          SizedBox(height: screenHeight * 0.02),
          // View history button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.history),
              label: Text("View Location History"),
              onPressed: () {
                Navigator.pop(context);
                // Navigate to location history page
                Navigator.pushNamed(context, '/locationHistory');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build status row
  Widget _buildStatusRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(icon,
            size: screenHeight * 0.025,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: screenWidth * 0.02),
        Text("$label:",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Format last online time
  String _formatLastOnline(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight * 0.8,
      child: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _defaultPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled:
                false, // Keep this false as we'll add our own buttons
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // Device count indicator
          Positioned(
            top: screenHeight * 0.02,
            left: screenWidth * 0.05,
            child: GestureDetector(
              onTap: _fitAllDevicesOnMap, // Add this to make it clickable
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: screenWidth * 0.02,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.gps_fixed,
                        size: screenHeight * 0.02,
                        color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "Devices: ${_devices.length}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            bottom: screenHeight * 0.02,
            left: screenWidth * 0.05,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: screenWidth * 0.02,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.my_location,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _goToMyLocation,
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Positioned(
              top: screenHeight * 0.02,
              right: screenWidth * 0.05,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                      blurRadius: screenWidth * 0.02,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: screenWidth * 0.04,
                  height: screenWidth * 0.04,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Fit all devices on map
  Future<void> _fitAllDevicesOnMap() async {
    if (_devices.isEmpty) return;

    final GoogleMapController controller = await _controller.future;

    // Calculate bounds
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final device in _devices) {
      if (device.position.latitude < minLat) minLat = device.position.latitude;
      if (device.position.latitude > maxLat) maxLat = device.position.latitude;
      if (device.position.longitude < minLng)
        minLng = device.position.longitude;
      if (device.position.longitude > maxLng)
        maxLng = device.position.longitude;
    }

    // Add padding
    final padding = 0.01;
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  // Go to current location (updated to also update the marker)
  Future<void> _goToMyLocation() async {
    final GoogleMapController controller = await _controller.future;

    // In a real app, you'd get actual location; for demo we use default
    setState(() {
      _myLocation = _defaultPosition.target;
      _updateMyLocationMarker();
    });

    controller.animateCamera(CameraUpdate.newLatLngZoom(
      _myLocation!,
      16.0,
    ));
  }
}
