import 'package:flutter/material.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Calculator bottom sheet for transaction amount input
/// Returns the calculated result when confirmed
class CalculatorSheet extends StatefulWidget {
  final int? initialValue;

  const CalculatorSheet({
    super.key,
    this.initialValue,
  });

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  String _expression = '';
  String _result = '0';
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue! > 0) {
      _expression = widget.initialValue.toString();
      _result = _formatNumber(widget.initialValue!);
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_hasCalculated) {
        _expression = number;
        _hasCalculated = false;
      } else {
        _expression += number;
      }
      _updateResult();
    });
  }

  void _onOperatorPressed(String operator) {
    if (_expression.isEmpty) return;

    setState(() {
      _hasCalculated = false;
      // If the last character is an operator, replace it
      if (_isOperator(_expression[_expression.length - 1])) {
        _expression = _expression.substring(0, _expression.length - 1) + operator;
      } else {
        _expression += operator;
      }
    });
  }

  bool _isOperator(String char) {
    return char == '+' || char == '-' || char == '×' || char == '÷';
  }

  void _onClear() {
    setState(() {
      _expression = '';
      _result = '0';
      _hasCalculated = false;
    });
  }

  void _onBackspace() {
    if (_expression.isNotEmpty) {
      setState(() {
        _expression = _expression.substring(0, _expression.length - 1);
        _hasCalculated = false;
        _updateResult();
      });
    }
  }

  void _onEquals() {
    _updateResult();
    setState(() {
      _hasCalculated = true;
      // Replace expression with result for chained calculations
      final calculated = _calculate();
      if (calculated > 0) {
        _expression = calculated.toString();
      }
    });
  }

  void _updateResult() {
    final calculated = _calculate();
    setState(() {
      _result = _formatNumber(calculated);
    });
  }

  int _calculate() {
    if (_expression.isEmpty) return 0;

    try {
      // Parse the expression
      String expr = _expression;

      // Remove trailing operator
      while (expr.isNotEmpty && _isOperator(expr[expr.length - 1])) {
        expr = expr.substring(0, expr.length - 1);
      }

      if (expr.isEmpty) return 0;

      // Split by operators while keeping them
      List<String> tokens = [];
      String currentNumber = '';

      for (int i = 0; i < expr.length; i++) {
        String char = expr[i];
        if (_isOperator(char)) {
          if (currentNumber.isNotEmpty) {
            tokens.add(currentNumber);
            currentNumber = '';
          }
          tokens.add(char);
        } else {
          currentNumber += char;
        }
      }
      if (currentNumber.isNotEmpty) {
        tokens.add(currentNumber);
      }

      if (tokens.isEmpty) return 0;

      // First pass: handle × and ÷
      List<String> intermediate = [];
      int i = 0;
      while (i < tokens.length) {
        if (tokens[i] == '×' || tokens[i] == '÷') {
          if (intermediate.isNotEmpty && i + 1 < tokens.length) {
            int left = int.tryParse(intermediate.removeLast()) ?? 0;
            int right = int.tryParse(tokens[i + 1]) ?? 0;
            int result;
            if (tokens[i] == '×') {
              result = left * right;
            } else {
              result = right != 0 ? left ~/ right : 0;
            }
            intermediate.add(result.toString());
            i += 2;
          } else {
            i++;
          }
        } else {
          intermediate.add(tokens[i]);
          i++;
        }
      }

      // Second pass: handle + and -
      if (intermediate.isEmpty) return 0;

      int result = int.tryParse(intermediate[0]) ?? 0;
      i = 1;
      while (i < intermediate.length - 1) {
        String op = intermediate[i];
        int right = int.tryParse(intermediate[i + 1]) ?? 0;
        if (op == '+') {
          result += right;
        } else if (op == '-') {
          result -= right;
        }
        i += 2;
      }

      return result < 0 ? 0 : result;
    } catch (e) {
      return 0;
    }
  }

  void _onConfirm() {
    final result = _calculate();
    Navigator.of(context).pop(result);
  }

  String _getDisplayExpression() {
    if (_expression.isEmpty) return '0';
    // Format numbers in expression for display
    String display = '';
    String currentNumber = '';

    for (int i = 0; i < _expression.length; i++) {
      String char = _expression[i];
      if (_isOperator(char)) {
        if (currentNumber.isNotEmpty) {
          display += _formatNumber(int.tryParse(currentNumber) ?? 0);
          currentNumber = '';
        }
        display += ' $char ';
      } else {
        currentNumber += char;
      }
    }
    if (currentNumber.isNotEmpty) {
      display += _formatNumber(int.tryParse(currentNumber) ?? 0);
    }

    return display;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.68,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '계산기',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Display area with more padding
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expression
                Text(
                  _getDisplayExpression(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Result
                Text(
                  '$_result 원',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Calculator buttons - 4 column grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildButtonRow(['AC', '⌫', '%', '÷']),
                  _buildButtonRow(['7', '8', '9', '×']),
                  _buildButtonRow(['4', '5', '6', '-']),
                  _buildButtonRow(['1', '2', '3', '+']),
                  _buildButtonRow(['00', '0', '.', '=']),
                ],
              ),
            ),
          ),

          // Confirm button - emphasized as primary action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onConfirm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((button) => _buildButton(button)).toList(),
      ),
    );
  }

  Widget _buildButton(String label) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    double fontSize;
    FontWeight fontWeight;
    bool isIcon = false;

    // AC button - Rose/Red with white text
    if (label == 'AC') {
      backgroundColor = AppColors.danger; // Rose-500
      textColor = Colors.white;
      fontSize = 22;
      fontWeight = FontWeight.bold;
    }
    // Backspace - subtle gray with filled icon
    else if (label == '⌫') {
      backgroundColor = theme.colorScheme.surfaceContainerHigh;
      textColor = theme.colorScheme.onSurface;
      fontSize = 24;
      fontWeight = FontWeight.normal;
      isIcon = true;
    }
    // Percent - functional button
    else if (label == '%') {
      backgroundColor = theme.colorScheme.surfaceContainerHigh;
      textColor = theme.colorScheme.onSurface;
      fontSize = 22;
      fontWeight = FontWeight.w600;
    }
    // Equals - secondary emphasis (toned down)
    else if (label == '=') {
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      fontSize = 28;
      fontWeight = FontWeight.bold;
    }
    // Operators - Primary blue with white text for visibility
    else if (_isOperator(label)) {
      backgroundColor = theme.colorScheme.primary;
      textColor = Colors.white;
      fontSize = 26;
      fontWeight = FontWeight.bold;
    }
    // Decimal point - visually disabled (integer-only calculator)
    else if (label == '.') {
      backgroundColor = theme.colorScheme.surfaceContainerLow;
      textColor = AppColors.disabledText;
      fontSize = 24;
      fontWeight = FontWeight.w600;
    }
    // Number buttons - light background
    else {
      backgroundColor = theme.colorScheme.surfaceContainerLow;
      textColor = theme.colorScheme.onSurface;
      fontSize = 24;
      fontWeight = FontWeight.w600;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _handleButtonPress(label),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                alignment: Alignment.center,
                child: isIcon
                    ? Icon(
                        Icons.backspace_rounded, // Filled/rounded icon
                        color: textColor,
                        size: 26,
                      )
                    : Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleButtonPress(String label) {
    if (label == 'AC') {
      _onClear();
    } else if (label == '⌫') {
      _onBackspace();
    } else if (label == '=') {
      _onEquals();
    } else if (label == '%') {
      _onPercent();
    } else if (label == '.') {
      // Decimal point - ignored for integer-only calculator
      // Korean won doesn't use decimals
    } else if (_isOperator(label)) {
      _onOperatorPressed(label);
    } else {
      _onNumberPressed(label);
    }
  }

  void _onPercent() {
    // Convert current number to percentage (divide by 100)
    final calculated = _calculate();
    if (calculated != 0) {
      setState(() {
        final percentValue = calculated ~/ 100;
        _expression = percentValue.toString();
        _result = _formatNumber(percentValue);
        _hasCalculated = true;
      });
    }
  }
}
