import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourpis/repository/event_repository.dart';
import 'package:tourpis/repository/event_request_repository.dart';

import '../../../utils/color_utils.dart';
import '../../../widgets/widget.dart';
import '../friends/add_event_request/add_event_friends_screen.dart';
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
  final eventRequestRepository = EventRequestRepository();

  List<LatLng> _points = [];
  List<String> _requestList = [];

  bool doneMap = false;
  bool doneFriends = false;

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

  Future<void> _selectStartDateAndTime(BuildContext context) async {
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

  Future<void> _selectEndDateAndTime(BuildContext context) async {
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
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0.1,
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0.4
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
                      ]),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                addEventView: this,
                              ),
                            ),
                          );
                        });
                      },
                      child: Column(
                        children: [
                          iconButton(Icons.map, doneMap),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Mapa',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    InkWell(
                      onTap: () async {
                        final selectedUsers = await Navigator.push<List<String>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEventFriendsListScreen(
                              requestList: _requestList,
                              onRequestListChanged: (List<String> updatedList) {
                                setState(() {
                                  _requestList = updatedList;
                                });
                              },
                            ),
                          ),
                        );
                        if (selectedUsers != null && selectedUsers.isNotEmpty) {
                          setState(() {
                            _requestList = selectedUsers;
                            doneFriends = true;
                          });
                        }
                      },
                      child: Column(
                        children: [
                          iconButton(Icons.person_add_alt_rounded, doneFriends),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Zaproś',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
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
              _dateEndTextController.text.isEmpty ||
              _maxParticipantsController.text.isEmpty ||
              doneMap == false) {
            createSnackBarError(
                'Nie wypełniono wszystkich wymaganych pól.', context);
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

            if (selectedEndDateTime.isBefore(selectedStartDateTime)) {
              createSnackBarError(
                  'Data zakończenia musi być późniejsza\nniż data rozpoczęcia.',
                  context);
              return;
            }

            List<GeoPoint> geoPoints = _points.map((latLng) {
              return GeoPoint(latLng.latitude, latLng.longitude);
            }).toList();

            String? eventId;

            try {
              eventId = await eventRepository.createEvent(
                  _titleController.text,
                  _descriptionController.text,
                  selectedStartDateTime,
                  selectedEndDateTime,
                  int.parse(_maxParticipantsController.text),
                  geoPoints);
            } catch (e) {
              createSnackBarError("Błąd serwera!\nSpróbuj ponownie.", context);
            } finally {
              sendRequestToEvent(eventId!);
            }

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

  void sendRequestToEvent(String eventId) {
    try {
      for (var userId in _requestList) {
        eventRequestRepository.createRequest(eventId, userId, true);
        print(userId);
      }
    } catch (e) {
      print("Error send request");
    }
  }
}
