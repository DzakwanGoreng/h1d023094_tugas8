import 'package:flutter/material.dart';
import 'package:h1d023094_tugas8/ui/registrasi_page.dart';
import 'package:h1d023094_tugas8/ui/produk_page.dart'; // IMPORT ProdukPage supaya bisa navigasi

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _emailTextboxController = TextEditingController();
  final _passwordTextboxController = TextEditingController();

  @override
  void dispose() {
    _emailTextboxController.dispose();
    _passwordTextboxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Dzakwan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _emailTextField(),
                _passwordTextField(),
                const SizedBox(height: 12),
                _buttonLogin(),
                const SizedBox(height: 30),
                _menuRegistrasi()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Email"),
      keyboardType: TextInputType.emailAddress,
      controller: _emailTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email harus diisi';
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Password"),
      keyboardType: TextInputType.text,
      obscureText: true,
      controller: _passwordTextboxController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password harus diisi";
        }
        return null;
      },
    );
  }

  Widget _buttonLogin() {
    return ElevatedButton(
      child: _isLoading ? const CircularProgressIndicator() : const Text("Login"),
      onPressed: () async {
        final validate = _formKey.currentState!.validate();
        if (!validate) return;

        setState(() => _isLoading = true);

        // Simulasi proses login (ganti dengan panggilan API Anda)
        await Future.delayed(const Duration(seconds: 1));

        setState(() => _isLoading = false);

        // Contoh: setelah berhasil login, pindah ke ProdukPage dan hapus halaman Login dari stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProdukPage()),
        );

        // Jika Anda ingin menyimpan token / status login, simpan di sini (SharedPreferences, secure_storage, dsb.)
      },
    );
  }

  Widget _menuRegistrasi() {
    return Center(
      child: InkWell(
        child: const Text(
          "Registrasi",
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrasiPage()));
        },
      ),
    );
  }
}
