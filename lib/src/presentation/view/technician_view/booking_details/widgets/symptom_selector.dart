import 'package:CarRescue/src/configuration/frontend_configs.dart';
import 'package:CarRescue/src/models/symptom.dart';
import 'package:CarRescue/src/providers/symptom_provider.dart';
import 'package:flutter/material.dart';

class SymptomSelector extends StatefulWidget {
  final Function(Symptom?) onSymptomSelected;

  SymptomSelector({required this.onSymptomSelected});

  @override
  _SymptomSelectorState createState() => _SymptomSelectorState();
}

class _SymptomSelectorState extends State<SymptomSelector> {
  List<Symptom> symptoms = [];
  Symptom? selectedSymptom; // Keep track of the selected symptom

  @override
  void initState() {
    super.initState();
    loadSymptoms();
  }

  Future<void> loadSymptoms() async {
    final _symptomProvider = SymptomProvider();
    try {
      List<Symptom> loadedSymptoms = await _symptomProvider.getAllSymptoms();
      setState(() {
        symptoms = loadedSymptoms;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: symptoms.map((symptom) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSymptom = symptom;
              widget.onSymptomSelected(
                  selectedSymptom); // Notify the parent widget
            });
          },
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: selectedSymptom == symptom
                  ? FrontendConfigs.kPrimaryColorCustomer
                  : Colors.grey,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              symptom.symptom1,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
