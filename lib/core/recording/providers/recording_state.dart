import 'package:flutter/foundation.dart';

import 'package:alwan_hub/core/recording/models/recording_file.dart';

@immutable
class RecordingState {
  /// جميع التسجيلات
  final List<RecordingFile> recordings;

  /// نتائج البحث الحالية
  final List<RecordingFile> filteredRecordings;

  /// التسجيلات المفضلة
  final List<RecordingFile> favorites;

  /// المجلدات التي أنشأها المستخدم
  final List<String> folders;

  /// المجلد المعروض حالياً، والقيمة null تعني عرض الكل
  final String? selectedFolder;

  /// التسجيلات المحددة
  final Set<String> selectedIds;

  /// التسجيل الجاري تشغيله
  final RecordingFile? currentRecording;

  /// هل يوجد تسجيل جارٍ الآن
  final bool isRecording;

  /// هل يوجد تحميل
  final bool isLoading;

  /// هل يوجد تحديث
  final bool isRefreshing;

  /// وضع التحديد المتعدد
  final bool selectionMode;

  /// نص البحث
  final String searchQuery;

  /// رسالة الخطأ
  final String? errorMessage;

  const RecordingState({
    this.recordings = const [],
    this.filteredRecordings = const [],
    this.favorites = const [],
    this.folders = const ['تسجيلاتي'],
    this.selectedFolder,
    this.selectedIds = const {},
    this.currentRecording,
    this.isRecording = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.selectionMode = false,
    this.searchQuery = '',
    this.errorMessage,
  });

  RecordingState copyWith({
    List<RecordingFile>? recordings,
    List<RecordingFile>? filteredRecordings,
    List<RecordingFile>? favorites,
    List<String>? folders,
    String? selectedFolder,
    Set<String>? selectedIds,
    RecordingFile? currentRecording,
    bool? isRecording,
    bool? isLoading,
    bool? isRefreshing,
    bool? selectionMode,
    String? searchQuery,
    String? errorMessage,
    bool clearCurrentRecording = false,
    bool clearSelectedFolder = false,
    bool clearError = false,
  }) {
    return RecordingState(
      recordings: recordings ?? this.recordings,
      filteredRecordings:
          filteredRecordings ?? this.filteredRecordings,
      favorites: favorites ?? this.favorites,
      folders: folders ?? this.folders,
      selectedFolder: clearSelectedFolder
          ? null
          : selectedFolder ?? this.selectedFolder,
      selectedIds: selectedIds ?? this.selectedIds,
      currentRecording: clearCurrentRecording
          ? null
          : currentRecording ?? this.currentRecording,
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      selectionMode: selectionMode ?? this.selectionMode,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  bool get hasRecordings => recordings.isNotEmpty;

  bool get hasFavorites => favorites.isNotEmpty;

  bool get hasSelection => selectedIds.isNotEmpty;

  int get selectedCount => selectedIds.length;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RecordingState &&
            listEquals(other.recordings, recordings) &&
            listEquals(
              other.filteredRecordings,
              filteredRecordings,
            ) &&
            listEquals(other.favorites, favorites) &&
            listEquals(other.folders, folders) &&
            other.selectedFolder == selectedFolder &&
            setEquals(other.selectedIds, selectedIds) &&
            other.currentRecording == currentRecording &&
            other.isRecording == isRecording &&
            other.isLoading == isLoading &&
            other.isRefreshing == isRefreshing &&
            other.selectionMode == selectionMode &&
            other.searchQuery == searchQuery &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(recordings),
        Object.hashAll(filteredRecordings),
        Object.hashAll(favorites),
        Object.hashAll(folders),
        selectedFolder,
        Object.hashAll(selectedIds),
        currentRecording,
        isRecording,
        isLoading,
        isRefreshing,
        selectionMode,
        searchQuery,
        errorMessage,
      );
}
