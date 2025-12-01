import 'package:dashboard_financeiro/blocs/category/category_event.dart';
import 'package:dashboard_financeiro/blocs/transaction/transaction_event.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/filter/filter_bloc.dart';
import 'pages/dashboard_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FilterBloc()),
        BlocProvider(
          create: (_) => CategoryBloc()..add(const LoadCategories()),
        ),
        BlocProvider(
          create: (context) =>
              TransactionBloc(filterBloc: context.read<FilterBloc>())
                ..add(const LoadTransactions()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const DashboardPage(),
      ),
    );
  }
}
