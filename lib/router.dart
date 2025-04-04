import 'package:authentication_repository/authentication_repository.dart';
import 'package:deck_repository/deck_repository.dart';
import 'package:fanki/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:fanki/pages/learning/learning.dart';
import 'package:fanki/pages/sign_up/view/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'pages/card/card.dart';
import 'pages/deck/deck.dart';
import 'pages/home_tab_view/view.dart';
import 'pages/login/login.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

final String routeLoginPage = '/LoginPage';
final String routeDeckPage = '/DeckPage';
final String routeHomeTabView = '/HomeTabView';

final String routeCreateCardPage = '/DeckPage/CreateCardPage';
final String routeSignUpPage = '/SignUpPage';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'LoginPage',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          path: 'SignUpPage',
          builder: (BuildContext context, GoRouterState state) {
            return const SignUpPage();
          },
        ),
        GoRoute(
          path: 'HomeTabView',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeTabView();
          },
        ),
        GoRoute(
          path: 'LearningPage',
          builder: (BuildContext context, GoRouterState state) {
            return BlocProvider(
              create: (context) => LearningBloc(
                deckRepository: context.read<DeckRepository>(),
              ),
              child: LearningPage(),
            );
          },
        ),
        GoRoute(
          path: 'DeckPage',
          builder: (BuildContext context, GoRouterState state) {
            return BlocProvider(
              create: (context) {
                return DeckBloc(
                  deckRepository: context.read<DeckRepository>(),
                );
              },
              child: DeckPage(),
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'CreateCardPage',
              builder: (BuildContext context, GoRouterState state) {
                return BlocProvider(
                  create: (context) {
                    return CardBloc(
                      deckRepository: context.read<DeckRepository>(),
                    );
                  },
                  child: CardPage(),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (context, state) async {
    final status = context.read<AuthenticationBloc>().state.status;
    switch (status) {
      case AuthenticationStatus.authenticated:
        final currentPath = state.fullPath;
        if (currentPath == routeLoginPage || currentPath == '/') {
          return routeHomeTabView;
        }
        return null;
      case AuthenticationStatus.unauthenticated || AuthenticationStatus.unknown:
        if (state.fullPath == routeSignUpPage) {
          return routeSignUpPage;
        }
        return routeLoginPage;
    }
  },
);
