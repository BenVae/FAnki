// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<Deck> _$DeckFromSupabase(
  Map<String, dynamic> data, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Deck(
    id: data['id'] as String?,
    deckName: data['deck_name'] as String,
    flashCards: await Future.wait<FlashCard>(
      data['flash_cards']
              ?.map(
                (d) => FlashCardAdapter().fromSupabase(
                  d,
                  provider: provider,
                  repository: repository,
                ),
              )
              .toList()
              .cast<Future<FlashCard>>() ??
          [],
    ),
  );
}

Future<Map<String, dynamic>> _$DeckToSupabase(
  Deck instance, {
  required SupabaseProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {
    'id': instance.id,
    'deck_name': instance.deckName,
    'flash_cards': await Future.wait<Map<String, dynamic>>(
      instance.flashCards
          .map(
            (s) => FlashCardAdapter().toSupabase(
              s,
              provider: provider,
              repository: repository,
            ),
          )
          .toList(),
    ),
  };
}

Future<Deck> _$DeckFromSqlite(
  Map<String, dynamic> data, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return Deck(
    id: data['id'] as String,
    deckName: data['deck_name'] as String,
    flashCards:
        (await provider
            .rawQuery(
              'SELECT DISTINCT `f_FlashCard_brick_id` FROM `_brick_Deck_flash_cards` WHERE l_Deck_brick_id = ?',
              [data['_brick_id'] as int],
            )
            .then((results) {
              final ids = results.map((r) => r['f_FlashCard_brick_id']);
              return Future.wait<FlashCard>(
                ids.map(
                  (primaryKey) => repository!
                      .getAssociation<FlashCard>(
                        Query.where('primaryKey', primaryKey, limit1: true),
                      )
                      .then((r) => r!.first),
                ),
              );
            })).toList().cast<FlashCard>(),
  )..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$DeckToSqlite(
  Deck instance, {
  required SqliteProvider provider,
  OfflineFirstWithSupabaseRepository? repository,
}) async {
  return {'id': instance.id, 'deck_name': instance.deckName};
}

/// Construct a [Deck]
class DeckAdapter extends OfflineFirstWithSupabaseAdapter<Deck> {
  DeckAdapter();

  @override
  final supabaseTableName = 'decks';
  @override
  final defaultToNull = true;
  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'deckName': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'deck_name',
    ),
    'flashCards': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'flash_cards',
      associationType: FlashCard,
      associationIsNullable: false,
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
    'deckName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'deck_name',
      iterable: false,
      type: String,
    ),
    'flashCards': const RuntimeSqliteColumnDefinition(
      association: true,
      columnName: 'flash_cards',
      iterable: true,
      type: FlashCard,
    ),
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
    Deck instance,
    DatabaseExecutor executor,
  ) async {
    final results = await executor.rawQuery(
      '''
        SELECT * FROM `Deck` WHERE id = ? LIMIT 1''',
      [instance.id],
    );

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'Deck';
  @override
  Future<void> afterSave(instance, {required provider, repository}) async {
    if (instance.primaryKey != null) {
      final flashCardsOldColumns = await provider.rawQuery(
        'SELECT `f_FlashCard_brick_id` FROM `_brick_Deck_flash_cards` WHERE `l_Deck_brick_id` = ?',
        [instance.primaryKey],
      );
      final flashCardsOldIds = flashCardsOldColumns.map(
        (a) => a['f_FlashCard_brick_id'],
      );
      final flashCardsNewIds =
          instance.flashCards.map((s) => s.primaryKey).whereType<int>();
      final flashCardsIdsToDelete = flashCardsOldIds.where(
        (id) => !flashCardsNewIds.contains(id),
      );

      await Future.wait<void>(
        flashCardsIdsToDelete.map((id) async {
          return await provider
              .rawExecute(
                'DELETE FROM `_brick_Deck_flash_cards` WHERE `l_Deck_brick_id` = ? AND `f_FlashCard_brick_id` = ?',
                [instance.primaryKey, id],
              )
              .catchError((e) => null);
        }),
      );

      await Future.wait<int?>(
        instance.flashCards.map((s) async {
          final id =
              s.primaryKey ??
              await provider.upsert<FlashCard>(s, repository: repository);
          return await provider.rawInsert(
            'INSERT OR IGNORE INTO `_brick_Deck_flash_cards` (`l_Deck_brick_id`, `f_FlashCard_brick_id`) VALUES (?, ?)',
            [instance.primaryKey, id],
          );
        }),
      );
    }
  }

  @override
  Future<Deck> fromSupabase(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async => await _$DeckFromSupabase(
    input,
    provider: provider,
    repository: repository,
  );
  @override
  Future<Map<String, dynamic>> toSupabase(
    Deck input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$DeckToSupabase(input, provider: provider, repository: repository);
  @override
  Future<Deck> fromSqlite(
    Map<String, dynamic> input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$DeckFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(
    Deck input, {
    required provider,
    covariant OfflineFirstWithSupabaseRepository? repository,
  }) async =>
      await _$DeckToSqlite(input, provider: provider, repository: repository);
}
