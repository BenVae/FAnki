import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:card_repository/card_deck_manager.dart';

class CreateCardsCubit extends Cubit<CreateCardsState> {
  // ignore: unused_field
  final AuthenticationRepository _repo;
  final CardDeckManager cdm;
  String deckName = '';
  List<SingleCard> cards = [];

  CreateCardsCubit(
      {required AuthenticationRepository repo,
      required CardDeckManager cardDeckManager})
      : _repo = repo,
        cdm = cardDeckManager,
        super(CreateCardLoadingState()) {
    _initializeCardDeckManager();
  }

  Future<void> _initializeCardDeckManager() async {
    // Debug: Check current state
    print('CreateCardsCubit: Current CDM userID: "${cdm.userID}"');
    print('CreateCardsCubit: Current CDM currentDeckName: "${cdm.currentDeckName}"');
    
    // Ensure CardDeckManager has the current user ID
    final currentUser = _repo.currentUser;
    print('CreateCardsCubit: Auth user email: "${currentUser.email}"');
    
    if (currentUser.email != null && currentUser.email!.isNotEmpty) {
      cdm.setUserID(currentUser.email!);
      print('CreateCardsCubit: Set userID to: "${cdm.userID}"');
      
      // Wait a bit for the deck to be properly initialized
      await Future.delayed(Duration(milliseconds: 100));
      
      // Get current deck name, ensuring it's set
      deckName = await cdm.getCurrentDeck();
      print('CreateCardsCubit: Current deck after getCurrentDeck(): "$deckName"');
      
      if (deckName.isEmpty) {
        // If no current deck, wait a bit more and try again
        await Future.delayed(Duration(milliseconds: 200));
        deckName = cdm.currentDeckName;
        print('CreateCardsCubit: Current deck after retry: "$deckName"');
      }
      
      loadCardsOfDeck();
    } else {
      print('CreateCardsCubit: No valid user email found');
      emit(CreateCardEmptyState());
    }
  }

  Future<void> addCard(String question, String answer) async {
    print('CreateCardsCubit: Adding card - userID: "${cdm.userID}", currentDeckName: "${cdm.currentDeckName}"');
    cdm.addCardWithQA(question, answer);
    cards = await cdm.getCurrentDeckCards();
    emit(CreateCardViewingState(deckName: deckName, cards: cards));
  }

  Future<void> removeCard(String cardID) async {
    cdm.removeCardByID(cardID);
    cards = await cdm.getCurrentDeckCards();
    if (cards.isEmpty) {
      emit(CreateCardEmptyState());
    } else {
      emit(CreateCardViewingState(deckName: deckName, cards: cards));
    }
  }

  void loadCardsOfDeck() async {
    emit(CreateCardLoadingState());
    cards = await cdm.getCurrentDeckCards();
    if (cards.isEmpty) {
      emit(CreateCardEmptyState());
    } else {
      deckName = cdm.currentDeckName;
      emit(CreateCardViewingState(deckName: deckName, cards: cards));
    }
  }

  void checkAndReloadDeck() {
    if (deckName != cdm.currentDeckName) {
      deckName = cdm.currentDeckName;
      loadCardsOfDeck();
    } else if (cards.isEmpty) {
      loadCardsOfDeck();
    }
  }
}

abstract class CreateCardsState {}

class CreateCardLoadingState extends CreateCardsState {}

class CreateCardViewingState extends CreateCardsState {
  final String _deckName;
  final List<SingleCard> _cards;

  String get deckName => _deckName;
  List<SingleCard> get cards => _cards;

  CreateCardViewingState(
      {required String deckName, required List<SingleCard> cards})
      : _deckName = deckName,
        _cards = cards;
}

class CreateCardEmptyState extends CreateCardsState {}
