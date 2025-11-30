# README - Aplikasi Toko Kita

Aplikasi mobile untuk manajemen produk toko dengan fitur autentikasi dan CRUD (Create, Read, Update, Delete).

## Fitur Aplikasi
- Login & Registrasi
- Daftar Produk
- Tambah Produk
- Edit Produk
- Hapus Produk
- Logout

## Konfigurasi API

Sebelum menjalankan aplikasi, pastikan untuk mengubah base URL API di file `lib/helpers/api_url.dart`:

```dart
static const String baseUrl = 'http://192.168.18.232/toko-api/public';
```

Ganti `192.168.18.232` dengan IP address server Anda.

---

## 1. Proses Registrasi

### a. Tampilan Form Registrasi
<img width="430" height="966" alt="image" src="https://github.com/user-attachments/assets/1d5f86a9-6005-444e-b1e5-994456f216ca" />


**Penjelasan:**
- User mengisi form registrasi dengan data: Nama, Email, Password, dan Konfirmasi Password
- Validasi form dilakukan sebelum submit

**Kode Validasi:**
```dart
// lib/ui/registrasi_page.dart
Widget _namaTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Nama"),
    controller: _namaTextboxController,
    validator: (value) {
      if (value!.length < 3) return "Nama harus diisi minimal 3 karakter";
      return null;
    },
  );
}

Widget _passwordKonfirmasiTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Konfirmasi Password"),
    obscureText: true,
    validator: (value) {
      if (value != _passwordTextboxController.text) 
        return "Konfirmasi Password tidak sama";
      return null;
    },
  );
}
```

### b. Proses Registrasi ke API
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/24f8cbb1-3302-41c8-866d-c4e1bcbe5976" />


**Penjelasan:**
- Data dikirim ke endpoint `/registrasi` melalui `RegistrasiBloc`
- Jika berhasil, muncul dialog sukses
- Jika gagal, muncul dialog peringatan

**Kode:**
```dart
// lib/ui/registrasi_page.dart
void _submit() {
  setState(() => _isLoading = true);
  
  RegistrasiBloc.registrasi(
    nama: _namaTextboxController.text,
    email: _emailTextboxController.text,
    password: _passwordTextboxController.text
  ).then((value) {
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        description: "Registrasi berhasil, silahkan login",
        okClick: () => Navigator.pop(context),
      )
    );
  }, onError: (error) {
    showDialog(
      context: context,
      builder: (context) => const WarningDialog(
        description: "Registrasi gagal, silahkan coba lagi",
      )
    );
  });
  
  setState(() => _isLoading = false);
}
```

---

## 2. Proses Login

### a. Tampilan Form Login
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/3147cebd-06e8-4efa-a11e-04cfc413c6f0" />

**Penjelasan:**
- User mengisi email dan password
- Validasi form dilakukan sebelum submit

**Kode Validasi:**
```dart
// lib/ui/login_page.dart
Widget _emailTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Email"),
    controller: _emailTextboxController,
    validator: (value) {
      if (value!.isEmpty) return 'Email harus diisi';
      return null;
    },
  );
}
```

### b. Proses Login dan Penyimpanan Token


**Penjelasan:**
- Kredensial dikirim ke endpoint `/login`
- Jika berhasil (code 200), token dan userID disimpan ke SharedPreferences
- User diarahkan ke halaman daftar produk
- Jika gagal, muncul dialog peringatan

**Kode:**
```dart
// lib/ui/login_page.dart
void _submit() {
  setState(() => _isLoading = true);
  
  LoginBloc.login(
    email: _emailTextboxController.text,
    password: _passwordTextboxController.text
  ).then((value) async {
    if (value.code == 200) {
      await UserInfo().setToken(value.token.toString());
      await UserInfo().setUserID(int.parse(value.userID.toString()));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProdukPage())
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => const WarningDialog(
          description: "Login gagal, silahkan coba lagi",
        )
      );
    }
  });
  
  setState(() => _isLoading = false);
}

// lib/bloc/login_bloc.dart
static Future<Login> login({String? email, String? password}) async {
  String apiUrl = ApiUrl.login;
  var body = {"email": email, "password": password};
  var response = await Api().post(apiUrl, body);
  var jsonObj = json.decode(response.body);
  return Login.fromJson(jsonObj);
}
```

---

## 3. Daftar Produk

### a. Tampilan List Produk
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/af5e862e-143c-4137-91a0-b59c41031acd" />



**Penjelasan:**
- Setelah login berhasil, aplikasi mengambil data produk dari API
- Data ditampilkan dalam bentuk list dengan nama dan harga produk
- Tombol (+) di AppBar untuk menambah produk baru
- Drawer menu untuk logout

