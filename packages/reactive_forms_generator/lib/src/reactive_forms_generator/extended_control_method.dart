import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:reactive_forms_generator/src/extensions.dart';
import 'package:reactive_forms_generator/src/reactive_form_generator_method.dart';

class ExtendedControlMethod extends ReactiveFormGeneratorMethod {
  ExtendedControlMethod(ParameterElement field) : super(field);

  // @override
  // Method? formGroupMethod() {
  //   final reference = 'FormGroup${field.nullabilitySuffix}';
  //
  //   String body = 'form.control(${field.fieldControlPath}()) as $reference';
  //
  //   if (field.isNullable) {
  //     body =
  //     '${field.containsMethodName} ? form.control(${field.fieldControlPath}()) as $reference : null';
  //   }
  //
  //   return Method(
  //         (b) => b
  //       ..name = field.fieldExtendedControlName
  //       ..lambda = true
  //       ..type = MethodType.getter
  //       ..returns = Reference(reference)
  //       ..body = Code(body),
  //   );
  // }

  @override
  Method? formGroupArrayMethod() {
    final classElement = ((field.type as ParameterizedType)
        .typeArguments
        .first
        .element as ClassElement);

    final generics = classElement.generics;

    final typeReference =
        'ExtendedControl<List<Map<String, Object?>?>, List<${classElement.name}Form$generics>>';

    final body = '''
      ExtendedControl<List<Map<String, Object?>?>, List<${classElement.name}Form$generics>>(
          form.control(${field.fieldControlPath}())
              as FormArray<Map<String, Object?>>,
          () => ${field.name}${field.className})
    ''';

    return Method(
      (b) => b
        ..name = field.fieldExtendedControlName
        ..lambda = true
        ..type = MethodType.getter
        ..returns = Reference(typeReference)
        ..body = Code(body),
    );
  }

// @override
// Method? formArrayMethod() {
//   final type = (field.type as ParameterizedType).typeArguments.first;
//
//   String displayType = type.getDisplayString(withNullability: true);
//
//   // we need to trim last NullabilitySuffix.question cause FormControl modifies
//   // generic T => T?
//   if (type.nullabilitySuffix == NullabilitySuffix.question) {
//     displayType = displayType.substring(0, displayType.length - 1);
//   }
//
//   String typeReference = 'FormArray<$displayType>${field.nullabilitySuffix}';
//
//   String body = 'form.control(${field.fieldControlPath}()) as $typeReference';
//
//   if (field.isNullable) {
//     body =
//     '${field.containsMethodName} ? form.control(${field.fieldControlPath}()) as $typeReference : null';
//   }
//
//   return Method(
//         (b) => b
//       ..name = field.fieldExtendedControlName
//       ..lambda = true
//       ..type = MethodType.getter
//       ..returns = Reference(typeReference)
//       ..body = Code(body),
//   );
// }
//
// @override
// Method? formControlMethod() {
//   String displayType = field.type.getDisplayString(withNullability: true);
//
//   // we need to trim last NullabilitySuffix.question cause FormControl modifies
//   // generic T => T?
//   if (field.type.nullabilitySuffix == NullabilitySuffix.question) {
//     displayType = displayType.substring(0, displayType.length - 1);
//   }
//
//   final reference = 'FormControl<$displayType>${field.nullabilitySuffix}';
//
//   String body = 'form.control(${field.fieldControlPath}()) as $reference';
//
//   if (field.isNullable) {
//     body =
//     '${field.containsMethodName} ? form.control(${field.fieldControlPath}()) as $reference : null';
//   }
//
//   return Method(
//         (b) => b
//       ..name = field.fieldExtendedControlName
//       ..lambda = true
//       ..type = MethodType.getter
//       ..returns = Reference(reference)
//       ..body = Code(body),
//   );
// }
}
