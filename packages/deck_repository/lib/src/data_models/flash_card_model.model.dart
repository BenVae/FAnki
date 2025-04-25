import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:uuid/uuid.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'flash_cards'),
)
class FlashCard extends OfflineFirstWithSupabaseModel {
  /// A collision-proof, universally unique identifier
  /// (generated client-side when not provided).
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  final String question;
  final String answer;

  FlashCard({
    String? id,
    required this.question,
    required this.answer,
  }) : id = id ?? const Uuid().v4();
}