**Kode:**
```dart
// lib/ui/produk_page.dart
body: FutureBuilder<List<Produk>>(
  future: ProdukBloc.getProduks(),
  builder: (context, snapshot) {
    if (snapshot.hasError) print(snapshot.error);
    return snapshot.hasData
      ? ListProduk(list: snapshot.data)
      : const Center(child: CircularProgressIndicator());
  },
)

// lib/bloc/produk_bloc.dart
static Future<List<Produk>> getProduks() async {
  String apiUrl = ApiUrl.listProduk;
  var response = await Api().get(apiUrl);
  var jsonObj = json.decode(response.body);
  List<dynamic> listProduk = jsonObj['data'];
  List<Produk> produks = [];
  for (int i = 0; i < listProduk.length; i++) {
    produks.add(Produk.fromJson(listProduk[i]));
  }
  return produks;
}
```

---

## 4. Detail Produk

### a. Tampilan Detail
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/c4459591-e6fc-4a23-9a2f-9f2e3134a846" />


**Penjelasan:**
- Tap pada item produk menampilkan halaman detail
- Menampilkan informasi lengkap produk
- Terdapat tombol EDIT dan DELETE

**Kode:**
```dart
// lib/ui/produk_detail.dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Detail Produk')),
    body: Center(
      child: Column(
        children: [
          Text("Kode: ${widget.produk!.kodeProduk}"),
          Text("Nama: ${widget.produk!.namaProduk}"),
          Text("Harga: Rp. ${widget.produk!.hargaProduk}"),
          _tombolHapusEdit()
        ],
      ),
    ),
  );
}
```

---

## 5. Tambah Produk

### a. Tampilan Form Tambah
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/f8f44454-dd7e-4300-b10e-87a07eef177c" />


**Penjelasan:**
- Akses dari tombol (+) di halaman daftar produk
- Form terdiri dari: Kode Produk, Nama Produk, dan Harga
- Validasi dilakukan sebelum submit

**Kode Validasi:**
```dart
// lib/ui/produk_form.dart
Widget _kodeProdukTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Kode Produk"),
    controller: _kodeProdukTextboxController,
    validator: (value) {
      if (value!.isEmpty) return "Kode Produk harus diisi";
      return null;
    },
  );
}
```

### b. Proses Simpan Data
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/1772cfa4-db37-4629-b044-b524837a47ea" />


**Penjelasan:**
- Data produk dikirim ke endpoint `/produk` dengan method POST
- Setelah berhasil, user diarahkan kembali ke halaman daftar produk
- Data baru akan muncul di list

**Kode:**
```dart
// lib/ui/produk_form.dart
void simpan() {
  setState(() => _isLoading = true);
  
  Produk createProduk = Produk(id: null);
  createProduk.kodeProduk = _kodeProdukTextboxController.text;
  createProduk.namaProduk = _namaProdukTextboxController.text;
  createProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);
  
  ProdukBloc.addProduk(produk: createProduk).then((value) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProdukPage())
    );
  }, onError: (error) {
    showDialog(
      context: context,
      builder: (context) => const WarningDialog(
        description: "Simpan gagal, silahkan coba lagi",
      )
    );
  });
  
  setState(() => _isLoading = false);
}

// lib/bloc/produk_bloc.dart
static Future addProduk({Produk? produk}) async {
  String apiUrl = ApiUrl.createProduk;
  var body = {
    "kode_produk": produk!.kodeProduk,
    "nama_produk": produk.namaProduk,
    "harga": produk.hargaProduk.toString()
  };
  var response = await Api().post(apiUrl, body);
  var jsonObj = json.decode(response.body);
  return jsonObj['status'];
}
```

---

## 6. Edit Produk

### a. Tampilan Form Edit
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/580bcac1-5c34-4da1-93e6-34c1de30aae1" />


**Penjelasan:**
- Akses dari tombol EDIT di halaman detail produk
- Form diisi dengan data produk yang akan diedit
- User dapat mengubah Kode, Nama, dan Harga produk

**Kode:**
```dart
// lib/ui/produk_form.dart
void initState() {
  super.initState();
  isUpdate();
}

isUpdate() {
  if (widget.produk != null) {
    setState(() {
      judul = "UBAH PRODUK";
      tombolSubmit = "UBAH";
      _kodeProdukTextboxController.text = widget.produk!.kodeProduk!;
      _namaProdukTextboxController.text = widget.produk!.namaProduk!;
      _hargaProdukTextboxController.text = widget.produk!.hargaProduk.toString();
    });
  }
}
```

### b. Proses Update Data
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/62eb4f88-157f-419c-bb5f-a04e2b7e2871" />

