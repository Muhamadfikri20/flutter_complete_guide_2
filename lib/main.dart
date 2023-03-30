import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_complete_guide_2/widgets/chart.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './models/transaction.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      home: MyHomePage(),
      theme: ThemeData(
          primarySwatch: Colors.purple,
          errorColor: Colors.red,
          accentColor: Colors.amber,
          fontFamily: 'Quicksand',
          textTheme:
              ThemeData.light().textTheme.copyWith(headline6: TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.bold, fontSize: 18), button: TextStyle(color: Colors.white)),
          appBarTheme: AppBarTheme(textTheme: ThemeData.light().textTheme.copyWith(headline6: TextStyle(fontFamily: 'OpenSans', fontSize: 20, fontWeight: FontWeight.bold)))),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [
    // Transaction(id: 't1', title: 'New Shoes', amount: 69.99, date: DateTime.now()),
    // Transaction(id: 't2', title: 'Weekly Groceries', amount: 69.53, date: DateTime.now())
  ];
  bool _showChart = false;
  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void _addNewTransaction(String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(title: txTitle, amount: txAmount, date: chosenDate, id: DateTime.now().toString());
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: NewTransaction(_addNewTransaction),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(MediaQueryData mediaQuery, double appBar, Widget txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.headline6,
          ),
          Switch.adaptive(
              activeColor: Theme.of(context).accentColor,
              value: _showChart,
              onChanged: (val) {
                setState(() {
                  _showChart = val;
                });
              }),
          _showChart
              ? Container(
                  height: (mediaQuery.size.height - appBar - mediaQuery.padding.top) * 0.7,
                  child: Chart(_recentTransactions),
                )
              : txListWidget
        ],
      ),
    ];
  }

  List<Widget> _buildPotraitContent(MediaQueryData mediaQuery, double appBar, Widget txListWidget) {
    return [Container(height: (mediaQuery.size.height - appBar - mediaQuery.padding.top) * 0.3, child: Chart(_recentTransactions)), txListWidget];
  }

  Widget _buildCupertinoAppBar(PreferredSizeWidget appBar, final pageBody) {
    return CupertinoPageScaffold(
      navigationBar: appBar,
      child: pageBody,
    );
  }

  Widget _buildScaffoldAppBar(PreferredSizeWidget appBar, final pageBody) {
    return Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _startAddNewTransaction(context),
            ),
    );
  }

  Widget _buildAppBar() {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Personal Expenses',
            ),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                child: Icon(CupertinoIcons.add),
                onTap: () => _startAddNewTransaction(context),
              )
            ]),
          )
        : AppBar(
            title: Text(
              'Personal Expenses',
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              )
            ],
          );
  }

  // String titleInput;
  @override
  Widget build(BuildContext context) {
    print('build() MyHomePageState');
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = _buildAppBar();
    final txListWidget =
        Container(height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) * 0.7, child: TransactionList(_userTransactions, _deleteTransaction));

    print(appBar.preferredSize.height);
    final pageBody = SafeArea(
        child: SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLandscape) ..._buildLandscapeContent(mediaQuery, appBar.preferredSize.height, txListWidget),
          if (!isLandscape) ..._buildPotraitContent(mediaQuery, appBar.preferredSize.height, txListWidget),
        ],
      ),
    ));
    return Platform.isIOS ? _buildCupertinoAppBar(appBar, pageBody) : _buildScaffoldAppBar(appBar, pageBody);
  }
}
