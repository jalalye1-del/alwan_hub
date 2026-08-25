import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:alwan_hub/core/recording/data_sources/hive_recording_local_data_source.dart';
import 'package:alwan_hub/core/recording/data_sources/recording_local_data_source.dart';
import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/repositories/recording_repository.dart';
import 'package:alwan_hub/core/recording/repositories/recording_repository_impl.dart';
import 'package:alwan_hub/core/recording/services/recording_service.dart';
import 'package:alwan_hub/core/recording/services/storage_service.dart';
import 'package:alwan_hub/core/recording/services/storage_service_factory.dart';

export 'recording_notifier.dart';

final recordingBoxProvider = Provider<Box<RecordingFile>>(
  (ref) => Hive.box<RecordingFile>(HiveRecordingLocalDataSource.boxName),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => createStorageService(),
);

final recordingLocalDataSourceProvider = Provider<RecordingLocalDataSource>(
  (ref) => HiveRecordingLocalDataSource(ref.read(recordingBoxProvider)),
);

final recordingRepositoryProvider = Provider<RecordingRepository>(
  (ref) => RecordingRepositoryImpl(
    localDataSource: ref.read(recordingLocalDataSourceProvider),
    storageService: ref.read(storageServiceProvider),
  ),
);

final recordingServiceProvider = Provider<RecordingService>(
  (ref) => RecordingServiceImpl(
    repository: ref.read(recordingRepositoryProvider),
    storageService: ref.read(storageServiceProvider),
  ),
);
