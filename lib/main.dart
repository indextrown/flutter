import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _newsList = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData(String search) async {
    final response = await http.post(
      Uri.parse('https://d685-15-164-193-200.ngrok-free.app/blog'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'search': search,
        'page': '3', // 페이지 번호를 수정하여 필요한 페이지를 요청할 수 있습니다.
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        // _newsList = json.decode(response.body) as List<dynamic>;
        _newsList = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _handleSearch() {
    String search = _searchController.text.trim();
    if (search.isNotEmpty) {
      fetchData(search);
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
          ),
          onSubmitted: (_) => _handleSearch(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _handleSearch,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _newsList.length,
        itemBuilder: (context, index) {
          final item = _newsList[index];
          return ListTile(
            title: Text(item['title'] ?? ''),
            subtitle: Text(item['link'] ?? ''),
            onTap: () {
              _launchURL(item['link']);
            },
          );
        },
      ),
    );
  }
}




