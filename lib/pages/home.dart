import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/appcolor.dart';
import 'package:testproject/pages/historypage.dart';

class MyHomePage extends StatefulWidget {
  final Function(int) countCart;
  const MyHomePage({super.key, required this.countCart});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Sharedpreferences instance
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Search Box controller
  final TextEditingController _searchBoxController = TextEditingController();

  // This variable is used to store search results
  List<DocumentSnapshot> _searchResults = [];

  // int? _cartCount;

  // This variable is used to check if a search is ongoing
  bool _isSearching = false;
  bool _isTyping = false;

//Map numbers with prices
  Future<List<String>> _mapNumbersWithPrices(String number) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedNumbers = prefs.getStringList('savedNumbers') ?? [];
    Map<String, dynamic> newNumbers = {'number': number, 'price': 1000};
    savedNumbers.add(jsonEncode(newNumbers));
    return savedNumbers;
  }

// save Number
  Future<void> _saveNumbers(List<String> strNumbers) async {
    final SharedPreferences prefs = await _prefs;
    for (int i = 0; i < strNumbers.length; i++) {
      List<String> newMapNumber = await _mapNumbersWithPrices(strNumbers[i]);
      await prefs.setStringList('savedNumbers', newMapNumber);
    }
    _loadCartCount();
  }

  //load cartCount
  Future<void> _loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? numberStrings = prefs.getStringList('savedNumbers') ?? [];
    widget.countCart(numberStrings.length);
  }

  @override
  void initState() {
    _loadCartCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ໜ້າຫຼັກ",
          style: TextStyle(fontFamily: 'Defago'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
            icon: const Icon(
              Icons.history_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Box
            TextField(
              controller: _searchBoxController,
              onChanged: (value) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => setState(() {
                          _isSearching = false;
                          _isTyping = true;
                        }));
              },
              decoration: InputDecoration(
                labelText: "ຝັນວ່າຫຍັງ...?",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: const Color.fromARGB(255, 237, 237, 237),
                suffixIcon: IconButton(
                  onPressed: () {
                    _isTyping && _isSearching
                        ? _clearText()
                        : _searchAnimal(_searchBoxController.text);

                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => setState(() {
                              _isSearching = true;
                            }));
                  },
                  icon: Icon(_isSearching
                      ? Icons.close_rounded
                      : Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'ຕົວຢ່າງ: ຝັນເຫັນຜີໄລ່ຕົກໜອງໃຫ້ພິມ ຜີ,ໄລ່,ໜອງ',
              style: TextStyle(fontSize: 15, color: AppColors.mainGradientTwo),
            ),

            const SizedBox(height: 10),

            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'ຝັນຍອດ Hit ...',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),

            const SizedBox(height: 10),

            // Displaying search results or top searches
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildTopSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No results found.'));
    }
    return _buildAnimalListView(_searchResults);
  }

  Widget _buildTopSearches() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('animals')
          .orderBy('searchCount', descending: true)
          .limit(15)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildAnimalListView(snapshot.data!.docs);
      },
    );
  }

  Widget _buildAnimalListView(List<DocumentSnapshot> animals) {
    return ListView.builder(
      itemCount: animals.length,
      itemBuilder: (context, index) {
        var animal = animals[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [AppColors.mainGradientOne, AppColors.mainGradientTwo],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 90,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animal Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),

                        //Show Animal Image Section
                        child: FutureBuilder(
                          future: _loadImage(animal['imageUrl']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Image.asset(snapshot.data as String,
                                  fit: BoxFit.cover);
                            } else {
                              return const Icon(Icons.image,
                                  size: 50, color: Colors.grey);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Animal Name and Numbers
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  animal['name'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${animal['searchCount']} ຄັ້ງ',
                                  style: const TextStyle(
                                      color: AppColors.secondaryColor,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 5,
                              children: (animal['numbers'] as List<dynamic>)
                                  .map((number) => Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(5),
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.primaryColor),
                                        ),
                                        child: Text(
                                          number.toString(),
                                          style: const TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 12),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 90,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondaryGradientOne,
                      AppColors.secondaryGradientTwo,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(60),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      // height: AppColors
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // print(animal['numbers']);
                    List<String> strNumbers = [
                      for (int i = 0; i < animal['numbers'].length; i++)
                        animal['numbers'][i].toString()
                    ];
                    // print(strNumbers);
                    _saveNumbers(strNumbers);
                  },
                  child: const Text('ຊື້ເລີຍ'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchAnimal(String query) async {
    if (query.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
            _isSearching = false;
            _searchResults = [];
          }));
      return;
    }

    // Split the query by commas or spaces
    List<String> keywords =
        query.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty).toList();

    // Search in the Firestore collection using the split keywords
    var results = await FirebaseFirestore.instance
        .collection('animals')
        .where('keywords', arrayContainsAny: keywords)
        .get();

    setState(() {
      _searchResults = results.docs;
    });

    if (results.docs.isNotEmpty) {
      _trackSearch(query);
    }
  }

  void _clearText() {
    _searchBoxController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          _isTyping = false;
          _isSearching = false;
        }));
  }

  Future<void> _trackSearch(String query) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    String today = DateTime.now().toIso8601String().substring(0, 10);

    var searchRecord = await FirebaseFirestore.instance
        .collection('search')
        .doc(today)
        .collection('users')
        .doc(userId)
        .get();

    List<dynamic> searchedQueries = searchRecord.data()?['queries'] ?? [];

    if (!searchedQueries.contains(query)) {
      await FirebaseFirestore.instance
          .collection('search')
          .doc(today)
          .collection('users')
          .doc(userId)
          .set({
        'queries': FieldValue.arrayUnion([query])
      });

      // Update search count for all search results
      for (var result in _searchResults) {
        var animalRef =
            FirebaseFirestore.instance.collection('animals').doc(result.id);
        var animalData = await animalRef.get();
        int searchCount = animalData['searchCount'] ?? 0;

        await animalRef.update({'searchCount': searchCount + 1});
      }
    }
  }

  // Helper function to load image
  Future<String> _loadImage(String image) async {
    String imgPath = 'assets/images/animal/$image';
    bool exists = await _assetExists(imgPath);
    return exists ? imgPath : 'assets/images/animal/non_disp_big.jpg';
  }

// Function to check if asset exists
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}
