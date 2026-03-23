import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/statistics_viewmodel.dart';
import 'viewmodels/budget_viewmodel.dart';
import 'viewmodels/reminder_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/voice_transaction_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Load theme preferences before building the app
  final themeVM = ThemeViewModel();
  await themeVM.loadPreferences();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => StatisticsViewModel()),
        ChangeNotifierProvider(create: (_) => BudgetViewModel()),
        ChangeNotifierProvider(create: (_) => ReminderViewModel()),
        ChangeNotifierProvider.value(value: themeVM),
        ChangeNotifierProvider(create: (_) => VoiceTransactionViewModel()),
      ],
      child: const LixiTrackerApp(),
    ),
  );
}
