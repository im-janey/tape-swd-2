import 'package:flutter/material.dart';
import 'package:flutter_application_1/packages/product.dart';
import 'package:flutter_application_1/screens/home/banner1.dart';
import 'package:flutter_application_1/screens/map/Frame.dart';

import 'drawer.dart';
import 'search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _navigateToSearch([String? query]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Search(initialQuery: query)),
    );
  }

  Widget _buildIconButton(String asset, Product product) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Frame(product: product)),
      ),
      child: Image.asset(asset, height: 55, width: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 110,
          title: Image.asset('assets/logo.png', width: 140),
          actions: [
            Stack(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.menu, size: 25),
                    padding: const EdgeInsets.only(top: 21, right: 33),
                  ),
                ),
                Positioned(
                  right: 30,
                  top: 19,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        endDrawer: CustomDrawer(),
        body: Column(
          children: [
            SizedBox(height: 15),
            Banner1(),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                cursorColor: Theme.of(context).primaryColor,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _navigateToSearch(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: '어디로 갈까요?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: _isSearchFocused ? 2.0 : 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.0,
                    ),
                  ),
                  filled: true,
                  fillColor: _isSearchFocused
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey[100],
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        _navigateToSearch(_searchController.text);
                      } else {
                        _navigateToSearch();
                      }
                    },
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                ),
              ),
            ),
            SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _buildIconButton('assets/bob.png', restaurantProduct),
                    SizedBox(height: 20),
                    _buildIconButton('assets/display.png', displayProduct),
                  ],
                ),
                SizedBox(width: 30),
                Column(
                  children: [
                    _buildIconButton('assets/cafe.png', cafeProduct),
                    SizedBox(height: 20),
                    _buildIconButton('assets/play.png', playProduct),
                  ],
                ),
                SizedBox(width: 30),
                Column(
                  children: [
                    _buildIconButton('assets/park.png', parkProduct),
                    SizedBox(height: 20),
                    _buildIconButton('assets/mall.png', shoppingProduct),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
