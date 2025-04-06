import 'package:flutter/material.dart';

// Model class for devices
class Device {
  final String id;
  final String name;
  final String deviceType;
  final bool isOnline;
  final DateTime addedOn;

  Device({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.isOnline,
    required this.addedOn,
  });
}

class Adddevice extends StatefulWidget {
  const Adddevice({super.key});

  @override
  State<Adddevice> createState() => _AdddeviceState();
}

class _AdddeviceState extends State<Adddevice> {
  // Sample devices
  List<Device> devices = [
    Device(
      id: "GT-1234567",
      name: "Emma's GierTag",
      deviceType: "GierTag Mini",
      isOnline: true,
      addedOn: DateTime.now().subtract(Duration(days: 45)),
    ),
    Device(
      id: "GT-7654321",
      name: "School Bag Tracker",
      deviceType: "GierTag Pro",
      isOnline: false,
      addedOn: DateTime.now().subtract(Duration(days: 12)),
    ),
  ];

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
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Devices',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Devices list
          Expanded(
            child: devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.devices_other,
                          size: 56,
                          color: Colors.grey,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "No devices added",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton.icon(
                          icon: Icon(Icons.qr_code_scanner),
                          label: Text("Add Your First Device"),
                          onPressed: _scanQRCode,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: device.isOnline
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            child: Icon(
                              Icons.gps_fixed,
                              color:
                                  device.isOnline ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Text(
                            device.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * 0.018,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                device.deviceType,
                                style: TextStyle(
                                  fontSize: screenHeight * 0.016,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Row(
                                children: [
                                  Icon(
                                    device.isOnline
                                        ? Icons.circle
                                        : Icons.circle_outlined,
                                    size: 12,
                                    color: device.isOnline
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    device.isOnline ? "Online" : "Offline",
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.014,
                                      color: device.isOnline
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () => _confirmDeviceRemoval(index),
                          ),
                          onTap: () => _viewDeviceDetails(device),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: devices.isNotEmpty
          ? FloatingActionButton(
              onPressed: _scanQRCode,
              child: Icon(Icons.qr_code_scanner),
              tooltip: 'Scan QR Code to add device',
            )
          : null,
    );
  }

  void _scanQRCode() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code Scanner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner,
                size: screenWidth * 0.2,
                color: Theme.of(context).colorScheme.primary),
            SizedBox(height: screenHeight * 0.02),
            Text('Scan the QR code on your GierTag device to add it.'),
            SizedBox(height: screenHeight * 0.02),
            Text('Simulating successful scan...',
                style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addNewDevice();
            },
            child: Text('Simulate Success'),
          ),
        ],
      ),
    );
  }

  void _addNewDevice() {
    setState(() {
      devices.add(
        Device(
          id: "GT-" +
              DateTime.now().millisecondsSinceEpoch.toString().substring(7),
          name: "New GierTag",
          deviceType: "GierTag Standard",
          isOnline: true,
          addedOn: DateTime.now(),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Device added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDeviceRemoval(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Device'),
        content:
            Text('Are you sure you want to remove "${devices[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                devices.removeAt(index);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Device removed'),
                ),
              );
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _viewDeviceDetails(Device device) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(screenHeight * 0.02)),
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
                    radius: screenWidth * 0.05,
                    backgroundColor: device.isOnline
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    child: Icon(
                      Icons.gps_fixed,
                      color: device.isOnline ? Colors.green : Colors.grey,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          device.deviceType,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              _detailRow(
                  Icons.confirmation_number_outlined, 'Device ID', device.id),
              SizedBox(height: screenHeight * 0.01),
              _detailRow(
                  Icons.access_time, 'Added on', _formatDate(device.addedOn)),
              SizedBox(height: screenHeight * 0.01),
              _detailRow(
                Icons.circle,
                'Status',
                device.isOnline ? 'Online' : 'Offline',
                color: device.isOnline ? Colors.green : Colors.grey,
              ),
              SizedBox(height: screenHeight * 0.02),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('Edit Device'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/deviceSettings');

                    
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Row(
      children: [
        Icon(
          icon,
          size: screenHeight * 0.025,
          color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: screenWidth * 0.02),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: screenHeight * 0.018,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenHeight * 0.018,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
