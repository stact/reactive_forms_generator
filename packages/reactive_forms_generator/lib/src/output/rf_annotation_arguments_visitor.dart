// ignore_for_file: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/utilities.dart';

class RfAnnotationArgumentsVisitor extends RecursiveAstVisitor<dynamic> {
  final arguments = <String, String>{};

  @override
  visitArgumentList(ArgumentList node) {
    for (var argument in node.arguments) {
      if (argument is NamedExpression) {
        arguments.addEntries(
          [
            MapEntry(
              argument.name.label.name,
              argument.expression.toSource().toString(),
            ),
          ],
        );
      } else {
        // For positional arguments
      }
    }
    return super.visitArgumentList(node);
  }
}

class ClassRenameVisitor extends RecursiveAstVisitor<void> {
  final String oldName;

  ClassRenameVisitor(this.oldName);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.name.lexeme == oldName && node is ClassDeclarationImpl) {
      final updatedClass = ClassDeclarationImpl(
        comment: null,
        metadata: node.metadata,
        augmentKeyword: node.augmentKeyword,
        abstractKeyword: node.abstractKeyword,
        macroKeyword: node.macroKeyword,
        sealedKeyword: node.sealedKeyword,
        baseKeyword: node.baseKeyword,
        interfaceKeyword: node.interfaceKeyword,
        finalKeyword: node.finalKeyword,
        mixinKeyword: node.mixinKeyword,
        classKeyword: node.classKeyword,
        name: StringToken(
          TokenType.STRING,
          '${node.name.lexeme}Output',
          0,
        ),
        typeParameters: node.typeParameters,
        extendsClause: node.extendsClause,
        withClause: node.withClause,
        implementsClause: node.implementsClause,
        nativeClause: node.nativeClause,
        leftBracket: node.leftBracket,
        members: node.members,
        rightBracket: node.rightBracket,
      );

      NodeReplacer.replace(node, updatedClass);
    }
    super.visitClassDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (node is ConstructorDeclarationImpl && node.name == null) {
      final updatedNode = ConstructorDeclarationImpl(
        comment: null,
        metadata: node.metadata,
        augmentKeyword: node.augmentKeyword,
        externalKeyword: node.externalKeyword,
        constKeyword: node.constKeyword,
        factoryKeyword: node.factoryKeyword,
        returnType: SimpleIdentifierImpl(
          StringToken(
            TokenType.STRING,
            '${node.returnType.name}Output',
            0,
          ),
        ),
        period: node.period,
        name: node.name,
        parameters: node.parameters,
        separator: node.separator,
        initializers: node.initializers,
        redirectedConstructor: node.redirectedConstructor,
        body: node.body,
      );
      NodeReplacer.replace(node, updatedNode);
    }
    super.visitConstructorDeclaration(node);
  }
}
