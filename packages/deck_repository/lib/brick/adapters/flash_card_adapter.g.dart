// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<FlashCard> _$FlashCardFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return FlashCard(
    id: data['id'] as String?,
    question: data['question'] as String,
    answer: data['answer'] as String,
  );
}

Future<Map<String, dynamic>> _$FlashCardToSupabase(
  FlashCard instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'question': instance.question,
    'answer': instance.answer,
  };
}

Future<FlashCard> _$FlashCardFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return FlashCard(
    id: data['id'] as String,
    question: data['question'] as String,
    answer: data['answer'] as String,
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$FlashCardToSqlite(
  FlashCard instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'question': instance.question,
    'answer': instance.answer,
  };
}

/// Construct a [FlashCard]
class FlashCardAdapter extends OfflineFirstWithSupabaseAdapter<FlashCard> {
  FlashCardAdapter();

  @override
  final supabaseTableName = 'flash_cards';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'question': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'question',
    ),
    'answer': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'answer',
    ),
  };
  @override
  final ignoreDuplicates = false;
  @override
  final uniqueFields = {'id'};
  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'id': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: String,
    ),
    'question': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'question',
      iterable: false,
      type: String,
    ),
    'answer': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'answer',
      iterable: false,
      type: String,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    FlashCard instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `FlashCard` WHERE id = ? LIMIT 1''',
      [instance.id],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'FlashCard';

  @override
  Future<FlashCard> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$FlashCardFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    FlashCard input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$FlashCardToSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<FlashCard> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$FlashCardFromSqlite(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSqlite(
    FlashCard input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$FlashCardToSqlite(
    input,
    provider: provider,
    repository: repository,
  );
}
