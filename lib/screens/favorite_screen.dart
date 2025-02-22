import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixedjob/screens/detail_lowongan_screen.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoading = true;
  String _errorMessage = "";
  List<dynamic> _bookmarkedLowongan = [];

  @override
  void initState() {
    super.initState();
    _fetchBookmarkedLowongan();
  }

  Future<void> _fetchBookmarkedLowongan() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/bookmarks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _bookmarkedLowongan = responseData['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              "Gagal mengambil data (Status: ${response.statusCode})";
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
      appBar: AppBar(title: Text('Lowongan Favorit')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _bookmarkedLowongan.isEmpty
                  ? Center(child: Text('Belum ada lowongan favorit.'))
                  : ListView.builder(
                      itemCount: _bookmarkedLowongan.length,
                      itemBuilder: (context, index) {
                        final bookmark = _bookmarkedLowongan[index];
                        final lowongan = bookmark['lowongan'];
                        final perusahaan = lowongan['perusahaan'];

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: perusahaan != null
                                ? Image.network(
                                    'http://127.0.0.1:8000/storage/${perusahaan['img_perusahaan']}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.business),
                            title: Text(lowongan['nama_lowongan'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Kategori: ${lowongan['kategori_lowongan']}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailLowonganScreen(id: lowongan['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
