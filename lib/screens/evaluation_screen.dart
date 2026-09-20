import 'package:flutter/material.dart';
import '../models/evaluation_data.dart';
import '../theme/app_colors.dart';
import '../db/database_helper.dart';
import 'home_screen.dart';

class EvaluationScreen extends StatefulWidget {
  final Map<String, dynamic>? datosExistentes;
  final int? evaluacionId;

  const EvaluationScreen({super.key, this.datosExistentes, this.evaluacionId});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  int _currentStep = 0;
  final Map<String, dynamic> _values = {};
  final Set<String> _selectedConditions = {};
  @override
  void initState() {
    super.initState();
    if (widget.datosExistentes != null) {
      _values.addAll(widget.datosExistentes!);
    }
  }

  Widget _buildField(EvalFieldDef f) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: f.label,
          suffixText: f.suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType:
            f.type == FieldType.number ? TextInputType.number : TextInputType.text,
            initialValue: _values[f.key]?.toString(),
        onChanged: (v) => _values[f.key] = v,
      ),
    );
  }

  Widget _buildConditionChecks() {
    return Wrap(
      spacing: 8,
      children: medicalConditions.map((c) {
        final selected = _selectedConditions.contains(c);
        return FilterChip(
          label: Text(c),
          selected: selected,
          onSelected: (v) {
            setState(() {
              if (v) {
                _selectedConditions.add(c);
              } else {
                _selectedConditions.remove(c);
              }
            });
          },
        );
      }).toList(),
    );
  }

  double? get _imc {
    final peso = double.tryParse(_values['peso']?.toString() ?? '');
    final estatura = double.tryParse(_values['estatura']?.toString() ?? '');
    if (peso == null || estatura == null || estatura == 0) return null;
    final metros = estatura / 100;
    return peso / (metros * metros);
  }

  void _finish() async {
    if (widget.evaluacionId != null) {
  await DatabaseHelper().actualizarEvaluacion(
    widget.evaluacionId!,
    _values,
    _selectedConditions,
  );
} else {
  await DatabaseHelper().guardarEvaluacion(_values, _selectedConditions);
}
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Evaluación Inicial'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        type: StepperType.vertical,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _finish();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: details.onStepContinue,
                child: Text(_currentStep == 2 ? 'Finalizar' : 'Siguiente',
                    style: const TextStyle(color: Colors.white)),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Atrás'),
                ),
              ],
            ],
          ),
        ),
        steps: [
          Step(
            title: const Text('Datos personales'),
            isActive: _currentStep >= 0,
            content: Column(children: personalFields.map(_buildField).toList()),
          ),
          Step(
            title: const Text('Ficha médica'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                ...medicalTextFields.map(_buildField),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Condiciones médicas',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _buildConditionChecks(),
                const SizedBox(height: 12),
                ...heartRateFields.map(_buildField),
              ],
            ),
          ),
          Step(
            title: const Text('Antropometría'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                ...anthropometryFields.map(_buildField),
                if (_imc != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('IMC calculado: ${_imc!.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Composición corporal (manual)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...bodyCompositionFields.map(_buildField),
                const SizedBox(height: 12),
                _buildField(finalObservations),
              ],
            ),
          ),
        ],
      ),
    );
  }
}