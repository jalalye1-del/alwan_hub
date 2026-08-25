import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:alwan_hub/core/recording/models/recording_file.dart'; // مطلوب لـ RecordingSourceType
import 'package:alwan_hub/core/recording/providers/recording_state.dart';
import 'package:alwan_hub/core/recording/providers/recording_provider.dart';
import 'package:alwan_hub/core/recording/repositories/recording_repository.dart';
import 'package:alwan_hub/core/recording/services/recording_service.dart';
import 'package:alwan_hub/core/recording/services/recording_types.dart'; // 🟢 1. أضف الاستيراد المطلوب
import 'package:alwan_hub/core/storage/hive_service.dart';

class RecordingNotifier extends StateNotifier<RecordingState> {
  RecordingNotifier(
    this._repository,
    this._recordingService,
    this._foldersBox,
  ) : super(const RecordingState());

  final RecordingRepository _repository;
  final RecordingService _recordingService;
  final Box<String> _foldersBox;

  List<RecordingFile> _applyFilters(
    List<RecordingFile> recordings, {
    String? query,
    String? folder,
    bool useCurrentFolder = true,
  }) {
    final normalizedQuery = (query ?? state.searchQuery).trim().toLowerCase();
    final selectedFolder = useCurrentFolder
        ? folder ?? state.selectedFolder
        : folder;

    return recordings.where((recording) {
      final matchesFolder = selectedFolder == null ||
          recording.folderName == selectedFolder;
      final matchesSearch = normalizedQuery.isEmpty ||
          recording.title.toLowerCase().contains(normalizedQuery) ||
          recording.folderName.toLowerCase().contains(normalizedQuery) ||
          (recording.programName ?? '').toLowerCase().contains(normalizedQuery) ||
          (recording.stationName ?? '').toLowerCase().contains(normalizedQuery);
      return matchesFolder && matchesSearch;
    }).toList();
  }

  //==========================================================================
  // دالة مساعدة لتقليل التكرار (DRY)
  //==========================================================================
  Future<void> _executeWithReload(Future<void> Function() action) async {
    try {
      await action();
      await loadRecordings();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  //==========================================================================
  // تحميل البيانات
  //==========================================================================

  Future<void> loadRecordings() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final recordings = await _repository.getAllRecordings();
      final favorites = await _repository.getFavoriteRecordings();
      final folders = <String>{
        'تسجيلاتي',
        ..._foldersBox.values,
        ...recordings.map((recording) => recording.folderName),
      }.where((folder) => folder.trim().isNotEmpty).toList()
        ..sort();

      state = state.copyWith(
        recordings: recordings,
        filteredRecordings: _applyFilters(recordings),
        favorites: favorites,
        folders: folders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);

    try {
      await _repository.refreshLibrary();
      await loadRecordings();
    } finally {
      // ضمان إعادة الحالة حتى في حال الفشل
      state = state.copyWith(isRefreshing: false);
    }
  }

  //==========================================================================
  // البحث
  //==========================================================================

  Future<void> search(String query) async {
    state = state.copyWith(
      searchQuery: query,
      filteredRecordings: _applyFilters(state.recordings, query: query),
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      filteredRecordings: _applyFilters(state.recordings, query: ''),
    );
  }

  Future<bool> createFolder(String name) async {
    final folderName = name.trim();
    if (folderName.isEmpty) return false;

    final existing = state.folders.any(
      (folder) => folder.toLowerCase() == folderName.toLowerCase(),
    );
    if (existing) return false;

    await _foldersBox.put(folderName, folderName);
    final folders = [...state.folders, folderName]..sort();
    state = state.copyWith(folders: folders, clearError: true);
    return true;
  }

  void selectFolder(String? folder) {
    state = state.copyWith(
      selectedFolder: folder,
      clearSelectedFolder: folder == null,
      filteredRecordings: _applyFilters(
        state.recordings,
        folder: folder,
        useCurrentFolder: false,
      ),
    );
  }

  //==========================================================================
  // المفضلة
  //==========================================================================

  Future<void> toggleFavorite(String id) async {
    await _executeWithReload(() => _repository.toggleFavorite(id));
  }

  //==========================================================================
  // إعادة التسمية
  //==========================================================================

  Future<void> renameRecording(
    String id,
    String newTitle,
  ) async {
    await _executeWithReload(() => _repository.renameRecording(id, newTitle));
  }

  //==========================================================================
  // النقل
  //==========================================================================

  Future<void> moveRecording({
    required String id,
    required String folder,
  }) async {
    await _executeWithReload(() => _repository.moveRecording(
      id: id,
      destinationFolder: folder,
    ));
  }

  Future<void> moveSelected(String folder) async {
    final ids = state.selectedIds.toList();
    await _executeWithReload(() async {
      for (final id in ids) {
        await _repository.moveRecording(
          id: id,
          destinationFolder: folder,
        );
      }
      clearSelection();
    });
  }

  //==========================================================================
  // الحذف
  //==========================================================================

  Future<void> deleteRecording(String id) async {
    await _executeWithReload(() => _repository.deleteRecording(id));
  }

  Future<void> deleteSelected() async {
    await _executeWithReload(() async {
      await _repository.deleteRecordings(
        state.selectedIds.toList(),
      );
      clearSelection();
    });
  }

  Future<void> clearAll() async {
    await _executeWithReload(() async {
      await _repository.clearAll();
      clearSelection();
    });
  }

  //==========================================================================
  // التحديد
  //==========================================================================

  void toggleSelection(String id) {
    final selected = Set<String>.from(state.selectedIds);

    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }

    state = state.copyWith(
      selectedIds: selected,
      selectionMode: selected.isNotEmpty,
    );
  }

