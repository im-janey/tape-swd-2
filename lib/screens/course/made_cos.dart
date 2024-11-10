import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MadeCosPage extends StatefulWidget {
  final String id;
  final String cosName;
  final DateTime timestamp;
  final List<String> selectedplace;

  const MadeCosPage({
    super.key,
    required this.id,
    required this.cosName,
    required this.timestamp,
    required this.selectedplace,
  });

  @override
  State<MadeCosPage> createState() => _MadeCosPageState();
}

class _MadeCosPageState extends State<MadeCosPage> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 10,
  );
  late GoogleMapController _controller;
  List<Map<String, dynamic>> placeDetails = [];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchPlaceDetails();
  }

  void _updateCameraBounds() {
    if (_markers.isEmpty) return;

    LatLngBounds bounds;
    final latitudes =
        _markers.map((marker) => marker.position.latitude).toList();
    final longitudes =
        _markers.map((marker) => marker.position.longitude).toList();

    final southwest = LatLng(
      latitudes.reduce((a, b) => a < b ? a : b),
      longitudes.reduce((a, b) => a < b ? a : b),
    );
    final northeast = LatLng(
      latitudes.reduce((a, b) => a > b ? a : b),
      longitudes.reduce((a, b) => a > b ? a : b),
    );

    bounds = LatLngBounds(southwest: southwest, northeast: northeast);

    _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> _fetchPlaceDetails() async {
    const apiKey =
        'K%2Bwrqt0w3kcqkpq5TzBHI8P37Kfk50Rlz1dYzc62tM2ltmIBDY3VG4eiblr%2FQbjw1JSXZYsFQBw4IieHP9cP9g%3D%3D';
    List<Map<String, dynamic>> fetchedDetails = [];

    for (String contentId in widget.selectedplace) {
      final apiUrl =
          'https://apis.data.go.kr/B551011/KorWithService1/detailCommon1?MobileOS=ios&MobileApp=sad&contentId=$contentId&defaultYN=Y&firstImageYN=Y&mapinfoYN=Y&_type=json&serviceKey=$apiKey';

      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final decodedData = json.decode(utf8.decode(response.bodyBytes));
          var item = decodedData['response']?['body']?['items']?['item'];

          if (item is Map<String, dynamic>) {
            double? lat = double.tryParse(item['mapy'] ?? '');
            double? lng = double.tryParse(item['mapx'] ?? '');
            String title = item['title'] ?? '제목 없음';

            if (lat != null && lng != null) {
              fetchedDetails.add({
                'contentid': contentId,
                'title': title,
                'lat': lat,
                'lng': lng,
              });
              _addMarker(contentId, title, lat, lng);
            }
          } else if (item is List && item.isNotEmpty) {
            var firstItem = item[0];
            double? lat = double.tryParse(firstItem['mapy'] ?? '');
            double? lng = double.tryParse(firstItem['mapx'] ?? '');
            String title = firstItem['title'] ?? '제목 없음';

            if (lat != null && lng != null) {
              fetchedDetails.add({
                'contentid': contentId,
                'title': title,
                'lat': lat,
                'lng': lng,
              });
              _addMarker(contentId, title, lat, lng);
            }
          }
        }
      } catch (e) {
        print('Error fetching place details: $e');
      }
    }

    setState(() {
      placeDetails = fetchedDetails;
    });
  }

  void _addMarker(String contentId, String title, double lat, double lng) {
    final marker = Marker(
      markerId: MarkerId(contentId),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title),
    );

    setState(() {
      _markers.add(marker);
      _updateCameraBounds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(
                context,
                (route) => route.settings.name == 'Cos',
              );
            },
            child: Text('저장'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.cosName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  '${widget.timestamp.toLocal().year}-${widget.timestamp.toLocal().month}-${widget.timestamp.toLocal().day}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            height: 200.0,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated,
              markers: _markers,
              zoomControlsEnabled: true,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: placeDetails.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: placeDetails.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildListTile(
                            index: index + 1,
                            text1: placeDetails[index]['title'] ?? '제목 없음',
                            text2: '',
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 34.0, right: 34, top: 10),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 0.3),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  '장소추가하기',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  Widget buildListTile({
    required int index,
    required String text1,
    required String text2,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text1,
            style: const TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            text2,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
