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
    if (superclass == 'StatelessWidget' || superclass == 'StatefulWidget') {
      return true;
    }

    // Check if it's a `State` class for a `StatefulWidget`.
    if (superclass == 'State' &&
        extendsClause.superclass.typeArguments != null) {
      return true;
    }

    return false;
  }

  void _checkMethods(ClassDeclaration node, ErrorReporter reporter) {
    // Get the LineInfo from the node
    final lineInfo = node.thisOrAncestorOfType<CompilationUnit>()?.lineInfo;

    if (lineInfo == null) {
      return; // Handle cases where LineInfo is unavailable
    }

    for (final ClassMember member in node.members) {
      if (member is MethodDeclaration) {
        final returnType = member.returnType?.toString() ?? '';
        final methodName = member.name.lexeme;

        // Check if the return type is `Widget` and it's not the `build` method
        if (returnType == 'Widget' && methodName != 'build') {
          final methodStartOffset = member.beginToken.offset;
          final methodEndOffset = member.endToken.offset;

          // Use LineInfo to get line numbers
          final methodStartLine =
              lineInfo.getLocation(methodStartOffset).lineNumber;
          final methodEndLine =
              lineInfo.getLocation(methodEndOffset).lineNumber;

          final methodLineCount = methodEndLine - methodStartLine + 1;

          // Allow if the method has less than 50 lines
          if (methodLineCount < 30) {
            continue;
          }

          // Report an error if the method is too long
          reporter.reportErrorForNode(_code, member);
        }
      }
    }
  }
}
