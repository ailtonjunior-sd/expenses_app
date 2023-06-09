import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:expenses/models/transaction.dart';
import 'package:expenses/components/transaction_list.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:expenses/components/chart.dart';

main() => runApp(const ExpensesApp());

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = ThemeData();

    return MaterialApp(
        home: const MyHomePage(),
        theme: tema.copyWith(
            colorScheme: tema.colorScheme.copyWith(
              primary: Colors.purple,
              secondary: Colors.amber,
            ),
            textTheme: tema.textTheme.copyWith(
                titleLarge: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
                bodySmall: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            appBarTheme: const AppBarTheme(
                titleTextStyle: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold))));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) {
        return tr.id == id;
      });
    });
  }

  _openTransactionFormModal(context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool isLandiscape = mediaQuery.orientation == Orientation.landscape;

    final appBar = AppBar(
      title: const Text('Despesas Pessoais'),
      actions: <Widget>[
        if (isLandiscape)
          IconButton(
            icon: Icon(_showChart ? Icons.list : Icons.show_chart),
            onPressed: () => {
              setState(() {
                _showChart = !_showChart;
              })
            },
          ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _openTransactionFormModal(context),
        ),
      ],
    );
    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_showChart || !isLandiscape)
              SizedBox(
                height: availableHeight * (isLandiscape ? 0.8 : 0.25),
                child: Chart(_recentTransactions),
              ),
            if (!_showChart || !isLandiscape)
              SizedBox(
                height: availableHeight * 1,
                child: TransactionList(_transactions, _removeTransaction),
              ),
          ],
        ),
      ),
      floatingActionButton: Platform.isIOS
          ? const SizedBox()
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _openTransactionFormModal(context),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
