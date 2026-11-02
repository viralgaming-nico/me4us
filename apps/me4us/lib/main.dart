import 'package:core_auth/core_auth.dart';
import 'package:core_union/core_union.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
  final client = Supabase.instance.client;
  runApp(Me4UsApp(
    auth: SupabaseAuthRepository(client),
    unions: SupabaseUnionRepository(client),
  ));
}
