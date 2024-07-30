import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testproject/appcolor.dart';
import 'package:testproject/pages/buy.dart';
import 'package:testproject/pages/home.dart';
import 'package:testproject/pages/profile.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;
  int _cartCount = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      MyHomePage(
        countCart: _updateCartCountFromHome,
      ),
      Buy(),
      Profile(),
    ];
    _updateCartCount();
  }

//update cart from home page
  void _updateCartCountFromHome(int count) {
    setState(() {
      _cartCount = count;
    });
  }

// update cart
  void _updateCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cartCount', _cartCount);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ໜ້າຫຼັກ',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'ຊື້ເລກ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_3),
            label: 'ບັນຊີ',
          ),
        ],
        selectedItemColor: AppColors.primaryColor,
        backgroundColor: AppColors.mainGradientTwo,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
