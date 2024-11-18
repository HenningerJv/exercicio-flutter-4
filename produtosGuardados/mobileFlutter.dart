import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD API Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CrudPage(),
    );
  }
}

class CrudPage extends StatefulWidget {
  const CrudPage({super.key});

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  final TextEditingController idController = TextEditingController(text: "0");
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();

  List<Map<String, dynamic>> items = [];

  Future<void> getItems() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost/api/testeApi.php/cliente/list"),
      );
      if (response.statusCode == 200) {
        setState(() {
          items = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError("Erro ao carregar dados.");
      }
    } catch (e) {
      showError("Erro: $e");
    }
  }

  Future<void> postItem() async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/api/testeApi.php/cliente"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nome": nomeController.text,
          "categoria": categoriaController.text,
        }),
      );
      if (response.statusCode == 200) {
        showMessage("Item adicionado com sucesso!");
        await getItems();
      } else {
        showError("Erro ao adicionar item.");
      }
    } catch (e) {
      showError("Erro: $e");
    }
  }

  Future<void> putItem() async {
    try {
      final response = await http.put(
        Uri.parse(
          "http://localhost/api/testeApi.php/cliente/${idController.text}",
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nome": nomeController.text,
          "categoria": categoriaController.text,
        }),
      );
      if (response.statusCode == 200) {
        showMessage("Item atualizado com sucesso!");
        await getItems();
      } else {
        showError("Erro ao atualizar item.");
      }
    } catch (e) {
      showError("Erro: $e");
    }
  }

  Future<void> deleteItem() async {
    try {
      final response = await http.delete(
        Uri.parse(
          "http://localhost/api/testeApi.php/cliente/${idController.text}",
        ),
      );
      if (response.statusCode == 200) {
        showMessage("Item excluído com sucesso!");
        await getItems();
      } else {
        showError("Erro ao excluir item.");
      }
    } catch (e) {
      showError("Erro: $e");
    }
  }

  void selectItem(Map<String, dynamic> item) {
    setState(() {
      idController.text = item['id'].toString();
      nomeController.text = item['nome'];
      categoriaController.text = item['categoria'];
    });
  }

  void showError(String message) {
    showMessage(message, isError: true);
  }

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD API')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID', enabled: false),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: categoriaController,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: getItems, child: const Text('GET')),
                ElevatedButton(onPressed: postItem, child: const Text('POST')),
                ElevatedButton(onPressed: putItem, child: const Text('PUT')),
                ElevatedButton(onPressed: deleteItem, child: const Text('DELETE')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['nome']),
                    subtitle: Text(item['categoria']),
                    onTap: () => selectItem(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
