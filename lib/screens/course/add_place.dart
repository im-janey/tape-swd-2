import 'package:flutter/material.dart';

import 'made_cos.dart';

class AddPlacePage extends StatefulWidget {
  const AddPlacePage({super.key});

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final List<Map<String, String>> places = [
    {
      'image': 'assets/bob.png',
      'title': '오뜨루 성수',
      'subtitle': '식당',
    },
    {
      'image': 'assets/park.png',
      'title': '장소 2',
      'subtitle': '공원',
    },
  ];

  final Set<int> selectedPlaces = <int>{};

  void _toggleSelection(int index) {
    setState(() {
      if (selectedPlaces.contains(index)) {
        selectedPlaces.remove(index);
      } else {
        selectedPlaces.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '장소 추가',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '찜한 장소',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70.0),
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                if (selectedPlaces.contains(index)) {
                  return const SizedBox.shrink(); // 선택된 항목은 리스트에 나타나지 않도록 함
                }
                return ListTile(
                  leading: Image.asset(
                    places[index]['image']!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(places[index]['title']!),
                  subtitle: Text(places[index]['subtitle']!),
                  trailing: SizedBox(
                    width: 71,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        _toggleSelection(index);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text(
                        '선택',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedPlaces.isNotEmpty)
            Column(
              children: [
                Container(
                  height: 100.0,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedPlaces.length,
                    itemBuilder: (context, index) {
                      int placeIndex = selectedPlaces.elementAt(index);
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 20.0, top: 5),
                            child: Image.asset(
                              places[placeIndex]['image']!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _toggleSelection(placeIndex);
                              },
                              color: Colors.white,
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              splashRadius: 18,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(7, 12, 0, 0),
                    child: ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        if (selectedPlaces.contains(index)) {
                          return const SizedBox
                              .shrink(); // 선택된 항목은 리스트에 나타나지 않도록 함
                        }
                        return ListTile(
                          leading: Image.asset(
                            places[index]['image']!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(places[index]['title']!),
                          subtitle: Text(places[index]['subtitle']!),
                          trailing: SizedBox(
                            width: 71,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () {
                                _toggleSelection(index);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text(
                                '선택',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          if (selectedPlaces.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MadeCosPage(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  '선택완료',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
