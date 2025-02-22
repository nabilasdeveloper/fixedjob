import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fixedjob/login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? email, fotoUrl;
  File? _image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      _logout();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Response Body: ${response.body}"); // Debugging API Response

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nameController.text = data['nama'] ?? '';
          email = data['email'];
          _deskripsiController.text = data['deskripsi'] ?? '';
          _alamatController.text = data['alamat'] ?? '';
          _contactController.text = data['contact'] ?? '';
          fotoUrl = data['foto']; // URL foto profil
          _isLoading = false;
        });
      } else {
        _logout();
      }
    } catch (error) {
      print("Error fetching profile: $error");
      _logout();
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      _logout();
      return;
    }

    setState(() => _isLoading = true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/api/profile'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['nama'] = _nameController.text;
    request.fields['deskripsi'] = _deskripsiController.text;
    request.fields['alamat'] = _alamatController.text;
    request.fields['contact'] = _contactController.text;

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', _image!.path),
      );
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        _fetchUserProfile(); // Refresh data setelah update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? 'Gagal memperbarui profil')),
        );
      }
    } catch (error) {
      print("Error updating profile: $error");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan, periksa koneksi Anda!')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('${fotoUrl}');
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (fotoUrl != null
                                    ? NetworkImage('$fotoUrl')
                                    : AssetImage('assets/default_avatar.png'))
                                as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nama'),
                      validator: (value) =>
                          value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      initialValue: email,
                      enabled: false,
                    ),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(labelText: 'Deskripsi'),
                      validator: (value) => value!.isEmpty
                          ? 'Deskripsi tidak boleh kosong'
                          : null,
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(labelText: 'Alamat'),
                      validator: (value) =>
                          value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                    ),
                    TextFormField(
                      controller: _contactController,
                      decoration: InputDecoration(labelText: 'Contact'),
                      validator: (value) =>
                          value!.isEmpty ? 'Contact tidak boleh kosong' : null,
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _updateProfile,
                            child: Text('Update Profile'),
                          ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: _logout,
                      child:
                          Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
