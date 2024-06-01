// ignore_for_file: implementation_imports
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:reactive_forms_generator/src/form_elements/form_element_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

const _formChecker = TypeChecker.fromUrl(
  'package:reactive_forms_annotations/src/reactive_form_annotation.dart#ReactiveFormAnnotation',
);

const formControlChecker = TypeChecker.fromUrl(
  'package:reactive_forms_annotations/src/form_control_annotation.dart#FormControlAnnotation',
);

const formArrayChecker = TypeChecker.fromUrl(
  'package:reactive_forms_annotations/src/form_array_annotation.dart#FormArrayAnnotation',
);

const formGroupChecker = TypeChecker.fromUrl(
  'package:reactive_forms_annotations/src/form_group_annotation.dart#FormGroupAnnotation',
);

extension LibraryReaderExt on LibraryReader {
  Iterable<AnnotatedElement> get rfAnnotated {
    return annotatedWith(_formChecker);
  }
}

extension MapExt on Map<String, String> {
  bool get hasRequiredValidator {
    return containsKey(FormElementGenerator.validatorKey) &&
        this[FormElementGenerator.validatorKey]
                ?.contains('RequiredValidator()') ==
            true;
  }
}

extension ElementRfExt on Element {
  bool get hasRfGroupAnnotation {
    return formGroupChecker.hasAnnotationOfExact(this);
  }

  Map<String, String> annotationParams(TypeChecker? typeChecker) {
    final result = <String, String>{};
    final annotation = typeChecker?.firstAnnotationOf(this);
    try {
      if (annotation != null) {
        for (final meta in metadata) {
          final obj = meta.computeConstantValue()!;

          if (typeChecker?.isExactlyType(obj.type!) == true) {
            final argumentList = (meta as ElementAnnotationImpl)
                .annotationAst
                .arguments as ArgumentListImpl;
            for (var argument in argumentList.arguments) {
              final argumentNamedExpression = argument as NamedExpressionImpl;
              result.addEntries(
                [
                  MapEntry(
                    argumentNamedExpression.name.label.toSource(),
                    argumentNamedExpression.expression.toSource(),
                  ),
                ],
              );
            }
          }
        }
      }

      return result;
    } catch (e) {
      return result;
    }
  }
}

extension ParameterElementAnnotationExt on ParameterElement {
  bool get hasRfAnnotation {
    return _formChecker.hasAnnotationOfExact(this);
  }

  bool get hasRfArrayAnnotation {
    return formArrayChecker.hasAnnotationOfExact(
      this,
      throwOnUnresolved: false,
    );
  }
}

extension FieldElementAnnotationExt on FieldElement {
  bool get hasRfAnnotation {
    return _formChecker.hasAnnotationOfExact(this);
  }
}

extension ClassElementAnnotationExt on ClassElement {
  bool get hasRfAnnotation {
    return _formChecker.hasAnnotationOfExact(this);
  }

  DartObject? get rfAnnotation {
    return _formChecker.firstAnnotationOfExact(this);
  }

  bool get output {
    try {
      if (hasRfAnnotation) {
        final annotation = rfAnnotation;
        return annotation?.getField('output')?.toBoolValue() ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
