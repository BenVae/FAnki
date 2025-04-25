import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:deck_repository/src/data_models/flash_card_model.model.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'decks'),
)
class Deck extends OfflineFirstWithSupabaseModel {
  /// Collision-proof primary key (generated client-side if not supplied).
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  final String deckName;

  /// One-to-many relationship: a deck can hold multiple flash cards.
  final List<FlashCard> flashCards;

  Deck({
    String? id,
    required this.deckName,
    this.flashCards = const [],
  }) : id = id ?? const Uuid().v4();
}
