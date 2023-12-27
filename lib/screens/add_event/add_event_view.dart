import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourpis/repository/event_repository.dart';

import '../../../utils/color_utils.dart';
import '../../../widgets/widget.dart';
import '../map/map_screen.dart';
import 'add_event_screen.dart';

class AddEventView extends State<AddEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateStartTextController;
  late TextEditingController _timeStartTextController;
  late TextEditingController _dateEndTextController;
  late TextEditingController _timeEndTextController;
  late TextEditingController _maxParticipantsController;
  late DateTime _selectedStartDate = DateTime.now();
  late TimeOfDay _selectedStartTime = TimeOfDay.now();
  late DateTime _selectedEndDate = DateTime.now();
  late TimeOfDay _selectedEndTime = TimeOfDay.now();
  final eventRepository = EventRepository();

  List<LatLng> _points = [];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateStartTextController = TextEditingController();
    _timeStartTextController = TextEditingController();
    _dateEndTextController = TextEditingController();
    _timeEndTextController = TextEditingController();
    _maxParticipantsController = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController date,
      DateTime selectedDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        date.text = "${pickedDate.day}.${pickedDate.month}.${pickedDate.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController time,
      TimeOfDay selectedTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        time.text = "${pickedTime.hour}:${pickedTime.minute}";
      });
    }
  }

  Widget _buildDisabledTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      enabled: false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        contentPadding: const EdgeInsets.all(16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dodaj wydarzenie"),
        backgroundColor: hexStringToColor("2F73B1"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("2F73B1"),
              hexStringToColor("2F73B1"),
              hexStringToColor("1A4290"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery
                  .of(context)
                  .size
                  .width * 0.05,
              vertical: MediaQuery
                  .of(context)
                  .size
                  .height * 0.02,
            ),
            child: Column(
              children: [
                smallLogoWidget("assets/images/logo_text.png"),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tytuł',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Opis',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _maxParticipantsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Limit uczestników',
                    labelStyle: const TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value != null) {
                      try {
                        int number = int.parse(value);
                        if (number <= 0) {
                          return 'Wprowadź liczbę większą od zera';
                        }
                      } catch (e) {
                        return 'Wprowadź poprawną liczbę';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                const Text("Początek wydarzenia:",
                    style: TextStyle(color: Colors.white)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _selectDate(context, _dateStartTextController,
                              _selectedStartDate),
                      child: const Text(
                          'Wybierz datę', style: TextStyle(color: Colors.blue)),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _selectTime(context, _timeStartTextController,
                              _selectedStartTime),
                      child: const Text('Wybierz godzinę',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildDisabledTextField(
                        controller: _dateStartTextController,
                        labelText: 'Data',
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildDisabledTextField(
                        controller: _timeStartTextController,
                        labelText: 'Godzina',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text("Koniec wydarzenia:",
                    style: TextStyle(color: Colors.white)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _selectDate(context, _dateEndTextController,
                              _selectedEndDate),
                      child: const Text(
                          'Wybierz datę', style: TextStyle(color: Colors.blue)),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _selectTime(context, _timeEndTextController,
                              _selectedEndTime),
                      child: const Text('Wybierz godzinę',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildDisabledTextField(
                        controller: _dateEndTextController,
                        labelText: 'Data',
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildDisabledTextField(
                        controller: _timeEndTextController,
                        labelText: 'Godzina',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MapScreen(addEventView: this),
                          ),
                        );
                      },
                      child: const Text('Wybierz trasę',
                          style: TextStyle(color: Colors.blue)),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () => showFriends(),
                      child: const Text('Zaproś znajomych',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_titleController.text.isEmpty ||
              _dateStartTextController.text.isEmpty ||
              _timeStartTextController.text.isEmpty ||
              _dateEndTextController.text.isEmpty ||
              _timeEndTextController.text.isEmpty ||
              _maxParticipantsController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nie wypełniono wszystkich wymaganych pól.'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            DateTime selectedStartDateTime = DateTime(
              _selectedStartDate.year,
              _selectedStartDate.month,
              _selectedStartDate.day,
              _selectedStartTime.hour,
              _selectedStartTime.minute,
            );

            DateTime selectedEndDateTime = DateTime(
              _selectedEndDate.year,
              _selectedEndDate.month,
              _selectedEndDate.day,
              _selectedEndTime.hour,
              _selectedEndTime.minute,
            );

            List<GeoPoint> geoPoints = _points.map((latLng) {
              return GeoPoint(latLng.latitude, latLng.longitude);
            }).toList();

            eventRepository.createEvent(
                _titleController.text, _descriptionController.text,
                selectedStartDateTime, selectedEndDateTime,
                int.parse(_maxParticipantsController.text), geoPoints);

            Navigator.pop(context);
          }
        },
        tooltip: 'Dodaj',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.check),
      ),
    );
  }

  void setPoints(List<LatLng> points) {
    setState(() {
      _points = points;
    });

    createSnackBar('Trasa została zapisana.', context);
  }

  showFriends() {
    //todo
  }
}