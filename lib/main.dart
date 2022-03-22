import 'package:flutter/material.dart';
import 'package:flutter_application_1/currencies.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Convert'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> results = [];

  final controller = TextEditingController();
  final usdController = TextEditingController();
  var usdAmount;

  void _updateCurrencyValues() {
    setState(() {
      usdAmount = double.parse(usdController.text);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    controller.dispose();
    usdController.dispose();
    super.dispose();
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CurrencySelector()),
    );

    setState(() {});

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (!results.contains(result)) {
      results.add(result);
    }
    // results.add(result);
    print(results);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$result')));

    // selectedCurrencies.add('$result');

    // print(selectedCurrencies);
  }

  Future<Map<String, dynamic>> downloadData() async {
    var url = Uri.parse(
        'https://openexchangerates.org/api/latest.json?app_id=239acfbc66184e11a1cbee16cccca9f8');
    var response = await http.get(url);
    var result;
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      result = jsonResponse['rates'];
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return Future.value(result);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: downloadData(), // function where you call your api
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    'Loading...',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            return Scaffold(
              appBar: AppBar(
                title: Center(child: Text(widget.title)),
              ),
              body: Center(
                child: Column(
                  children: <Widget>[
                    Card(
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('icons/flags/png/us.png',
                              package: 'country_icons'),
                        ),
                        title: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('USD'),
                            ),
                          ],
                        ),
                        subtitle: Text('United States Dollar'),
                        trailing: SizedBox(
                          width: 150,
                          child: TextField(
                            onEditingComplete: () {
                              _updateCurrencyValues();
                            },
                            controller: usdController,
                            obscureText: false,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.calculate_rounded),
                              border: OutlineInputBorder(),
                              labelText: 'Amount',
                            ),
                          ),
                        ),
                        isThreeLine: false,
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final currency = results[index];

                            return ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.asset('icons/flags/png/us.png',
                                    package: 'country_icons'),
                              ),
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(currency),
                                  ),
                                ],
                              ),
                              subtitle: Text('United States Dollar\n' +
                                  '1 ' +
                                  currency +
                                  ' = ' +
                                  snapshot.data![currency].toString() +
                                  ' USD'),
                              trailing: Text(
                                  (double.tryParse(usdController.text) == null
                                          ? 0
                                          : double.tryParse(
                                                  usdController.text)! *
                                              snapshot.data![currency])
                                      .toStringAsFixed(2)),
                              isThreeLine: true,
                            );
                          }),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      onPressed: () {
                        _navigateAndDisplaySelection(context);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const CurrencySelector()),
                        // );
                      },
                      child: Text('Add Currency'),
                    ),
                  ],
                ),
              ),
            ); // snapshot.data  :- get your object which is pass from your downloadData() function
        }
      },
    );
  }
}

class CurrencySelector extends StatefulWidget {
  const CurrencySelector({Key? key}) : super(key: key);

  @override
  _CurrencySelectorState createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  List<Currency> currencies = allCurrencies;

  final controller = TextEditingController();

  void searchCurrency(String query) {
    final suggestions = allCurrencies.where((currency) {
      final currencyName = currency.currencyName.toLowerCase();
      final input = query.toLowerCase();
      return currencyName.contains(input);
    }).toList();

    setState(() => currencies = suggestions);
  }

  Future<Map<String, dynamic>> downloadData() async {
    var url = Uri.parse(
        'https://openexchangerates.org/api/latest.json?app_id=239acfbc66184e11a1cbee16cccca9f8');
    var response = await http.get(url);
    var result;
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      result = jsonResponse['rates'];
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return Future.value(result);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: downloadData(), // function where you call your api
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    'Loading...',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else
            return Scaffold(
              appBar: AppBar(
                title: const Text('Second Route'),
              ),
              body: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                      child: TextField(
                        controller: controller,
                        obscureText: false,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          labelText: 'Search',
                        ),
                        onChanged: searchCurrency,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: currencies.length,
                          itemBuilder: (context, index) {
                            final currency = currencies[index];

                            return ListTile(
                              onTap: () {
                                Navigator.pop(context,
                                    currencies[index].currencyName.toString());
                              },
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.asset('icons/flags/png/us.png',
                                    package: 'country_icons'),
                              ),
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(currency.currencyName),
                                  ),
                                ],
                              ),
                              subtitle: Text('United States Dollar\n' +
                                  '1 ' +
                                  currency.currencyName +
                                  ' = ' +
                                  snapshot.data![currency.currencyName]
                                      .toString() +
                                  ' USD'),
                              trailing: Icon(Icons.add),
                              isThreeLine: false,
                            );
                          }),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go back!'),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
