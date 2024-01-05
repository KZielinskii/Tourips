import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourpis/repository/event_participants_repository.dart';
import 'package:tourpis/repository/event_repository.dart';
import 'package:tourpis/repository/event_request_repository.dart';
import 'package:tourpis/repository/user_repository.dart';
import '../../../utils/color_utils.dart';
import '../../../widgets/widget.dart';
import '../../models/EventModel.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _dateStartTextController;
  late TextEditingController _timeStartTextController;
  late TextEditingController _dateEndTextController;
  late TextEditingController _timeEndTextController;
  late DateTime _selectedStartDate;
  late TimeOfDay _selectedStartTime;
  late DateTime _selectedEndDate;
  late TimeOfDay _selectedEndTime;
  final userRepository = UserRepository();
  final eventRepository = EventRepository();
  final eventRequestRepository = EventRequestRepository();
  final eventParticipantsRepository = EventParticipantsRepository();
  late EventModel event;

  List<LatLng> _points = [];

  @override
  void initState() {
    super.initState();
    _initializeState();
    _loadEventDetails();
  }

  Future<void> _initializeState() async {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _dateStartTextController = TextEditingController();
    _timeStartTextController = TextEditingController();
    _dateEndTextController = TextEditingController();
    _timeEndTextController = TextEditingController();
    _dateStartTextController = TextEditingController();
    _dateEndTextController = TextEditingController();
  }

  Future<void> _loadEventDetails() async {
    try {
      event = (await eventRepository.getEventById(widget.eventId))!;

      setState(() {
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _maxParticipantsController.text = event.capacity.toString();
        _dateStartTextController.text = _formatDate(event.startDate);
        _timeStartTextController.text = _formatTime(event.startDate);
        _dateEndTextController.text = _formatDate(event.endDate);
        _timeEndTextController.text = _formatTime(event.endDate);
        _selectedStartDate = event.startDate;
        _selectedStartTime = TimeOfDay.fromDateTime(event.startDate);
        _selectedEndDate = event.endDate;
        _selectedEndTime = TimeOfDay.fromDateTime(event.endDate);
      });
    } catch (error) {
      print('Error loading event details: $error');
    }
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day}.${dateTime.month}.${dateTime.year}";
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edytuj wydarzenie"),
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
              hexStringToColor("0B3963"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                  maxLines: 5,
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
                ElevatedButton(
                  onPressed: () => _selectStartDateAndTime(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Text(
                        _dateStartTextController.text.isNotEmpty
                            ? '${_dateStartTextController.text} ${_timeStartTextController.text}'
                            : 'Wybierz datę rozpoczęcia.',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _selectEndDateAndTime(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Text(
                        _dateEndTextController.text.isNotEmpty
                            ? '${_dateEndTextController.text} ${_timeEndTextController.text}'
                            : 'Wybierz datę zakończenia.',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                // ... other UI elements as needed
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
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

            if (selectedEndDateTime.isBefore(selectedStartDateTime)) {
              createSnackBarError(
                'Data zakończenia musi być późniejsza\nniż data rozpoczęcia.',
                context,
              );
              return;
            }

            if (event.participants > int.parse(_maxParticipantsController.text)) {
              createSnackBarError(
                'Zapisało się za dużo uczestników by zmniejszyć\npojemność wydarzenia.',
                context,
              );
              return;
            }

            List<GeoPoint> geoPoints = _points.map((latLng) {
              return GeoPoint(latLng.latitude, latLng.longitude);
            }).toList();

            await eventRepository.updateEvent(
              widget.eventId,
              _titleController.text,
              _descriptionController.text,
              selectedStartDateTime,
              selectedEndDateTime,
              int.parse(_maxParticipantsController.text),
              event.participants,
              geoPoints,
              event.owner,
            );

            Navigator.pop(context);
            createSnackBar("Pomyślnie zaktualizowano event.", context);
          } catch (e) {
            createSnackBarError("Błąd serwera!\nSpróbuj ponownie.", context);
          }
        },
        tooltip: 'Zapisz zmiany',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.check),
      ),
    );
  }

  void _selectStartDateAndTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedStartDate) {
      setState(() {
        _selectedStartDate = pickedDate;
        _dateStartTextController.text =
        "${pickedDate.day}.${pickedDate.month}.${pickedDate.year}";
      });

      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedStartTime,
      );

      if (pickedTime != null && pickedTime != _selectedStartTime) {
        setState(() {
          _selectedStartTime = pickedTime;
          _timeStartTextController.text =
          "${pickedTime.hour}:${pickedTime.minute}";
        });
      }
    }
  }

  void _selectEndDateAndTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedEndDate) {
      setState(() {
        _selectedEndDate = pickedDate;
        _dateEndTextController.text =
        "${pickedDate.day}.${pickedDate.month}.${pickedDate.year}";
      });

      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedEndTime,
      );

      if (pickedTime != null && pickedTime != _selectedEndTime) {
        setState(() {
          _selectedEndTime = pickedTime;
          _timeEndTextController.text =
          "${pickedTime.hour}:${pickedTime.minute}";
        });
      }
    }
  }

}
