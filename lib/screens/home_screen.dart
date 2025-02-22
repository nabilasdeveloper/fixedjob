import 'dart:convert';
import 'package:fixedjob/screens/detail_lowongan_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeContentScreen extends StatefulWidget {
  @override
  _HomeContentScreenState createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  List<dynamic> _lowonganList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLowongan();
  }

  Future<void> _fetchLowongan() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Token tidak ditemukan. Silakan login ulang.";
        });
        return;
      }

      print("TOKEN: $token"); // Debugging token
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/lowongan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        print("Response Data: $responseData"); // Debugging untuk melihat data

        if (responseData.containsKey('data') &&
            responseData['data'].containsKey('lowongan') &&
            responseData['data']['lowongan'] is List) {
          setState(() {
            _lowonganList =
                responseData['data']['lowongan']; // Ambil daftar lowongan
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "Format data tidak sesuai.";
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Gagal mengambil data lowongan. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Terjadi kesalahan: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lowongan Kerja')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _lowonganList.isEmpty
                  ? Center(child: Text('Tidak ada lowongan tersedia'))
                  : ListView.builder(
                      itemCount: _lowonganList.length,
                      itemBuilder: (context, index) {
                        final lowongan = _lowonganList[index];
                        final perusahaan =
                            lowongan['perusahaan'] ?? {}; // Menghindari null

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Membuat gambar lebih rapi
                              child: Image.network(
                                'http://127.0.0.1:8000/storage/${perusahaan['img_perusahaan']}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image_not_supported, size: 60),
                              ),
                            ),
                            title: Text(lowongan['nama_lowongan'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${perusahaan['nama_perusahaan'] ?? 'Tidak diketahui'}'),
                                Text(
                                    '${lowongan['kategori_lowongan']}'),
                              ],
                            ),
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
