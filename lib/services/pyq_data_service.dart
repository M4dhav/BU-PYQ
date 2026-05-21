import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';
import '../models/paper.dart';
import '../models/pyq_data.dart';

class PyqDataService {
  static const String _owner = 'M4dhav';
  static const String _repo = 'BU-PYQ';
  static const String _branch = 'main';
  static const String _dataFile = 'pyq-data.json';
  static const String _pdfFolder = 'pyqs';

  static const String _rawBase =
      'https://raw.githubusercontent.com/$_owner/$_repo/$_branch';

  Future<PyqData> fetchPyqData() async {
    final response = await http.get(Uri.parse('$_rawBase/$_dataFile'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch pyq-data.json (status ${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = PyqData.fromJson(decoded);

    for (final course in data.courses) {
      course.papers.sort((a, b) {
        final ay = a.yearOrNull;
        final by = b.yearOrNull;
        if (ay != null && by != null) {
          final yearCmp = by.compareTo(ay);
          if (yearCmp != 0) return yearCmp;
          return a.paperName.compareTo(b.paperName);
        }
        if (ay != null) return -1;
        if (by != null) return 1;
        return a.paperNum.compareTo(b.paperNum);
      });
    }

    return data;
  }

  Stream<Course> fetchCoursesStream() async* {
    final data = await fetchPyqData();
    for (final course in data.courses) {
      yield course;
    }
  }

  static String paperUrl(Paper paper) =>
      '$_rawBase/$_pdfFolder/${paper.paperId}';
}
