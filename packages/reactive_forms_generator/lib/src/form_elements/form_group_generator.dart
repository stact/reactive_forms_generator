import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:reactive_forms_generator/src/form_elements/form_array_generator.dart';
import 'package:reactive_forms_generator/src/form_elements/form_control_generator.dart';
import 'package:reactive_forms_generator/src/form_elements/form_element_generator.dart';
import 'package:reactive_forms_generator/src/types.dart';
import 'package:reactive_forms_generator/src/extensions.dart';

class FormGroupGenerator extends FormElementGenerator {
  FormGroupGenerator(ParameterElement field, DartType? type)
      : super(field, type);

  List<ParameterElement> get formElements =>
      (field.type.element as ClassElement)
          .constructors
          .where((e) => e.hasReactiveFormAnnotatedParameters)
          .first
          .parameters
          .where(
            (e) =>
                formControlChecker.hasAnnotationOfExact(e) ||
                formArrayChecker.hasAnnotationOfExact(e),
          )
          .toList();

  List<ParameterElement> get nestedFormElements =>
      (field.type.element as ClassElement)
          .constructors
          .where((e) => e.hasReactiveFormAnnotatedParameters)
          .first
          .parameters
          .where(
            (e) => e.type.element is ClassElement,
          )
          .where(
            (e) => formGroupChecker.hasAnnotationOfExact(e.type.element!),
          )
          .toList();

  @override
  String element() {
    final _formElements = formElements
        .map(
          (f) {
            FormElementGenerator? formElementGenerator;

            if (formControlChecker.hasAnnotationOfExact(f)) {
              formElementGenerator = FormControlGenerator(f, type);
            }

            if (formArrayChecker.hasAnnotationOfExact(f)) {
              formElementGenerator = FormArrayGenerator(f, type);
            }

            if (formElementGenerator != null) {
              return '${f.fieldControlNameName}: ${formElementGenerator.element()}';
            }

            return null;
          },
        )
        .whereType<String>()
        .toList();

    _formElements.addAll(
      nestedFormElements.map(
        (f) {
          return '${f.fieldControlNameName}: ${f.name}Form.formElements()';
        },
      ),
    );

    final props = [
      '{${_formElements.join(',')}}',
      'validators: [${syncValidatorList(formControlChecker).join(',')}]',
      'asyncValidators: [${asyncValidatorList(formControlChecker).join(',')}]',
      'asyncValidatorsDebounceTime: ${asyncValidatorsDebounceTime(formControlChecker)}',
      'disabled: ${disabled(formControlChecker)}',
    ].join(',');

    return 'FormGroup($props)';
  }
}
