// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_database.dart';

// ignore_for_file: type=lint
class $DecksTable extends Decks with TableInfo<$DecksTable, Deck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deckNameMeta =
      const VerificationMeta('deckName');
  @override
  late final GeneratedColumn<String> deckName = GeneratedColumn<String>(
      'deck_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, deckName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(Insertable<Deck> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_name')) {
      context.handle(_deckNameMeta,
          deckName.isAcceptableOrUnknown(data['deck_name']!, _deckNameMeta));
    } else if (isInserting) {
      context.missing(_deckNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deck(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deckName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_name'])!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class Deck extends DataClass implements Insertable<Deck> {
  final int id;
  final String deckName;
  const Deck({required this.id, required this.deckName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_name'] = Variable<String>(deckName);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      deckName: Value(deckName),
    );
  }

  factory Deck.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deck(
      id: serializer.fromJson<int>(json['id']),
      deckName: serializer.fromJson<String>(json['deckName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckName': serializer.toJson<String>(deckName),
    };
  }

  Deck copyWith({int? id, String? deckName}) => Deck(
        id: id ?? this.id,
        deckName: deckName ?? this.deckName,
      );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      deckName: data.deckName.present ? data.deckName.value : this.deckName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deck(')
          ..write('id: $id, ')
          ..write('deckName: $deckName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deckName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deck && other.id == this.id && other.deckName == this.deckName);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<int> id;
  final Value<String> deckName;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.deckName = const Value.absent(),
  });
  DecksCompanion.insert({
    this.id = const Value.absent(),
    required String deckName,
  }) : deckName = Value(deckName);
  static Insertable<Deck> custom({
    Expression<int>? id,
    Expression<String>? deckName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckName != null) 'deck_name': deckName,
    });
  }

  DecksCompanion copyWith({Value<int>? id, Value<String>? deckName}) {
    return DecksCompanion(
      id: id ?? this.id,
      deckName: deckName ?? this.deckName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckName.present) {
      map['deck_name'] = Variable<String>(deckName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('deckName: $deckName')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES decks (id)'));
  static const VerificationMeta _questionMeta =
      const VerificationMeta('question');
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
      'question', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
      'answer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, deckId, question, answer];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(Insertable<Flashcard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('question')) {
      context.handle(_questionMeta,
          question.isAcceptableOrUnknown(data['question']!, _questionMeta));
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(_answerMeta,
          answer.isAcceptableOrUnknown(data['answer']!, _answerMeta));
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deck_id'])!,
      question: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question'])!,
      answer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answer'])!,
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class Flashcard extends DataClass implements Insertable<Flashcard> {
  final int id;
  final int deckId;
  final String question;
  final String answer;
  const Flashcard(
      {required this.id,
      required this.deckId,
      required this.question,
      required this.answer});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['question'] = Variable<String>(question);
    map['answer'] = Variable<String>(answer);
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      question: Value(question),
      answer: Value(answer),
    );
  }

  factory Flashcard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flashcard(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      question: serializer.fromJson<String>(json['question']),
      answer: serializer.fromJson<String>(json['answer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'question': serializer.toJson<String>(question),
      'answer': serializer.toJson<String>(answer),
    };
  }

  Flashcard copyWith(
          {int? id, int? deckId, String? question, String? answer}) =>
      Flashcard(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        question: question ?? this.question,
        answer: answer ?? this.answer,
      );
  Flashcard copyWithCompanion(FlashcardsCompanion data) {
    return Flashcard(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      question: data.question.present ? data.question.value : this.question,
      answer: data.answer.present ? data.answer.value : this.answer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flashcard(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('question: $question, ')
          ..write('answer: $answer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deckId, question, answer);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flashcard &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.question == this.question &&
          other.answer == this.answer);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<String> question;
  final Value<String> answer;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.question = const Value.absent(),
    this.answer = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required String question,
    required String answer,
  })  : deckId = Value(deckId),
        question = Value(question),
        answer = Value(answer);
  static Insertable<Flashcard> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<String>? question,
    Expression<String>? answer,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (question != null) 'question': question,
      if (answer != null) 'answer': answer,
    });
  }

  FlashcardsCompanion copyWith(
      {Value<int>? id,
      Value<int>? deckId,
      Value<String>? question,
      Value<String>? answer}) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('question: $question, ')
          ..write('answer: $answer')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [decks, flashcards];
}

typedef $$DecksTableCreateCompanionBuilder = DecksCompanion Function({
  Value<int> id,
  required String deckName,
});
typedef $$DecksTableUpdateCompanionBuilder = DecksCompanion Function({
  Value<int> id,
  Value<String> deckName,
});

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
      _flashcardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.flashcards,
          aliasName: $_aliasNameGenerator(db.decks.id, db.flashcards.deckId));

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager($_db, $_db.flashcards)
        .filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckName => $composableBuilder(
      column: $table.deckName, builder: (column) => ColumnFilters(column));

  Expression<bool> flashcardsRefs(
      Expression<bool> Function($$FlashcardsTableFilterComposer f) f) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.deckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableFilterComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckName => $composableBuilder(
      column: $table.deckName, builder: (column) => ColumnOrderings(column));
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckName =>
      $composableBuilder(column: $table.deckName, builder: (column) => column);

  Expression<T> flashcardsRefs<T extends Object>(
      Expression<T> Function($$FlashcardsTableAnnotationComposer a) f) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.deckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableAnnotationComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DecksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DecksTable,
    Deck,
    $$DecksTableFilterComposer,
    $$DecksTableOrderingComposer,
    $$DecksTableAnnotationComposer,
    $$DecksTableCreateCompanionBuilder,
    $$DecksTableUpdateCompanionBuilder,
    (Deck, $$DecksTableReferences),
    Deck,
    PrefetchHooks Function({bool flashcardsRefs})> {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> deckName = const Value.absent(),
          }) =>
              DecksCompanion(
            id: id,
            deckName: deckName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String deckName,
          }) =>
              DecksCompanion.insert(
            id: id,
            deckName: deckName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DecksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({flashcardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (flashcardsRefs) db.flashcards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flashcardsRefs)
                    await $_getPrefetchedData<Deck, $DecksTable, Flashcard>(
                        currentTable: table,
                        referencedTable:
                            $$DecksTableReferences._flashcardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DecksTableReferences(db, table, p0)
                                .flashcardsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.deckId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DecksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DecksTable,
    Deck,
    $$DecksTableFilterComposer,
    $$DecksTableOrderingComposer,
    $$DecksTableAnnotationComposer,
    $$DecksTableCreateCompanionBuilder,
    $$DecksTableUpdateCompanionBuilder,
    (Deck, $$DecksTableReferences),
    Deck,
    PrefetchHooks Function({bool flashcardsRefs})>;
typedef $$FlashcardsTableCreateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  required int deckId,
  required String question,
  required String answer,
});
typedef $$FlashcardsTableUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  Value<int> deckId,
  Value<String> question,
  Value<String> answer,
});

