import 'package:hive/hive.dart';
import '../models/library_item_model.dart';
import 'library_local_data_source.dart';

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  static const String boxName = 'library_items_box';

  final Box<LibraryItemModel> itemBox;

  LibraryLocalDataSourceImpl({required this.itemBox});

  @override
  Future<List<LibraryItemModel>> getItems() async {
    return itemBox.values.toList();
  }

  @override
  Future<LibraryItemModel?> getItem(String id) async {
    return itemBox.get(id);
  }

  @override
  Stream<List<LibraryItemModel>> watchItems() async* {
    yield itemBox.values.toList();
    yield* itemBox.watch().map((_) => itemBox.values.toList());
  }

  @override
  Future<void> saveItem(LibraryItemModel item) async {
    await itemBox.put(item.id, item);
  }

  @override
  Future<void> updateItem(LibraryItemModel item) async {
    await itemBox.put(item.id, item);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await itemBox.delete(itemId);
  }

  @override
  Future<bool> exists(String id) async {
    return itemBox.containsKey(id);
  }

  @override
  Future<void> clearItems() async {
    await itemBox.clear();
  }
}
