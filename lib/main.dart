import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/filter/filter_bloc.dart';
// ReportBloc removed: reports feature disabled
import 'blocs/category/category_bloc.dart';
import 'blocs/category/category_event.dart';

import 'pages/home_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/transactions/transactions_page.dart';
import 'pages/transactions/transaction_form_page.dart';
import 'pages/categories/categories_page.dart';
import 'pages/categories/category_form_page.dart';
import 'pages/filters/filters_page.dart';
// scheduled transactions page removed

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        /// ⚠️ CATEGORIAS – deve vir antes dos outros para ser lido sem erro
        BlocProvider(create: (_) => CategoryBloc()..add(LoadCategories())),

        /// FILTROS (deve existir antes do TransactionBloc para injeção)
        BlocProvider(create: (_) => FilterBloc()),

        /// TRANSAÇÕES
        BlocProvider(
          create: (context) =>
              TransactionBloc(filterBloc: context.read<FilterBloc>()),
        ),

        // TRANSAÇÕES FUTURAS (removidas)

        // Reports removed
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dashboard Financeiro',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: const Color(0xFFF6F7FB),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent,
          ),
          // Removido cardTheme incompatível (erro do analyzer). Podemos ajustar depois se API exigir CardThemeData.
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 14, height: 1.35),
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/dashboard': (context) => const DashboardPage(),
          '/transactions': (context) => const TransactionsPage(),
          '/transaction_form': (context) => const TransactionFormPage(),
          '/categories': (context) => const CategoriesPage(),
          '/category_form': (context) => const CategoryFormPage(),
          '/filters': (context) => const FiltersPage(),
        },
      ),
    );
  }
}
