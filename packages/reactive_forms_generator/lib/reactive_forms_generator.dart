// ignore_for_file: implementation_imports

library reactive_forms_generator;

import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:reactive_forms_generator/src/extensions.dart';
import 'package:reactive_forms_generator/src/types.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen/src/output_helpers.dart';

import 'src/library_builder.dart';
import 'utils.dart';

class ReactiveFormsGenerator extends Generator {
  const ReactiveFormsGenerator();

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final specList = <Spec>[];

    final emitter = DartEmitter(
      allocator: Allocator.simplePrefixing(),
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    for (var annotatedElement in library.rfAnnotated) {
      specList.addAll(
        await generateForAnnotatedElement(
          annotatedElement.element,
          annotatedElement.annotation,
          buildStep,
        ),
      );
    }

    final lib = Library(
      (b) => b
        ..body.addAll(specList.mergeDuplicatesBy(
          (i) => i is Class ? i.name : i,
          (a, b) => a,
        )),
    );

    // final x = lib.accept(emitter).toString();

    final generatedValue =
        DartFormatter().format(lib.accept(emitter).toString());

    final values = <String>[];
    await for (var value in normalizeGeneratorOutput(generatedValue)) {
      assert(value.length == value.trim().length);
      values.add(value);
    }

    return values.join('\n\n');
  }

  Future<List<Spec>> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    throwIf(
      element is! ClassElement,
      '${element.name} is not a class element',
      element: element,
    );

    final unit = await element.session!.getResolvedUnit(
      element.source!.fullName,
    );
    unit as ResolvedUnitResult;
    final Object? ast = unit.unit.declarations.firstWhereOrNull(
      (declaration) => declaration.declaredElement?.name == element.name!,
    );
    if (ast == null) {
      throw InvalidGenerationSourceError('Ast not found', element: element);
    }
    if (ast is! Declaration) {
      throw InvalidGenerationSourceError(
        'Ast is not a Declaration',
        element: element,
      );
    }

    return await generateLibrary(element as ClassElement, ast);
  }
}
