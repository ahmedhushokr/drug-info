import 'dart:io';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeImagePicked extends HomeState {
  final File file;
  HomeImagePicked(this.file);
}

// Image Upload States
class HomeImageUploadLoading extends HomeState {}

class HomeImageUploadSuccess extends HomeState {
  final dynamic data;
  HomeImageUploadSuccess(this.data);
}

class HomeImageUploadFailure extends HomeState {
  final String error;
  HomeImageUploadFailure(this.error);
}

// History States
class HomeHistoryLoading extends HomeState {}

class HomeHistorySuccess extends HomeState {
  final List<dynamic> history;
  HomeHistorySuccess(this.history);
}

class HomeHistoryFailure extends HomeState {
  final String error;
  HomeHistoryFailure(this.error);
}

class HomeExportFileLoading extends HomeState {}

class HomeExportFileSuccess extends HomeState {
  final String filePath;
  final String format;

  HomeExportFileSuccess(this.filePath, this.format);
}

class HomeExportFileFailure extends HomeState {
  final String error;
  HomeExportFileFailure(this.error);
}

// Search States
class HomeSearchLoading extends HomeState {}

class HomeSearchSuccess extends HomeState {
  final List<dynamic> results;
  HomeSearchSuccess(this.results);
}

class HomeSearchFailure extends HomeState {
  final String error;
  HomeSearchFailure(this.error);
}