  void selectAll() {
    state = state.copyWith(
      selectionMode: true,
      selectedIds: state.recordings
          .map((e) => e.id)
          .toSet(),
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedIds: {},
      selectionMode: false,
    );
  }

  //==========================================================================
  // التسجيل
  //==========================================================================

  Future<void> startRecording({
    required String streamUrl,
    required String title,
    required String folderName,
    required String category,
    required RecordingSourceType sourceType,
    String? programName,
    String? imagePath,
  }) async {
    // إزالة التغيير الاستباقي للحالة
    try {
      final result = await _recordingService.startRecording(
        streamUrl: streamUrl,
        title: title,
        folderName: folderName,
        category: category,
        sourceType: sourceType,
        programName: programName,
        imagePath: imagePath,
      );

      switch (result) {
        case RecordingSuccess():
          state = state.copyWith(
            isRecording: true,
            clearError: true,
          );
        case RecordingFailure(:final error):
          state = state.copyWith(
            isRecording: false,
            errorMessage: error.name, // يمكنك تخصيص الرسالة هنا لاحقاً
          );
      }
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> stopRecording() async {
    try {
      final result = await _recordingService.stopRecording();

      switch (result) {
        case RecordingSuccess():
          state = state.copyWith(
            isRecording: false,
            clearError: true,
          );
          await loadRecordings();
          clearSelection(); // 🟢 3. مسح التحديد حتى لا تبقى العناصر المحذوفة أو المنتهية محددة
          return true;
        case RecordingFailure(:final error):
          state = state.copyWith(
            isRecording: false,
            errorMessage: error.name,
          );
          return false;
      }
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // 🟢 2. تعديل دالة cancelRecording مع معالجة الأخطاء
  Future<void> cancelRecording() async {
    try {
      await _recordingService.cancelRecording();

      state = state.copyWith(
        isRecording: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Provider الرئيسي
final recordingNotifierProvider =
    StateNotifierProvider<RecordingNotifier, RecordingState>(
  (ref) {
    return RecordingNotifier(
      ref.read(recordingRepositoryProvider),
      ref.read(recordingServiceProvider),
      Hive.box<String>(HiveService.recordingFoldersBoxName),
    );
  },
);
