import 'package:fixedjob/screens/detail_lowongan_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  /// Mengambil data riwayat lamaran
  Future<void> _fetchHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/lamaran/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _history = responseData['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Gagal mengambil data (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Terjadi kesalahan: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Lamaran")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _history.isEmpty
                  ? Center(child: Text("Belum ada riwayat lamaran."))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        final lowongan = item['lowongan'];
                        final perusahaan = lowongan['perusahaan'];

                        return Card(
                          margin: EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () {
                              // Navigasi ke DetailLowonganScreen saat Card ditekan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailLowonganScreen(
                                    id: lowongan['id'],
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: perusahaan['img_perusahaan'] != null
                                  ? Image.network(
                                      'http://127.0.0.1:8000/storage/${perusahaan['img_perusahaan']}',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.business, size: 50),
                              title: Text(lowongan['nama_lowongan'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Perusahaan: ${perusahaan['nama_perusahaan']}"),
                                  Text(
                                      "Kategori: ${lowongan['kategori_lowongan']}"),
                                  Text("Status: ${item['status']}"),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
