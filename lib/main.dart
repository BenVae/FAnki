import 'package:authentication_repository/authentication_repository.dart';
import 'package:deck_repository/deck_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanki/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'router.dart';
import 'package:path_provider/path_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: non_constant_identifier_names
final NEXT_PUBLIC_SUPABASE_URL = 'https://nboagoifuwsecqjhxrop.supabase.co';
// ignore: non_constant_identifier_names
final NEXT_PUBLIC_SUPABASE_ANON_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ib2Fnb2lmdXdzZWNxamh4cm9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk3MTgzNzEsImV4cCI6MjA1NTI5NDM3MX0.fhfasszFIKAnFExFqkjgXj5G5FxRVB3duAaymzWY_QM';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Supabase supabase = await Supabase.initialize(
    url: NEXT_PUBLIC_SUPABASE_URL,
    anonKey: NEXT_PUBLIC_SUPABASE_ANON_KEY,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb ? HydratedStorageDirectory.web : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  final authenticationRepository = AuthenticationRepository();
  final deckRepository = await DeckRepository.init(supabase.client);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>.value(value: authenticationRepository),
        RepositoryProvider<DeckRepository>.value(value: deckRepository),
      ],
      child: FankiApp(router: router),
    ),
  );
}
