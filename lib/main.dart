import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/orientation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockLandscape();
  runApp(const App());
}
