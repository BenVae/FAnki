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
    context.read<DeckBloc>().add(InitDeckEvent(deckName: deckName));
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
      body: BlocConsumer<CardDeckBloc, CardDeckState>(
        listenWhen: (previous, current) =>
            previous.deckName != current.deckName,
        listener: (context, state) =>
            _deckNameController.text = state.deck?.deckName ?? '',
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _deckNameController,
                  onChanged: (deckName) => context
                      .read<DeckBloc>()
                      .add(DeckNameChanged(deckName: deckName)),
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
                            onPressed: context
                                    .read<DeckBloc>()
                                    .state
                                    .newDeckNameIsValid
                                ? () => context.read<CardDeckBloc>().add(
                                    RenameDeck(
                                        deckName: _deckNameController.text))
                                : null,
                          ),
                          IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () {
                                context
                                    .read<DeckBloc>()
                                    .add(DeckNameChanged(deckName: ''));
                                _deckNameController.text = '';
                              }),
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
                  child: (state.isLoading || state.deck == null)
                      ? const Center(child: CircularProgressIndicator())
                      : state.deck!.flashCards.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('There are no cards for this deck yet.'),
                                  _addDeleteDeckButton(state.deck?.deckName),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.deck!.flashCards.length + 1,
                              itemBuilder: (context, index) {
                                if (state.deck!.flashCards.length > index) {
                                  return GestureDetector(
                                    onTap: () {
                                      context.read<CardDeckBloc>().add(
                                            SetFlashCardForEditingOrCreating(
                                              cardId: state
                                                  .deck!.flashCards[index].id,
                                            ),
                                          );
                                      return context.go(
                                          '/HomeTabView/DeckPage/CreateCardPage');
                                    },
                                    child: FlashCard(
                                      id: index,
                                      question: state
                                          .deck!.flashCards[index].question,
                                      answer:
                                          state.deck!.flashCards[index].answer,
                                    ),
                                  );
                                } else if (state.deck!.flashCards.length ==
                                    index) {
                                  return _addDeleteDeckButton(
                                      state.deck!.deckName);
                                } else {
                                  return Text('Error: Should never come here.');
                                }
                              },
                            ),
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                _addNewCardButton(),
                const SizedBox(height: 30.0),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _addNewCardButton() {
    return ElevatedButton(
      onPressed: () {
        context.read<CardDeckBloc>().add(SetFlashCardForEditingOrCreating());
        context.go('/HomeTabView/DeckPage/CreateCardPage');
      },
      child: const Text('Create card'),
    );
  }

  Widget _addDeleteDeckButton(String? deckName) {
    if (deckName == null) {
      return const Text('Error: DeckName not found.');
    }

    return Column(
      children: [
        const Divider(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            final bool? confirmDelete = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                    'Are you sure you want to delete the deck?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );

            if (confirmDelete == true && mounted) {
              context.go('/HomeTabView');
              context
                  .read<CardDeckBloc>()
                  .add(DeleteDeckEvent(deckName: deckName));
            }
          },
          child: const Text('Delete Deck'),
        ),
      ],
    );
  }
}
