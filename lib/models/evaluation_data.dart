enum FieldType { text, number }

class EvalFieldDef {
  final String key;
  final String label;
  final FieldType type;
  final String? suffix;
  const EvalFieldDef(this.key, this.label, {this.type = FieldType.text, this.suffix});
}

// --- Sección 1: Datos personales ---
const List<EvalFieldDef> personalFields = [
  EvalFieldDef('nombre', 'Nombre'),
  EvalFieldDef('apellido', 'Apellido'),
  EvalFieldDef('direccion', 'Dirección'),
  EvalFieldDef('telefono', 'Teléfono', type: FieldType.number),
];

// --- Sección 2: Ficha médica ---
const List<EvalFieldDef> medicalTextFields = [
  EvalFieldDef('antecedentesDeportivos', 'Antecedentes deportivos'),
  EvalFieldDef('antecedentesFisicos', 'Antecedentes físicos'),
  EvalFieldDef('antecedentesQuirurgicos', 'Antecedentes quirúrgicos'),
  EvalFieldDef('prescripcionMedica', 'Prescripción médica'),
  EvalFieldDef('observacionesMedicas', 'Observaciones médicas'),
];

const List<String> medicalConditions = [
  'Enfermedad cardiovascular',
  'Diabetes',
  'Hipertensión arterial',
  'Enfermedad pulmonar',
  'Problemas de colesterol',
  'Ahogo al esfuerzo',
  'Hipoglicemia',
  'Cefaleas',
  'Dolor muscular',
  'Problemas de espalda',
  'Fuma',
  'Trasnocha',
];

const List<EvalFieldDef> heartRateFields = [
  EvalFieldDef('fcReposo', 'Frec. cardíaca en reposo', type: FieldType.number, suffix: 'lpm'),
  EvalFieldDef('fcMaxima', 'Frec. cardíaca máxima', type: FieldType.number, suffix: 'lpm'),
];

// --- Sección 3: Antropometría (medidas) ---
const List<EvalFieldDef> anthropometryFields = [
  EvalFieldDef('estatura', 'Estatura', type: FieldType.number, suffix: 'cm'),
  EvalFieldDef('peso', 'Peso', type: FieldType.number, suffix: 'kg'),
  EvalFieldDef('hombro', 'Hombro', type: FieldType.number, suffix: 'cm'),
  EvalFieldDef('pecho', 'Pecho', type: FieldType.number, suffix: 'cm'),
  EvalFieldDef('brazo', 'Brazo', type: FieldType.number, suffix: 'cm'),
  EvalFieldDef('antebrazo', 'Antebrazo', type: FieldType.number, suffix: 'cm'),
  EvalFieldDef('cintura', 'Cintura', type: FieldType.number, suffix: 'cm'),
  EvalFieldDef('cadera', 'Cadera', type: FieldType.number, suffix: 'cm'),
  EvalFieldDef('muslos', 'Muslos', type: FieldType.number, suffix: 'cm'),
  EvalFieldDef('pantorrilla', 'Pantorrilla', type: FieldType.number, suffix: 'cm'),
];

// --- Composición corporal (manual, de báscula u otro medio) ---
const List<EvalFieldDef> bodyCompositionFields = [
  EvalFieldDef('grasaPct', '% Grasa corporal', type: FieldType.number, suffix: '%'),
  EvalFieldDef('musculoPct', '% Músculo', type: FieldType.number, suffix: '%'),
  EvalFieldDef('aguaPct', '% Agua', type: FieldType.number, suffix: '%'),
  EvalFieldDef('grasaVisceral', 'Grasa visceral', type: FieldType.number),
  EvalFieldDef('hueso', 'Hueso', type: FieldType.number, suffix: 'kg'),
  EvalFieldDef('metabolismo', 'Metabolismo basal', type: FieldType.number, suffix: 'kcal'),
  EvalFieldDef('proteina', 'Proteína', type: FieldType.number, suffix: '%'),
  EvalFieldDef('edadBiologica', 'Edad biológica', type: FieldType.number, suffix: 'años'),
  EvalFieldDef('pesoMagro', 'Peso magro', type: FieldType.number, suffix: 'kg'),
];

const EvalFieldDef finalObservations =
    EvalFieldDef('objetivoFinal', 'Objetivo / Observaciones finales');