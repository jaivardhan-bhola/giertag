import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

// Model class for geofence data
class GeofenceArea {
  final String name;
  final double radius; // in meters
  final bool isActive;
  final LatLng position;
  final DateTime createdAt;

  GeofenceArea({
    required this.name,
    required this.radius,
    required this.position,
    this.isActive = true,
    required this.createdAt,
  });
}

class Geofence extends StatefulWidget {
  const Geofence({super.key});

  @override
  State<Geofence> createState() => _GeofenceState();
}

class _GeofenceState extends State<Geofence> {
  // Controller for Google Map
  final Completer<GoogleMapController> _controller = Completer();

  // Default camera position (can be replaced with device's current location)
  static final CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // Set to store map markers
  final Set<Marker> _markers = {};

  // Set to store geofence circles
  final Set<Circle> _circles = {};

  // Currently selected geofence for editing
  int? _selectedGeofenceIndex;

  // Sample geofence areas
  List<GeofenceArea> geofences = [
    GeofenceArea(
      name: "Home",
      radius: 100,
      position: LatLng(37.42796133580664, -122.085749655962),
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    ),
    GeofenceArea(
      name: "School",
      radius: 150,
      position: LatLng(37.43296133580664, -122.089749655962),
      createdAt: DateTime.now().subtract(Duration(days: 15)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Remove the call to _updateMapItems from initState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move the initialization here instead
    _updateMapItems();
  }

  void _updateMapItems() {
    setState(() {
      _markers.clear();
      _circles.clear();

      for (int i = 0; i < geofences.length; i++) {
        final geofence = geofences[i];

        // Add marker for the geofence
        _markers.add(
          Marker(
            markerId: MarkerId('geofence_$i'),
            position: geofence.position,
            infoWindow: InfoWindow(
              title: geofence.name,
              snippet: 'Radius: ${geofence.radius.toInt()}m',
            ),
            onTap: () {
              _selectedGeofenceIndex = i;
              _showGeofenceDetails(geofence);
            },
          ),
        );

        // Add circle for the geofence radius
        _circles.add(
          Circle(
            circleId: CircleId('circle_$i'),
            center: geofence.position,
            radius: geofence.radius,
            fillColor: Theme.of(context).colorScheme.primary.withValues(
              alpha: 50,
            ),
            strokeColor: geofence.isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            strokeWidth: 2,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text('Gier',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: screenHeight * 0.03)),
            Text('Tag',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.03)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setup Geofence',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Map view
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _defaultPosition,
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onLongPress: (LatLng position) {
                    _showAddGeofenceDialog(position);
                  },
                ),
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Instructions
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
            ),
            child: Text(
              "Long press on the map to add a new geofence",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),

          SizedBox(height: 16),

          // Geofence list
          Expanded(
            flex: 1,
            child: geofences.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: screenHeight * 0.1,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "No geofences configured",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: geofences.length,
                    itemBuilder: (context, index) {
                      final geofence = geofences[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(50),  
                            child: Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            geofence.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('Radius: ${geofence.radius.toInt()}m'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: geofence.isActive,
                                onChanged: (value) {
                                  setState(() {
                                    final updatedGeofence = GeofenceArea(
                                      name: geofence.name,
                                      radius: geofence.radius,
                                      position: geofence.position,
                                      isActive: value,
                                      createdAt: geofence.createdAt,
                                    );
                                    geofences[index] = updatedGeofence;
                                    _updateMapItems();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _confirmGeofenceRemoval(index),
                              ),
                            ],
                          ),
                          onTap: () {
                            _selectedGeofenceIndex = index;
                            _moveToGeofence(geofence);
                            _showGeofenceDetails(geofence);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        tooltip: 'My Location',
        child: Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    // In a real app, you would get the actual current location
    // For demo purposes, we'll just center on the default position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_defaultPosition));
  }

  Future<void> _moveToGeofence(GeofenceArea geofence) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
      geofence.position,
      16.0,
    ));
  }

  void _showAddGeofenceDialog(LatLng position) {
    final nameController = TextEditingController();
    double radius = 100.0;
    double screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Geofence'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g. Home, School, Park',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text('Radius (meters): ${radius.toInt()}'),
                    Slider(
                      value: radius,
                      min: 50,
                      max: 500,
                      divisions: 45,
                      label: radius.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          radius = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a name')),
                      );
                      return;
                    }

                    final newGeofence = GeofenceArea(
                      name: nameController.text.trim(),
                      radius: radius,
                      position: position,
                      createdAt: DateTime.now(),
                    );

                    setState(() {
                      geofences.add(newGeofence);
                      _updateMapItems();
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Geofence added'),
                      ),
                    );
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmGeofenceRemoval(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Geofence'),
        content:
            Text('Are you sure you want to remove "${geofences[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                geofences.removeAt(index);
                _updateMapItems();
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Geofence removed')),
              );
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showGeofenceDetails(GeofenceArea geofence) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withAlpha(50),
                    radius: screenWidth * 0.07,
                    child: Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                      size: screenWidth * 0.08,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      geofence.name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              _detailItem(Icons.circle_outlined, 'Radius',
                  '${geofence.radius.toInt()} meters'),
              SizedBox(height: screenHeight * 0.02),
              _detailItem(
                Icons.access_time,
                'Created on',
                '${geofence.createdAt.day}/${geofence.createdAt.month}/${geofence.createdAt.year}',
              ),
              SizedBox(height: screenHeight * 0.02),
              _detailItem(
                Icons.notifications,
                'Status',
                geofence.isActive ? 'Active (alerts enabled)' : 'Inactive',
                valueColor: geofence.isActive ? Colors.green : Colors.grey,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Edit'),
                    onPressed: () {
                      Navigator.pop(context);
                      if (_selectedGeofenceIndex != null) {
                        _editGeofence(_selectedGeofenceIndex!);
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                    ),
                    label: Text('Remove'),
                    onPressed: () {
                      Navigator.pop(context);
                      if (_selectedGeofenceIndex != null) {
                        _confirmGeofenceRemoval(_selectedGeofenceIndex!);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _editGeofence(int index) {
    final geofence = geofences[index];
    final nameController = TextEditingController(text: geofence.name);
    double radius = geofence.radius;
    bool isActive = geofence.isActive;
    double screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Geofence'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text('Radius (meters): ${radius.toInt()}'),
                    Slider(
                      value: radius,
                      min: 50,
                      max: 500,
                      divisions: 45,
                      label: radius.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          radius = value;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        Text('Active'),
                        Spacer(),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a name')),
                      );
                      return;
                    }

                    setState(() {
                      final updatedGeofence = GeofenceArea(
                        name: nameController.text.trim(),
                        radius: radius,
                        position: geofence.position,
                        isActive: isActive,
                        createdAt: geofence.createdAt,
                      );

                      geofences[index] = updatedGeofence;
                      _updateMapItems();
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Geofence updated'),
                      ),
                    );
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _detailItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: screenWidth * 0.06,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
