import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:card_repository/card_deck_manager.dart';
import '../cubit/ai_import_cubit.dart';
import 'ai_import_view.dart';
import '../../create_cards/cubit/create_cards_cubit.dart';

class AiImportPage extends StatelessWidget {
  final CardDeckManager? cardDeckManager;
  
  const AiImportPage({super.key, this.cardDeckManager});

  @override
  Widget build(BuildContext context) {
    // Get cardDeckManager from parameter or CreateCardsCubit
    final cdm = cardDeckManager ?? context.read<CreateCardsCubit>().cdm;

    return BlocProvider(
      create: (context) => AiImportCubit(
        cardDeckManager: cdm,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('AI Card Generation'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: AiImportView(),
      ),
    );
  }
}
