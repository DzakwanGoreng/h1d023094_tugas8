import 'package:flutter/material.dart';
import 'package:h1d023094_tugas8/model/produk.dart';
import 'package:h1d023094_tugas8/ui/produk_detail.dart';
import 'package:h1d023094_tugas8/ui/produk_form.dart';
import 'package:h1d023094_tugas8/ui/login_page.dart'; 

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  // contoh data statis (sesuai materi)
  List<Produk> items = [
    Produk(
      id: '1',
      kodeProduk: 'A001',
      namaProduk: 'Kamera',
      hargaProduk: 5000000,
    ),
    Produk(
      id: '2',
      kodeProduk: 'A002',
      namaProduk: 'Kulkas',
      hargaProduk: 2500000,
    ),
    Produk(
      id: '3',
      kodeProduk: 'A003',
      namaProduk: 'Mesin Cuci',
      hargaProduk: 2000000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Produk Dzakwan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: const Icon(Icons.add, size: 26.0),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProdukForm()),
                );
                if (result != null && result is Produk) {
                  setState(() {
                    items.add(result);
                  });
                }
              },
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout),
              onTap: () async {
                // Pastikan Anda menghapus session/token di sini jika ada.
                // Contoh: navigasi kembali ke LoginPage dan buang semua halaman sebelumnya.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            )
          ],
        ),
      ),
      body: ListView(
        children: items.map((p) => ItemProduk(produk: p, onDelete: _onDelete)).toList(),
      ),
    );
  }

  void _onDelete(Produk produk) {
    setState(() {
      items.removeWhere((element) => element.id == produk.id);
    });
  }
}

class ItemProduk extends StatelessWidget {
  final Produk produk;
  final void Function(Produk)? onDelete;
  const ItemProduk({Key? key, required this.produk, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final deleted = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProdukDetail(produk: produk)),
        );
        if (deleted == true && onDelete != null) {
          onDelete!(produk);
        }
      },
      child: Card(
        child: ListTile(
          title: Text(produk.namaProduk ?? ''),
          subtitle: Text(produk.hargaProduk.toString()),
        ),
      ),
    );
  }
}
