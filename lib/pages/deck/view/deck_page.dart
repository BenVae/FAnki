import 'package:fanki/blocs/card_deck/bloc/card_deck_bloc.dart';
import 'package:fanki/pages/deck/bloc/deck_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/flashcard.dart';

class DeckPage extends StatefulWidget {
  const DeckPage({super.key});

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  late final TextEditingController _deckNameController;

  @override
  void initState() {
    super.initState();
    String deckName = context.read<CardDeckBloc>().state.deckName ?? '';
    context.read<DeckBloc>().add(DeckNameChanged(deckName: deckName));
    _deckNameController = TextEditingController(text: deckName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cards'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: BlocListener<DeckBloc, DeckState>(
        listenWhen: (previous, current) {
          bool foo = previous.newDeckName != current.newDeckName;
          return foo;
        },
        listener: (context, state) {
          _deckNameController.text = state.newDeckName;
        },
        child: BlocBuilder<CardDeckBloc, CardDeckState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _deckNameController,
                    onChanged: (deckName) => context.read<DeckBloc>().add(DeckNameChanged(deckName: deckName)),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: context.read<DeckBloc>().state.newDeckNameIsValid
                                  ? () =>
                                      context.read<CardDeckBloc>().add(RenameDeck(deckName: _deckNameController.text))
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () => context.read<DeckBloc>().add(DeckNameChanged(deckName: '')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '${state.deck?.flashCards.length ?? '_'} cards',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state.deck!.flashCards.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('There are no cards for this deck yet.'),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.deck!.flashCards.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      context.read<CardDeckBloc>().add(
                                            SetFlashCardForEditingOrCreating(
                                              cardId: state.deck!.flashCards[index].id,
                                            ),
                                          );
                                      return context.go('/HomeTabView/DeckPage/CreateCardPage');
                                    },
                                    child: FlashCard(
                                      id: index,
                                      question: state.deck!.flashCards[index].question,
                                      answer: state.deck!.flashCards[index].answer,
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 16.0),
                  _addNewCardButton(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _addNewCardButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<CardDeckBloc>().add(SetFlashCardForEditingOrCreating());
        context.go('/HomeTabView/DeckPage/CreateCardPage');
      },
      child: const Text('Create card'),
    );
  }
}
