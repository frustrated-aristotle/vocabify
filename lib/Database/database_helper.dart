import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'wordnet_db.db');

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load('assets/wordnet_db.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path);
  }

  Future<List<String>> searchWords(String query) async {
    final db = await database;
    List<String> results = [];

    // Exact match
    final exactMatch = await db.rawQuery('SELECT word FROM words WHERE word = ? ORDER BY word ASC', [query]);
    results.addAll(exactMatch.map((word) => word["word"].toString()));
    // Starts with
    final startsWith = await db.rawQuery('SELECT word FROM words WHERE word LIKE ? ORDER BY word ASC', ['$query%']);
    results.addAll(startsWith.map((word) => word["word"].toString()));

    // Contains (excluding those that start with the query to avoid duplicates)
    final contains = await db.rawQuery('SELECT word FROM words WHERE word LIKE ? AND word NOT LIKE ? ORDER BY word ASC', ['%$query%', '$query%']);
    results.addAll(contains.map((word) => word["word"].toString()));

    return results;
  }
}
