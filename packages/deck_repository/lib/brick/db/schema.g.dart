// GENERATED CODE DO NOT EDIT
// This file should be version controlled
import 'package:brick_sqlite/db.dart';
part '20250428205947.migration.dart';

/// All intelligently-generated migrations from all `@Migratable` classes on disk
final migrations = <Migration>{
  const Migration20250428205947(),};

/// A consumable database structure including the latest generated migration.
final schema = Schema(
  0,
  generatorVersion: 1,
  tables: <SchemaTable>{
    SchemaTable(
      '_brick_Deck_flash_cards',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn(
          'l_Deck_brick_id',
          Column.integer,
          isForeignKey: true,
          foreignTableName: 'Deck',
          onDeleteCascade: true,
          onDeleteSetDefault: false,
        ),
        SchemaColumn(
          'f_FlashCard_brick_id',
          Column.integer,
          isForeignKey: true,
          foreignTableName: 'FlashCard',
          onDeleteCascade: true,
          onDeleteSetDefault: false,
        ),
      },
      indices: <SchemaIndex>{
        SchemaIndex(
          columns: ['l_Deck_brick_id', 'f_FlashCard_brick_id'],
          unique: true,
        ),
      },
    ),
    SchemaTable(
      'Deck',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('id', Column.varchar, unique: true),
        SchemaColumn('deck_name', Column.varchar),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['id'], unique: true),
      },
    ),
    SchemaTable(
      'FlashCard',
      columns: <SchemaColumn>{
        SchemaColumn(
          '_brick_id',
          Column.integer,
          autoincrement: true,
          nullable: false,
          isPrimaryKey: true,
        ),
        SchemaColumn('id', Column.varchar, unique: true),
        SchemaColumn('question', Column.varchar),
        SchemaColumn('answer', Column.varchar),
      },
      indices: <SchemaIndex>{
        SchemaIndex(columns: ['id'], unique: true),
      },
    ),
  },
);
