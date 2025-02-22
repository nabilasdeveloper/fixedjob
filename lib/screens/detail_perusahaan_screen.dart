import 'package:flutter/material.dart';

class DetailPerusahaanScreen extends StatelessWidget {
  final Map<String, dynamic> perusahaan;

  DetailPerusahaanScreen({required this.perusahaan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(perusahaan['nama_perusahaan'])),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'http://127.0.0.1:8000/storage/${perusahaan['img_perusahaan']}',
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text('Email: ${perusahaan['email_perusahaan']}'),
            Text('Contact: ${perusahaan['contact_perusahaan']}'),
            Text('Alamat: ${perusahaan['alamat_perusahaan']}'),
            Text('Industri: ${perusahaan['jenis_industri_perusahaan']}'),
            Text('Website: ${perusahaan['website_perusahaan']}'),
          ],
        ),
      ),
    );
  }
}
