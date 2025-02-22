import 'package:fixedjob/screens/detail_perusahaan_screen.dart';
import 'package:fixedjob/screens/upload_lamaran_screen.dart'; // Tambahkan ini
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:bot_toast/bot_toast.dart';

String removeHtmlTags(String htmlText) {
  return htmlParser.parse(htmlText).body?.text ?? "";
}

class DetailLowonganScreen extends StatefulWidget {
  final int id;

  const DetailLowonganScreen({Key? key, required this.id}) : super(key: key);

  @override
  _DetailLowonganScreenState createState() => _DetailLowonganScreenState();
}

class _DetailLowonganScreenState extends State<DetailLowonganScreen> {
  bool _isLoading = true;
  String _errorMessage = "";
  Map<String, dynamic>? _lowongan;
  bool _isBookmarked = false;
  bool _isBookmarking = false;
  bool _sudahMelamar = false; // Tambahkan ini untuk cek status pelamaran

  @override
  void initState() {
    super.initState();
    _fetchLowonganDetail();
    _checkIfBookmarked();
    _cekStatusLamaran(); // Cek apakah user sudah melamar
  }

  Future<void> _cekStatusLamaran() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/lamaran/check/${widget.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _sudahMelamar = responseData['sudah_melamar'] ?? false;
        });
      }
    } catch (e) {
      print("Gagal mengecek status lamaran: $e");
    }
  }

  Future<void> _checkIfBookmarked() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/bookmarks/check/${widget.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _isBookmarked = responseData['bookmarked'] ?? false;
        });
      }
    } catch (e) {
      print("Gagal mengecek bookmark: $e");
    }
  }


Future<void> _toggleBookmark() async {
  if (_isBookmarking) return;

  setState(() {
    _isBookmarking = true;
  });

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    late http.Response response;

    if (_isBookmarked) {
      response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/bookmarks/${widget.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } else {
      response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/bookmarksadd'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'lowongan_id': widget.id}),
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      setState(() {
        _isBookmarked = !_isBookmarked;
      });

      // Notifikasi menggunakan BotToast Notification
      BotToast.showNotification(
        title: (_) => Text(
          _isBookmarked ? "Bookmark Ditambahkan" : "Bookmark Dihapus",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: (_) => Text(
          _isBookmarked
              ? "Berhasil Menambahkan."
              : "Telah Dihapus.",
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
        leading: (_) => Icon( // Tambahkan (_) => sebelum Icon
          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: Colors.white,
          size: 30,
        ),
        margin: EdgeInsets.all(10),
        backgroundColor: _isBookmarked ? Colors.green : Colors.red,
        duration: Duration(seconds: 3),
      );

    } else {
      print("Gagal mengubah bookmark (Status: ${response.statusCode})");
    }
  } catch (e) {
    print("Terjadi kesalahan: $e");
  } finally {
    setState(() {
      _isBookmarking = false;
    });
  }
}


  Future<void> _fetchLowonganDetail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/lowongan/${widget.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('lowongan')) {
          setState(() {
            _lowongan = responseData['lowongan'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Data tidak ditemukan";
            _isLoading = false;
          });
        }
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
    if (_lowongan == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Detail Lowongan')),
        body: Center(
            child:
                _isLoading ? CircularProgressIndicator() : Text(_errorMessage)),
      );
    }

    final perusahaan = _lowongan!['perusahaan'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_lowongan!['nama_lowongan']),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked
                  ? Colors.blue
                  : Colors.black, // Warna berubah saat bookmark aktif
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (perusahaan != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailPerusahaanScreen(perusahaan: perusahaan),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Image.network(
                      'http://127.0.0.1:8000/storage/${perusahaan['img_perusahaan']}',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 8),
                    Text(
                      perusahaan['nama_perusahaan'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Text('Kategori: ${_lowongan!['kategori_lowongan']}'),
            Text('Gaji: ${_lowongan!['gaji_perbulan']}'),
            Text('Batas Lamaran: ${_lowongan!['penutupan_lowongan']}'),
            SizedBox(height: 20),

            /// **TOMBOL LAMAR SEKARANG**
            Center(
              child: ElevatedButton(
                onPressed: _sudahMelamar
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UploadLamaranScreen(lowonganId: widget.id),
                          ),
                        );

                        if (result == true) {
                          _cekStatusLamaran(); // Cek ulang status setelah melamar

                          // Tampilkan notifikasi dengan BotToast
                          BotToast.showText(
                            text: "Lamaran Anda telah berhasil dikirim!",
                            duration: Duration(seconds: 3),
                            contentColor: Colors.green,
                            textStyle:
                                TextStyle(fontSize: 16, color: Colors.white),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: _sudahMelamar ? Colors.grey : Colors.blue,
                ),
                child: Text(
                  _sudahMelamar ? "Anda sudah melamar" : "Lamar Sekarang",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