final class $$FlashcardsTableReferences
    extends BaseReferences<_$AppDatabase, $FlashcardsTable, Flashcard> {
  $$FlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDatabase db) => db.decks
      .createAlias($_aliasNameGenerator(db.flashcards.deckId, db.decks.id));

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$DecksTableTableManager($_db, $_db.decks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answer => $composableBuilder(
      column: $table.answer, builder: (column) => ColumnFilters(column));

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.decks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DecksTableFilterComposer(
              $db: $db,
              $table: $db.decks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answer => $composableBuilder(
      column: $table.answer, builder: (column) => ColumnOrderings(column));

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.decks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DecksTableOrderingComposer(
              $db: $db,
              $table: $db.decks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.decks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DecksTableAnnotationComposer(
              $db: $db,
              $table: $db.decks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FlashcardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlashcardsTable,
    Flashcard,
    $$FlashcardsTableFilterComposer,
    $$FlashcardsTableOrderingComposer,
    $$FlashcardsTableAnnotationComposer,
    $$FlashcardsTableCreateCompanionBuilder,
    $$FlashcardsTableUpdateCompanionBuilder,
    (Flashcard, $$FlashcardsTableReferences),
    Flashcard,
    PrefetchHooks Function({bool deckId})> {
  $$FlashcardsTableTableManager(_$AppDatabase db, $FlashcardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> deckId = const Value.absent(),
            Value<String> question = const Value.absent(),
            Value<String> answer = const Value.absent(),
          }) =>
              FlashcardsCompanion(
            id: id,
            deckId: deckId,
            question: question,
            answer: answer,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int deckId,
            required String question,
            required String answer,
          }) =>
              FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            question: question,
            answer: answer,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FlashcardsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({deckId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (deckId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deckId,
                    referencedTable:
                        $$FlashcardsTableReferences._deckIdTable(db),
                    referencedColumn:
                        $$FlashcardsTableReferences._deckIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FlashcardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FlashcardsTable,
    Flashcard,
    $$FlashcardsTableFilterComposer,
    $$FlashcardsTableOrderingComposer,
    $$FlashcardsTableAnnotationComposer,
    $$FlashcardsTableCreateCompanionBuilder,
    $$FlashcardsTableUpdateCompanionBuilder,
    (Flashcard, $$FlashcardsTableReferences),
    Flashcard,
    PrefetchHooks Function({bool deckId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
}
