// ignore_for_file: implementation_imports
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/utilities.dart';
import 'package:analyzer/src/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/generated/utilities_dart.dart';

void replaceR(
  Map<String, FieldDeclaration> fieldDeclaration,
  Map<String, DefaultFormalParameter> fieldFormalParameter,
) {
  fieldFormalParameter.forEach((key, node) {
    final parameter = node.parameter as FieldFormalParameterImpl;
    final newParameter = DefaultFormalParameterImpl(
      parameter: FieldFormalParameterImpl(
        comment: null,
        metadata: parameter.metadata,
        covariantKeyword: parameter.covariantKeyword,
        requiredKeyword: KeywordToken(Keyword.REQUIRED, 0),
        name: parameter.name,
        keyword: parameter.keyword,
        type: parameter.type,
        thisKeyword: parameter.thisKeyword,
        period: parameter.period,
        typeParameters: parameter.typeParameters,
        parameters: parameter.parameters,
        question: parameter.question,
      ),
      kind: ParameterKind.NAMED_REQUIRED,
      separator: node.separator,
      defaultValue: node.defaultValue as ExpressionImpl?,
    );

    final field = fieldDeclaration[key];
    if (field != null && field is FieldDeclarationImpl) {
      final newField = FieldDeclarationImpl(
        comment: null,
        metadata: field.metadata,
        abstractKeyword: field.abstractKeyword,
        augmentKeyword: field.augmentKeyword,
        covariantKeyword: field.covariantKeyword,
        externalKeyword: field.externalKeyword,
        staticKeyword: field.staticKeyword,
        fieldList: VariableDeclarationListImpl(
          comment: null,
          metadata: field.fields.metadata,
          lateKeyword: field.fields.lateKeyword,
          keyword: field.fields.keyword,
          type: NamedTypeImpl(
            importPrefix: (field.fields.type as NamedTypeImpl).importPrefix,
            name2: (field.fields.type as NamedTypeImpl).name2,
            typeArguments: (field.fields.type as NamedTypeImpl).typeArguments,
            question: null,
          ),
          variables: field.fields.variables,
        ),
        semicolon: field.semicolon,
      );
      NodeReplacer.replace(field, newField);
    }

    NodeReplacer.replace(node, newParameter);
  });
}

String generateModifiedCode(String code, List<Annotation> annotations) {
  final buffer = StringBuffer();
  int lastIndex = 0;

  for (var annotation in annotations) {
    final offset = annotation.offset;
    final end = annotation.end;

    buffer.write(code.substring(lastIndex, offset));
    buffer.write('');
    lastIndex = end;
  }
  buffer.write(code.substring(lastIndex));

  return buffer.toString();
}
