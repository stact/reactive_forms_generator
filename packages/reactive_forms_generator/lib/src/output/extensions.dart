import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';

import 'package:source_gen/source_gen.dart';

extension ElementExt on Element {
  Future<Declaration> clone() async {
    final unit = await session!.getResolvedUnit(
      source!.fullName,
    );
    unit as ResolvedUnitResult;
    final Object? ast = unit.unit.declarations.firstWhereOrNull(
      (declaration) {
        return declaration.declaredElement?.name == name!;
      },
    );
    if (ast == null) {
      throw InvalidGenerationSourceError(
        'Ast not found',
        element: this,
      );
    }
    if (ast is! Declaration) {
      throw InvalidGenerationSourceError(
        'Ast is not a Declaration',
        element: this,
      );
    }

    final clonedSource = parseString(content: ast.toSource());

    final Object? clonedAst = clonedSource.unit.declarations.firstWhereOrNull(
      (declaration) {
        return declaration is ClassDeclaration &&
            (declaration).name.lexeme == name;
      },
    );
    if (clonedAst == null) {
      throw InvalidGenerationSourceError('Ast not found', element: this);
    }
    if (clonedAst is! Declaration) {
      throw InvalidGenerationSourceError(
        'Ast is not a Declaration',
        element: this,
      );
    }

    return clonedAst;
  }
}
