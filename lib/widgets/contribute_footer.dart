import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String contributionsUrl =
    'https://github.com/M4dhav/BU-PYQ/blob/main/CONTRIBUTIONS.md';

class ContributeFooterCard extends StatelessWidget {
  const ContributeFooterCard({super.key});

  Future<void> _open() async {
    await launchUrl(
      Uri.parse(contributionsUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.handshake_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Found this useful?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Help fellow students — contribute the papers you have.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _open,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Contribute'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
