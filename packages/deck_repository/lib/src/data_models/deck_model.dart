import 'package:deck_repository/deck_repository.dart';

class DeckModel {
  int id;

  String deckName;

  List<FlashCardModel> flashCards;

  DeckModel({required this.id, required this.deckName, required this.flashCards});
}
