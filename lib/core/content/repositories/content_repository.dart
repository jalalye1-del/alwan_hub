import '../models/managed_content.dart';

abstract interface class ContentRepository {
  Future<List<ManagedContent>> fetchPublished({String? type});

  Future<ManagedContent?> fetchById(String id);

  Stream<List<ManagedContent>> watchPublished({String? type});
}
