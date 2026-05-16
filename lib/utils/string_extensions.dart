extension StringExtensions on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;

  String capitalizeAll() => split(' ').map((e) => e.capitalize()).join(' ');
}
