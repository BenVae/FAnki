// GENERATED CODE EDIT WITH CAUTION
// THIS FILE **WILL NOT** BE REGENERATED
// This file should be version controlled and can be manually edited.
part of 'schema.g.dart';

// While migrations are intelligently created, the difference between some commands, such as
// DropTable vs. RenameTable, cannot be determined. For this reason, please review migrations after
// they are created to ensure the correct inference was made.

// The migration version must **always** mirror the file name

const List<MigrationCommand> _migration_20250428205947_up = [
  InsertTable('_brick_Deck_flash_cards'),
  InsertTable('Deck'),
  InsertTable('FlashCard'),
  InsertForeignKey('_brick_Deck_flash_cards', 'Deck', foreignKeyColumn: 'l_Deck_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertForeignKey('_brick_Deck_flash_cards', 'FlashCard', foreignKeyColumn: 'f_FlashCard_brick_id', onDeleteCascade: true, onDeleteSetDefault: false),
  InsertColumn('id', Column.varchar, onTable: 'Deck', unique: true),
  InsertColumn('deck_name', Column.varchar, onTable: 'Deck'),
  InsertColumn('id', Column.varchar, onTable: 'FlashCard', unique: true),
  InsertColumn('question', Column.varchar, onTable: 'FlashCard'),
  InsertColumn('answer', Column.varchar, onTable: 'FlashCard'),
  CreateIndex(columns: ['l_Deck_brick_id', 'f_FlashCard_brick_id'], onTable: '_brick_Deck_flash_cards', unique: true),
  CreateIndex(columns: ['id'], onTable: 'Deck', unique: true),
  CreateIndex(columns: ['id'], onTable: 'FlashCard', unique: true)
];

const List<MigrationCommand> _migration_20250428205947_down = [
  DropTable('_brick_Deck_flash_cards'),
  DropTable('Deck'),
  DropTable('FlashCard'),
  DropColumn('l_Deck_brick_id', onTable: '_brick_Deck_flash_cards'),
  DropColumn('f_FlashCard_brick_id', onTable: '_brick_Deck_flash_cards'),
  DropColumn('id', onTable: 'Deck'),
  DropColumn('deck_name', onTable: 'Deck'),
  DropColumn('id', onTable: 'FlashCard'),
  DropColumn('question', onTable: 'FlashCard'),
  DropColumn('answer', onTable: 'FlashCard'),
  DropIndex('index__brick_Deck_flash_cards_on_l_Deck_brick_id_f_FlashCard_brick_id'),
  DropIndex('index_Deck_on_id'),
  DropIndex('index_FlashCard_on_id')
];

//
// DO NOT EDIT BELOW THIS LINE
//

@Migratable(
  version: '20250428205947',
  up: _migration_20250428205947_up,
  down: _migration_20250428205947_down,
)
class Migration20250428205947 extends Migration {
  const Migration20250428205947()
    : super(
        version: 20250428205947,
        up: _migration_20250428205947_up,
        down: _migration_20250428205947_down,
      );
}
