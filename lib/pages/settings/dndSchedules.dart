import 'package:flutter/material.dart';

// Model class for DND schedules
class DndSchedule {
  bool monEnabled;
  bool tueEnabled;
  bool wedEnabled;
  bool thuEnabled;
  bool friEnabled;
  bool satEnabled;
  bool sunEnabled;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isActive;

  DndSchedule({
    this.monEnabled = true,
    this.tueEnabled = true,
    this.wedEnabled = true,
    this.thuEnabled = true,
    this.friEnabled = true,
    this.satEnabled = false,
    this.sunEnabled = false,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  String getActiveDaysText() {
    List<String> days = [];
    if (monEnabled) days.add('Mon');
    if (tueEnabled) days.add('Tue');
    if (wedEnabled) days.add('Wed');
    if (thuEnabled) days.add('Thu');
    if (friEnabled) days.add('Fri');
    if (satEnabled) days.add('Sat');
    if (sunEnabled) days.add('Sun');
    return days.join(', ');
  }
}

class Dndschedules extends StatefulWidget {
  const Dndschedules({super.key});

  @override
  State<Dndschedules> createState() => _DndschedulesState();
}

class _DndschedulesState extends State<Dndschedules> {
  List<DndSchedule> schedules = [
    // Sample schedule for initial UI testing
    DndSchedule(
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 17, minute: 0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
          SizedBox(height: screenHeight * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Text(
              'Do Not Disturb Schedules',
              style: TextStyle(
                fontSize: screenHeight * 0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: schedules.isEmpty
                ? Center(child: Text('No DND schedules configured'))
                : ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.05),
                        child: ListTile(
                          title: Text(
                            '${schedule.startTime.format(context)} - ${schedule.endTime.format(context)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(schedule.getActiveDaysText()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: schedule.isActive,
                                onChanged: (value) {
                                  setState(() {
                                    schedule.isActive = value;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editSchedule(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteSchedule(index),
                              ),
                            ],
                          ),
                          onTap: () => _editSchedule(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSchedule,
        tooltip: 'Add Schedule',
        child: Icon(Icons.add),
      ),
    );
  }

  void _addNewSchedule() {
    _showScheduleForm(onSave: (schedule) {
      setState(() {
        schedules.add(schedule);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DND schedule added')),
      );
    });
  }

  void _editSchedule(int index) {
    final schedule = schedules[index];
    _showScheduleForm(
        schedule: schedule,
        onSave: (updatedSchedule) {
          setState(() {
            schedules[index] = updatedSchedule;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('DND schedule updated')),
          );
        });
  }

  void _deleteSchedule(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Schedule'),
        content: Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                schedules.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Schedule removed')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showScheduleForm(
      {DndSchedule? schedule, required Function(DndSchedule) onSave}) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Initialize with default values or existing schedule values
    bool monEnabled = schedule?.monEnabled ?? true;
    bool tueEnabled = schedule?.tueEnabled ?? true;
    bool wedEnabled = schedule?.wedEnabled ?? true;
    bool thuEnabled = schedule?.thuEnabled ?? true;
    bool friEnabled = schedule?.friEnabled ?? true;
    bool satEnabled = schedule?.satEnabled ?? false;
    bool sunEnabled = schedule?.sunEnabled ?? false;
    TimeOfDay startTime = schedule?.startTime ?? TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = schedule?.endTime ?? TimeOfDay(hour: 17, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: screenHeight * 0.8,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    schedule == null ? 'Add Schedule' : 'Edit Schedule',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),

                // Days of the week selection
                Text('Select days:', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDayToggle('M', monEnabled,
                        (val) => setState(() => monEnabled = val!)),
                    _buildDayToggle('T', tueEnabled,
                        (val) => setState(() => tueEnabled = val!)),
                    _buildDayToggle('W', wedEnabled,
                        (val) => setState(() => wedEnabled = val!)),
                    _buildDayToggle('T', thuEnabled,
                        (val) => setState(() => thuEnabled = val!)),
                    _buildDayToggle('F', friEnabled,
                        (val) => setState(() => friEnabled = val!)),
                    _buildDayToggle('S', satEnabled,
                        (val) => setState(() => satEnabled = val!)),
                    _buildDayToggle('S', sunEnabled,
                        (val) => setState(() => sunEnabled = val!)),
                  ],
                ),

                SizedBox(height: 30),

                // Time selection
                Text('Select time range:', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text('Start Time'),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setState(() => startTime = picked);
                            }
                          },
                          child: Text(startTime.format(context)),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward),
                    Column(
                      children: [
                        Text('End Time'),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setState(() => endTime = picked);
                            }
                          },
                          child: Text(endTime.format(context)),
                        ),
                      ],
                    ),
                  ],
                ),

                Spacer(),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        final newSchedule = DndSchedule(
                          monEnabled: monEnabled,
                          tueEnabled: tueEnabled,
                          wedEnabled: wedEnabled,
                          thuEnabled: thuEnabled,
                          friEnabled: friEnabled,
                          satEnabled: satEnabled,
                          sunEnabled: sunEnabled,
                          startTime: startTime,
                          endTime: endTime,
                          isActive: schedule?.isActive ?? true,
                        );
                        onSave(newSchedule);
                        Navigator.pop(context);
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayToggle(String label, bool value, Function(bool?) onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
