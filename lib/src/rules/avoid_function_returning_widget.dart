import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidFunctionReturningWidget extends DartLintRule {
  const AvoidFunctionReturningWidget() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_function_returning_widget',
    problemMessage:
        'Avoid creating widget-returning functions inside widget classes.',
    correctionMessage:
        'Consider moving this function outside the widget class or creating a separate widget component.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (_isWidgetClass(node)) {
        _checkMethods(node, reporter);
      }
    });
  }

  bool _isWidgetClass(ClassDeclaration node) {
    final ExtendsClause? extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclass = extendsClause.superclass.name2.toString();
    return superclass == 'StatelessWidget' || superclass == 'StatefulWidget';
  }

  void _checkMethods(ClassDeclaration node, ErrorReporter reporter) {
    for (final member in node.members) {
      if (member is MethodDeclaration) {
        final returnType = member.returnType?.toString() ?? '';
        if (returnType == 'Widget' && !member.name.lexeme.startsWith('build')) {
          reporter.reportErrorForNode(_code, member);
        }
      }
    }
  }
}
