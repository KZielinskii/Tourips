import 'package:flutter/material.dart';
import 'package:tourpis/models/UserModel.dart';
import 'package:tourpis/repository/user_repository.dart';

import '../../repository/event_participants_repository.dart';
import '../../repository/payments_repository.dart';
import '../../utils/color_utils.dart';
import '../../widgets/widget.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key, required this.eventId});

  final String eventId;

  @override
  AddPaymentView createState() => AddPaymentView();
}

class AddPaymentView extends State<AddPaymentScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late List<String> selectedParticipants = [];
  List<UserModel> participants = [];
  late final String userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _initParticipants();
  }

  Future<void> _initParticipants() async {
    List<UserModel?> users = await EventParticipantsRepository()
        .getParticipantsByEventId(widget.eventId);
    for (var user in users) {
      participants.add(user!);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _initializeState() async {
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    userId = (await UserRepository().getCurrentUserId())!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dodaj koszta"),
        backgroundColor: hexStringToColor("2F73B1"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width * 0.1,
                          MediaQuery.of(context).size.height * 0.1,
                          MediaQuery.of(context).size.width * 0.1,
                          MediaQuery.of(context).size.height * 0.1),
                      child: Column(children: [
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
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Koszt',
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            border: Border.all(color: Colors.white, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ExpansionTile(
                            title: const Text(
                              'Wybierz uczestników',
                              style: TextStyle(color: Colors.white),
                            ),
                            children: [
                              Builder(
                                builder: (BuildContext context) {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: participants.length,
                                    itemBuilder: (context, index) {
                                      UserModel? participant =
                                          participants[index];
                                      return CheckboxListTile(
                                        title: Text(
                                          participant.login,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        value: selectedParticipants
                                            .contains(participant.uid),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value != null) {
                                              if (value) {
                                                selectedParticipants
                                                    .add(participant.uid);
                                              } else {
                                                selectedParticipants
                                                    .remove(participant.uid);
                                              }
                                            }
                                          });
                                        },
                                        checkColor: Colors.blue,
                                        activeColor: Colors.white,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ])))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String title = _titleController.text;
          String amount = _amountController.text;

          if (title.isEmpty || amount.isEmpty || selectedParticipants.isEmpty) {
            createSnackBarError(
                'Wszystkie pola są wymagane.\nWybierz przynajmniej jednego uczestnika.',
                context);
          } else {
            try {
              await PaymentsRepository().create(
                widget.eventId,
                title,
                userId,
                amount,
                selectedParticipants,
              );
              Navigator.pop(context);
            } catch (e) {
              createSnackBarError(
                  'Wystąpił błąd podczas dodawania danych.\nSpróbuj ponownie później.',
                  context);
            }
          }
        },
        tooltip: 'Dodaj',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.check),
      ),
    );
  }
}
