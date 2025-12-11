import 'package:flutter/material.dart';

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
      height: screenHeight * 0.65,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // Display area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expression
                Text(
                  _getDisplayExpression(),
                  style: theme.textTheme.bodyLarge?.copyWith(
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

          // Calculator buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildButtonRow(['AC', '⌫', '÷']),
                  _buildButtonRow(['7', '8', '9', '×']),
                  _buildButtonRow(['4', '5', '6', '-']),
                  _buildButtonRow(['1', '2', '3', '+']),
                  _buildButtonRow(['00', '0', '=']),
                ],
              ),
            ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onConfirm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
    double flex = 1;

    if (label == 'AC') {
      backgroundColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.error;
    } else if (label == '⌫') {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.onSurface;
    } else if (label == '=') {
      backgroundColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
      flex = 2;
    } else if (_isOperator(label)) {
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.primary;
    } else {
      backgroundColor = theme.colorScheme.surface;
      textColor = theme.colorScheme.onSurface;
    }

    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          elevation: 1,
          child: InkWell(
            onTap: () => _handleButtonPress(label),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
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
    } else if (_isOperator(label)) {
      _onOperatorPressed(label);
    } else {
      _onNumberPressed(label);
    }
  }
}
