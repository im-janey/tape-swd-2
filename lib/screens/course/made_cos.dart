import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _saveSelectedPlaces() async {
    final docRef =
        FirebaseFirestore.instance.collection('my cos').doc(widget.id);

    try {
      final randomDoc = await FirebaseFirestore.instance
          .collection('cos')
          .doc(widget.id)
          .get();

      List<dynamic> randomImages = randomDoc.data()?['random'] ?? [];

      await docRef.update({
        'selectedplace': widget.selectedplace,
        'randomImages': randomImages,
      });

      print('Firestore에 선택된 장소와 랜덤 이미지가 업데이트되었습니다.');

      Navigator.popUntil(
        context,
        (route) => route.settings.name == 'Cos',
      );
    } catch (e) {
      print('Error updating selected places: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택한 장소 저장에 실패했습니다.')),
        );
      }
    }
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

  void _updateCameraBounds() {
    if (_markers.isEmpty) return;

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

    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cosName}'),
        actions: [
          ElevatedButton(
            onPressed: _saveSelectedPlaces,
            child: const Text('저장'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 200.0,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated,
              markers: _markers,
            ),
          ),
          Expanded(
            child: placeDetails.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: placeDetails.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(placeDetails[index]['title'] ?? '제목 없음'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
