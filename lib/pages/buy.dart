import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/appcolor.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:testproject/pages/billpage.dart';

class Buy extends StatefulWidget {
  const Buy({super.key});

  @override
  State<Buy> createState() => _BuyState();
}

class _BuyState extends State<Buy> {
  List<String> _numbers = [];
  int _total = 0;
  var formatter = NumberFormat('#,###');
  final TextEditingController _animalNumberController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();
  // List<String> _animalSuggestions = [];
  List<String> _moneySuggestions = ['1,000', '5,000', '10,000', '20,000'];
  // OverlayEntry? _overlayEntry; // Declare outside of the function

  // Load numbers from SharedPreferences
  Future<List<String>?> _loadNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? numberStrings = prefs.getStringList('savedNumbers') ?? [];

    setState(() {
      _numbers = numberStrings;
    });

    return numberStrings;
  }

  // Calculate total price
  void _calculatePrice() async {
    int total = 0;
    List<String>? numbers = await _loadNumbers();
    for (int i = 0; i < numbers!.length; i++) {
      final data = jsonDecode(numbers[i]);
      total += data['price'] as int;
    }

    setState(() {
      _total = total;
    });
  }

  // Fetch animal suggestions based on user input
  // Future<void> _fetchAnimalSuggestions(String input) async {
  //   if (input.isEmpty) {
  //     setState(() {
  //       _animalSuggestions = [];
  //     });
  //     return;
  //   }

  //   final querySnapshot = await FirebaseFirestore.instance
  //       .collection('animals')
  //       .where('numbers', arrayContains: i   nput)
  //       .get();

  //   final List<String> suggestions = querySnapshot.docs
  //       .map((doc) => doc['numbers'] as List<dynamic>)
  //       .expand((list) => list)
  //       .map((number) => number.toString())
  //       .where((number) => number.contains(input))
  //       .toList();

  //   setState(() {
  //     _animalSuggestions = suggestions;
  //   });
  // }

  Future<List<String>> _mapNumbersWithPrices(String number, int price) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedNumbers = prefs.getStringList('savedNumbers') ?? [];
    Map<String, dynamic> newNumbers = {'number': number, 'price': price};
    savedNumbers.add(jsonEncode(newNumbers));
    return savedNumbers;
  }

  Future<void> _saveNumbers(List<String> strNumbers) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < strNumbers.length; i++) {
      List<String> newMapNumber = await _mapNumbersWithPrices(
          strNumbers[i].split(",")[0], int.parse(_moneyController.text));
      await prefs.setStringList('savedNumbers', newMapNumber);
    }
    _loadNumbers();
    _calculatePrice();
    _moneyController.clear();
    _animalNumberController.clear();
  }

  // Clear all saved numbers
  Future<void> _clearAllNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedNumbers');
    setState(() {
      _numbers = [];
      _total = 0;
    });
  }

  // Show Autocomplete
  // void _showAutocompleteSuggestions(
  //     BuildContext context, List<String> suggestions) {
  //   final overlay = Overlay.of(context);
  //   final renderBox = context.findRenderObject() as RenderBox;
  //   final size = renderBox.size;
  //   final offset = renderBox.localToGlobal(Offset.zero);

  //   _overlayEntry = OverlayEntry(
  //     builder: (context) => Positioned(
  //       top: offset.dy -
  //           suggestions.length *
  //               50, // Adjust position to show above the text field
  //       left: offset.dx,
  //       width: size.width,
  //       child: Material(
  //         elevation: 4.0,
  //         child: Container(
  //           color: Colors.white,
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             padding: EdgeInsets.zero,
  //             itemCount: suggestions.length,
  //             itemBuilder: (context, index) {
  //               return ListTile(
  //                 title: Text(suggestions[index]),
  //                 onTap: () {
  //                   // Handle item tap
  //                   _animalNumberController.text = suggestions[index];
  //                   _overlayEntry?.remove();
  //                   _overlayEntry = null; // Reset overlay entry
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   overlay.insert(_overlayEntry!);
  // }

  // Event on text changed
  // void _onTextChanged(String value) {
  //   final suggestions =
  //       _animalSuggestions.where((number) => number.startsWith(value)).toList();
  //   _showAutocompleteSuggestions(context, suggestions);
  // }

  // Initialize state
  @override
  void initState() {
    _loadNumbers();
    _calculatePrice();
    super.initState();
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("ຝັນພາລວຍ"),
        actions: [
          IconButton(
              onPressed: () {
                _clearAllNumbers();
              },
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ເລກທີ່ເລືອກ',
                    style:
                        TextStyle(fontSize: 20, color: AppColors.primaryColor),
                  ),
                  Text(
                    'ຈຳນວນເງິນ',
                    style:
                        TextStyle(fontSize: 20, color: AppColors.primaryColor),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 300, // Adjust height as needed
                child: _numbers.isEmpty
                    ? const Center(child: Text('No numbers in cart.'))
                    : ListView.builder(
                        itemCount: _numbers.length,
                        itemBuilder: (context, index) {
                          final data = jsonDecode(_numbers[index]);
                          String number = data['number'];
                          var price = formatter.format(data['price']);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            padding: const EdgeInsets.all(0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: AppColors.textPrimaryColor),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 40,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primaryColor),
                                  ),
                                  child: Text(
                                    number,
                                    style: const TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 13),
                                  ),
                                ),

                                // Price and Delete button
                                Row(
                                  children: [
                                    Text(
                                      price,
                                      style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        // Get the saved numbers from SharedPreferences
                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        List<String>? savedNumbers =
                                            prefs.getStringList(
                                                    'savedNumbers') ??
                                                [];

                                        // Remove the selected number from the list
                                        savedNumbers.removeAt(index);

                                        // Update the saved numbers in SharedPreferences
                                        await prefs.setStringList(
                                            'savedNumbers', savedNumbers);

                                        // Reload the numbers and calculate the new total price
                                        await _loadNumbers();
                                        _calculatePrice();
                                      },
                                      icon: const Icon(
                                          Icons.delete_forever_outlined),
                                      color: Colors.red,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppColors.textPrimaryColor))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ລວມທັງໝົດ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: 20),
                    ),
                    Text(
                      formatter.format(_total),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextField(
                            controller: _animalNumberController,
                            keyboardType: TextInputType.number,
                            // onChanged: (value) {
                            //   _fetchAnimalSuggestions(
                            //       value); // Fetch suggestions based on user input
                            //   _showAutocompleteSuggestions(context,
                            //       _animalSuggestions); // Show suggestions
                            // },
                            decoration: const InputDecoration(
                              hintText: 'ເລກເດັດ',
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: TextField(
                            controller: _moneyController,
                            decoration: const InputDecoration(
                              hintText: 'ເງິນ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _moneySuggestions = _moneySuggestions
                                    .where((suggestion) =>
                                        suggestion.contains(value))
                                    .toList();
                              });
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: ElevatedButton(
                              onPressed: () {
                                String number = _animalNumberController.text;
                                List<String> animalNumbersList =
                                    number.split(',');

                                // int price = int.parse(
                                // _moneyController.text.replaceAll(',', ''));
                                _saveNumbers(animalNumbersList);
                                _calculatePrice();
                                setState(() {});
                              },
                              child: const Text('ຊື້')),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      onPressed: () async {
                        try {
                          // Get current user ID
                          String userId =
                              FirebaseAuth.instance.currentUser!.uid;

                          // Prepare the data to be saved
                          List<Map<String, dynamic>> numberData =
                              _numbers.map((jsonString) {
                            final data = jsonDecode(jsonString);
                            return {
                              'number': data['number'],
                              'price': data['price'],
                            };
                          }).toList();

                          // Create a new buy history entry
                          DocumentReference documentReference =
                              await FirebaseFirestore.instance
                                  .collection('buyHistory')
                                  .add({
                            'userId': userId,
                            'numbers': numberData,
                            'total': _total,
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          // Clear the numbers from SharedPreferences
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove('savedNumbers');

                          // Get the server timestamp after it's set
                          DocumentSnapshot documentSnapshot =
                              await documentReference.get();
                          DateTime timestamp =
                              (documentSnapshot['timestamp'] as Timestamp)
                                  .toDate();
// Clear the local state and show a success message
                          int total = _total;
                          setState(() {
                            _numbers = [];
                            _total = 0;
                          });
                          // Navigate to the BillPage with the details
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => BillPage(
                                numberData: numberData,
                                total: total,
                                timestamp: timestamp,
                              ),
                            ),
                          );
                        } catch (e) {
                          log("error");
                          // Handle errors
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ເກີດຂໍ້ຜິດພາດ: $e')),
                          );
                        }
                      },
                      child: const Text('ຈ່າຍເງິນ'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
