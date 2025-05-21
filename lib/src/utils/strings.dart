extension StringExtension on String {
  String capitalize() {
    final thisString = this;
    return "${thisString[0].toUpperCase()}${thisString.substring(1).toLowerCase()}";
  }

  String getFileExtension() {
    final thisString = this;
    final extension = thisString.split('.').last.toLowerCase();
    return extension == 'jpg' ? 'jpeg' : extension;
  }
}
