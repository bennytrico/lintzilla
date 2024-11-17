library lintzilla;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:lintzilla/src/rules/avoid_function_returning_widget.dart';

// This is the entrypoint of our custom linter
PluginBase createPlugin() => _ExampleLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _ExampleLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const AvoidFunctionReturningWidget(),
      ];
}