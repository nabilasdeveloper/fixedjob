import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fixedjob/home.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/login'),
          body: {
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        );

        final data = jsonDecode(response.body);
        setState(() => _isLoading = false);

        if (response.statusCode == 200 && data['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);

          // Notifikasi Berhasil
          BotToast.showNotification(
            leading: (cancel) =>
                Icon(Icons.check_circle, color: Colors.white, size: 30),
            title: (_) => Text("Login Berhasil!",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            subtitle: (_) => Text("Selamat datang kembali",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(10),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Notifikasi Gagal
          BotToast.showNotification(
            leading: (cancel) =>
                Icon(Icons.error_outline, color: Colors.white, size: 30),
            title: (_) => Text("Login Gagal",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            subtitle: (_) => Text(
                data['message'] ?? "Periksa kembali email & password Anda",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(10),
          );
        }
      } catch (error) {
        setState(() => _isLoading = false);

        // Notifikasi Error
        BotToast.showNotification(
          leading: (cancel) =>
              Icon(Icons.warning, color: Colors.white, size: 30),
          title: (_) => Text("Terjadi Kesalahan",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          subtitle: (_) => Text("Silakan coba lagi nanti",
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo atau Icon
                FlutterLogo(size: 80,),
                SizedBox(height: 20),
                Text(
                  "Selamat Datang",
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 81, 197, 255)),
                ),
                Text(
                  "Masukkan akun Anda untuk melanjutkan",
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: const Color.fromARGB(255, 40, 56, 64)),
                ),
                SizedBox(height: 30),

                // Card Form
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Input Email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value!.contains('@')
                                ? null
                                : 'Masukkan email yang valid',
                          ),
                          SizedBox(height: 15),

                          // Input Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            obscureText: true,
                            validator: (value) => value!.length < 6
                                ? 'Password minimal 6 karakter'
                                : null,
                          ),
                          SizedBox(height: 20),

                          // Tombol Login dengan efek loading
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey[800],
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                          SizedBox(height: 10),

                          // Tombol Daftar
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: Text(
                              'Belum punya akun? Daftar',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.blueGrey[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
