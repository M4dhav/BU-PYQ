import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewer extends StatelessWidget {
  const PdfViewer({super.key});

  Future<void> _downloadPdf(String url, BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open download URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the URL from route arguments
    final String url =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Document Viewer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              onPressed:
                  url.isNotEmpty ? () => _downloadPdf(url, context) : null,
              icon: const Icon(Icons.download),
              tooltip: 'Download PDF',
            ),
          ],
        ),
        body:
            url.isNotEmpty
                ? SfPdfViewer.network(
                  url,
                  canShowTextSelectionMenu: false,
                  canShowSignaturePadDialog: false,
                  enableTextSelection: false,
                )
                : const Center(child: Text('No document URL provided')),
      ),
    );
  }
}
