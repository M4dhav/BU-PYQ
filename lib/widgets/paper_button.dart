import 'package:flutter/material.dart';

class PaperButton extends StatelessWidget {
  final String label;
  final String url;
  final double? fontSize;

  const PaperButton({
    super.key,
    required this.label,
    required this.url,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveFontSize = fontSize ?? 13.0;

    final lowerLabel = label.toLowerCase();
    
    final isDark = theme.brightness == Brightness.dark;
    
    Color bgColor = theme.colorScheme.primaryContainer;
    Color fgColor = theme.colorScheme.onPrimaryContainer;

    if (lowerLabel.contains('end semester')) {
      bgColor = Colors.green.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.green.shade300 : Colors.green.shade800;
    } else if (lowerLabel.contains('mid semester')) {
      bgColor = Colors.purple.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.purple.shade300 : Colors.purple.shade800;
    } else if (lowerLabel.contains('assignment') || lowerLabel.contains('nptel')) {
      bgColor = Colors.indigo.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.indigo.shade300 : Colors.indigo.shade800;
    } else if (lowerLabel.contains('lab')) {
      bgColor = Colors.teal.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.teal.shade300 : Colors.teal.shade800;
    } else if (lowerLabel.contains('quiz')) {
      bgColor = Colors.orange.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    } else if (lowerLabel.contains('supplementary') || lowerLabel.contains('makeup')) {
      bgColor = Colors.deepPurple.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade800;
    } else if (lowerLabel.contains('notes')) {
      bgColor = Colors.blueGrey.withValues(alpha: isDark ? 0.25 : 0.15);
      fgColor = isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade800;
    }

    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/pdf_viewer', arguments: url);
      },
      icon: Icon(Icons.picture_as_pdf_outlined, size: effectiveFontSize * 1.3),
      label: Text(
        label,
        style: TextStyle(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        softWrap: true,
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
