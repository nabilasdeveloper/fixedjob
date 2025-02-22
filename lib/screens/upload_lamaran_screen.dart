import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadLamaranScreen extends StatefulWidget {
  final int lowonganId;

  const UploadLamaranScreen({Key? key, required this.lowonganId})
      : super(key: key);

  @override
  _UploadLamaranScreenState createState() => _UploadLamaranScreenState();
}

class _UploadLamaranScreenState extends State<UploadLamaranScreen> {
  File? _suratLamaran;
  File? _cv;
  File? _dokumenLainnya;

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (type == 'surat') _suratLamaran = File(result.files.single.path!);
        if (type == 'cv') _cv = File(result.files.single.path!);
        if (type == 'dokumen')
          _dokumenLainnya = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitLamaran() async {
    if (_suratLamaran == null || _cv == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Surat Lamaran dan CV wajib diunggah")),
      );
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/lamaran/${widget.lowonganId}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.files.add(await http.MultipartFile.fromPath(
          'surat_lamaran', _suratLamaran!.path));
      request.files.add(await http.MultipartFile.fromPath('cv', _cv!.path));

      if (_dokumenLainnya != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'dokumen_lainnya', _dokumenLainnya!.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lamaran berhasil dikirim")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim lamaran")),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Unggah Lamaran")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text("Surat Lamaran"),
              subtitle: Text(_suratLamaran?.path ?? "Pilih file"),
              trailing: Icon(Icons.attach_file),
              onTap: () => _pickFile('surat'),
            ),
            ListTile(
              title: Text("CV"),
              subtitle: Text(_cv?.path ?? "Pilih file"),
              trailing: Icon(Icons.attach_file),
              onTap: () => _pickFile('cv'),
            ),
            ListTile(
              title: Text("Dokumen Lainnya (Opsional)"),
              subtitle: Text(_dokumenLainnya?.path ?? "Pilih file"),
              trailing: Icon(Icons.attach_file),
              onTap: () => _pickFile('dokumen'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitLamaran,
              child: Text("Kirim Lamaran"),
            ),
          ],
        ),
      ),
    );
  }
}
