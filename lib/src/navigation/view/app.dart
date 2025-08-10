import 'dart:ui';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:card_repository/card_deck_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/view/settings_view.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/view/learning_page.dart';
import '../../login/cubit/login_cubit.dart';
import '../../login/cubit/login_cubit_v2.dart';
import '../../login/view/login_page.dart';
import '../../manage_decks/cubit/manage_decks_cubit.dart';
import '../../manage_decks/cubit/manage_decks_cubit_v2.dart';
import '../../manage_decks/view/manage_decks_view_v2.dart';
import '../../study_stats/view/study_stats_page.dart';
import '../../widgets/frosted_navigation.dart';
import '../cubit/navigation_cubit.dart';

class KarteiApp extends StatefulWidget {
  const KarteiApp({
    super.key,
    required this.authenticationRepository,
    required this.cardDeckManager,
    required this.deckTreeManager,
  });

  final AuthenticationRepository authenticationRepository;
  final CardDeckManager cardDeckManager;
  final DeckTreeManager deckTreeManager;

  @override
  State<KarteiApp> createState() => _KarteiAppState();
}

class _KarteiAppState extends State<KarteiApp> {

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: widget.authenticationRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoginCubit(
                widget.authenticationRepository, widget.cardDeckManager),
          ),
        BlocProvider(
          create: (context) => LoginCubitV2(
              widget.authenticationRepository, 
              widget.cardDeckManager,
              widget.deckTreeManager),
        ),
        BlocProvider(
          create: (context) => NavigationCubit(),
        ),
        BlocProvider(
          create: (context) => LearningCubit(
              widget.authenticationRepository, widget.cardDeckManager),
        ),
        BlocProvider(
          create: (context) => ManageDecksCubit(
            cardDeckManager: widget.cardDeckManager,
          ),
        ),
        BlocProvider(
          create: (context) => ManageDecksCubitV2(
            deckTreeManager: widget.deckTreeManager,
            cardDeckManager: widget.cardDeckManager,
          ),
        ),
      ],
      child: MaterialApp(
        home: StreamBuilder<User>(
          stream: widget.authenticationRepository.user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (!snapshot.hasData || snapshot.data == User.empty) {
              return Scaffold(
                body: Center(child: LoginPage()),
              );
            } else {
              return BlocBuilder<NavigationCubit, NavigationState>(
                builder: (context, state) {
                  final isLearning = state == NavigationState.learning;
                  
                  return Scaffold(
                    body: Stack(
                      children: [
                        _getPage(state),
                        if (!isLearning)
                          FrostedNavigationButtons(
                            selectedIndex: _determineSelectedIndex(state),
                            onNavigate: (index) => _onDestinationSelected(context, index),
                          ),
                        if (isLearning)
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 16,
                            right: MediaQuery.of(context).padding.right + 16,
                            child: _FrostedBackButton(
                              onPressed: () => context.read<NavigationCubit>().goBack(),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      ),
    );
  }

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == 0) {
      context.read<NavigationCubit>().goToDecks();
    } else if (index == 1) {
      context.read<NavigationCubit>().goToStats();
    } else if (index == 2) {
      context.read<NavigationCubit>().goToSettings();
    } else {
      throw UnimplementedError();
    }
  }

  int _determineSelectedIndex(NavigationState state) {
    switch (state) {
      case NavigationState.decks:
        return 0;
      case NavigationState.stats:
        return 1;
      case NavigationState.settings:
        return 2;
      case NavigationState.learning:
        return -1; // Not in navigation bar
    }
  }

  Widget _getPage(NavigationState state) {
    switch (state) {
      case NavigationState.learning:
        return LearningPage();
      case NavigationState.decks:
        return ManageDecksViewV2();
      case NavigationState.stats:
        return StudyStatsPage();
      case NavigationState.settings:
        return SettingsView();
    }
  }
}

class _FrostedBackButton extends StatelessWidget {
  const _FrostedBackButton({required this.onPressed});
  
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.close,
                  size: 22,
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