**Penjelasan:**
- Data dikirim ke endpoint `/produk/{id}` dengan method PUT
- Setelah berhasil, user diarahkan ke halaman daftar produk
- Data yang diupdate akan tampil dengan nilai baru

**Kode:**
```dart
// lib/ui/produk_form.dart
void ubah() {
  setState(() => _isLoading = true);
  
  Produk updateProduk = Produk(id: widget.produk!.id!);
  updateProduk.kodeProduk = _kodeProdukTextboxController.text;
  updateProduk.namaProduk = _namaProdukTextboxController.text;
  updateProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);
  
  ProdukBloc.updateProduk(produk: updateProduk).then((value) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProdukPage())
    );
  }, onError: (error) {
    showDialog(
      context: context,
      builder: (context) => const WarningDialog(
        description: "Permintaan ubah data gagal, silahkan coba lagi",
      )
    );
  });
  
  setState(() => _isLoading = false);
}

// lib/bloc/produk_bloc.dart
static Future updateProduk({required Produk produk}) async {
  String apiUrl = ApiUrl.updateProduk(int.parse(produk.id!));
  var body = {
    "kode_produk": produk.kodeProduk,
    "nama_produk": produk.namaProduk,
    "harga": produk.hargaProduk.toString()
  };
  var response = await Api().put(apiUrl, body);
  var jsonObj = json.decode(response.body);
  return jsonObj['status'];
}
```

---

## 7. Hapus Produk

### a. Konfirmasi Hapus
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/38f5ef7f-90b6-4608-829d-af05d2749f16" />

**Penjelasan:**
- Akses dari tombol DELETE di halaman detail produk
- Muncul dialog konfirmasi sebelum menghapus
- User dapat memilih "Ya" untuk menghapus atau "Batal"

**Kode:**
```dart
// lib/ui/produk_detail.dart
void confirmHapus() {
  AlertDialog alertDialog = AlertDialog(
    content: const Text("Yakin ingin menghapus data ini?"),
    actions: [
      OutlinedButton(
        child: const Text("Ya"),
        onPressed: () {
          ProdukBloc.deleteProduk(id: int.parse(widget.produk!.id!))
            .then((value) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProdukPage())
              );
            }, onError: (error) {
              showDialog(
                context: context,
                builder: (context) => const WarningDialog(
                  description: "Hapus gagal, silahkan coba lagi",
                )
              );
            });
        },
      ),
      OutlinedButton(
        child: const Text("Batal"),
        onPressed: () => Navigator.pop(context),
      )
    ],
  );
  showDialog(context: context, builder: (context) => alertDialog);
}
```

### b. Proses Hapus Data
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/a7cde0a9-0750-41f0-927d-0f893634a0c1" />

**Penjelasan:**
- Request DELETE dikirim ke endpoint `/produk/{id}`
- Produk dihapus dari database
- User diarahkan kembali ke halaman daftar produk
- Produk yang dihapus tidak lagi muncul di list

**Kode:**
```dart
// lib/bloc/produk_bloc.dart
static Future<bool> deleteProduk({int? id}) async {
  String apiUrl = ApiUrl.deleteProduk(id!);
  var response = await Api().delete(apiUrl);
  var jsonObj = json.decode(response.body);
  return jsonObj['data'];
}
```

---

## 8. Logout

### a. Menu Logout
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/3dc0405b-eaa8-4960-b801-4a06194ca79e" />


**Penjelasan:**
- Akses dari drawer menu di halaman daftar produk
- Tap pada menu Logout untuk keluar dari aplikasi

**Kode:**
```dart
// lib/ui/produk_page.dart
drawer: Drawer(
  child: ListView(
    children: [
      ListTile(
        title: const Text('Logout'),
        trailing: const Icon(Icons.logout),
        onTap: () async {
          await LogoutBloc.logout().then((value) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false
            );
          });
        },
      )
    ],
  ),
)
```

### b. Proses Logout
<img width="417" height="959" alt="image" src="https://github.com/user-attachments/assets/84981ca7-d15b-4dee-a45a-93520fccfb52" />


**Penjelasan:**
- Token dan data user dihapus dari SharedPreferences
- User diarahkan kembali ke halaman login
- Stack navigasi dibersihkan sehingga user tidak bisa kembali dengan tombol back

**Kode:**
```dart
// lib/bloc/logout_bloc.dart
static Future logout() async {
  await UserInfo().logout();
}

// lib/helpers/user_info.dart
Future logout() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.clear();
}
```

---

**Catatan:** Pastikan backend API sudah berjalan dan dapat diakses dari device/emulator yang digunakan.
