import 'dart:async';
import 'package:fixedjob/screens/detail_lowongan_screen.dart';
import 'package:fixedjob/screens/detail_perusahaan_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = "";
  int _selectedTabIndex = 0; // 0 = Lowongan, 1 = Perusahaan
  Timer? _searchDelay;

  void _onSearchChanged(String query) {
    if (_searchDelay?.isActive ?? false) _searchDelay!.cancel();

    _searchDelay = Timer(Duration(milliseconds: 500), () {
      _search();
    });
  }

  Future<void> _search() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = "";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      String url = _selectedTabIndex == 0
          ? 'http://127.0.0.1:8000/api/cari-lowongan?q=$query'
          : 'http://127.0.0.1:8000/api/cari-perusahaan?q=$query';

      await Future.delayed(Duration(seconds: 1)); // Simulasi loading

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200 && data['status'] == 'success') {
          _searchResults = data['data'] ?? [];
          _errorMessage =
              _searchResults.isEmpty ? "Tidak ada hasil ditemukan" : "";
        } else {
          _errorMessage = data['message'] ?? "Terjadi kesalahan saat mencari.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal mengambil data, periksa koneksi Anda.";
      });
    }
  }

  @override
  void dispose() {
    _searchDelay?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cari Data..'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
                _searchResults = [];
                _errorMessage = "";
              });
            },
            tabs: [
              Tab(text: "Lowongan"),
              Tab(text: "Perusahaan"),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: _selectedTabIndex == 0
                      ? "Cari Lowongan..."
                      : "Cari Perusahaan...",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _search,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage))
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];

                              if (_selectedTabIndex == 0) {
                                // Tampilan untuk hasil pencarian Lowongan
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    title: Text(
                                      item['nama_lowongan'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Gaji: ${item['gaji_perbulan']}'),
                                        Text(
                                            'Kategori: ${item['kategori_lowongan']}'),
                                        Text(
                                            'Batas: ${item['penutupan_lowongan']}'),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailLowonganScreen(
                                                  id: item['id']),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                // Tampilan untuk hasil pencarian Perusahaan
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    leading: item['img_perusahaan'] != null
                                        ? Image.network(
                                            'http://127.0.0.1:8000/storage/${item['img_perusahaan']}',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(Icons.business, size: 50),
                                    title: Text(
                                      item['nama_perusahaan'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Alamat: ${item['alamat']}'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPerusahaanScreen(
                                                  perusahaan: item),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
