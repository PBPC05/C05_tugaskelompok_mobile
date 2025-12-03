import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pittalk_mobile/features/news/data/news_model.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EditFormPage extends StatefulWidget {
  final News? news;

  const EditFormPage({super.key, this.news});

  @override
  State<EditFormPage> createState() => _EditFormPageState();
}

class _EditFormPageState extends State<EditFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _id = "";
  String _title = "";
  String _content = "";
  String _category = "f1"; // default
  String _thumbnail = "";
  bool _isFeatured = false; // default

  final List<String> _categories = [
    'f1',
    'championship',
    'team',
    'driver',
    'constructor',
    'race',
    'analysis',
    'history',
    'fanbase',
    'exclusive',
    'other',
  ];

  final _displayCatMap = {
    "f1": "Formula 1/FIA",
    "championship": "Championship",
    "team": "Team",
    "driver": "Driver",
    "constructor": "Constructor",
    "race": "Race",
    "analysis": "Analysis",
    "history": "F1 History",
    "fanbase": "F1 Fanbase",
    "exclusive": "Exclusive",
    "other": "Other",
  };

  @override
  void initState() {
    super.initState();
    var news = widget.news;

    if (news != null) {
      _id = news.id;
      _title = news.title;
      _content = news.content;
      _thumbnail = news.thumbnail;
      _category = news.category;
      _isFeatured = news.isFeatured;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Article")),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Edit Article",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Change information about your published article",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // News Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Title",
                  labelText: "Enter news title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                initialValue: _title,
                onChanged: (String? value) {
                  setState(() {
                    _title = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Title must not be empty";
                  }
                  return null;
                },
              ),
            ),

            // News Content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                minLines: 5,
                maxLines: double.maxFinite.toInt(),
                decoration: InputDecoration(
                  hintText: "Content",
                  labelText: "Enter news content",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                initialValue: _content,
                onChanged: (String? value) {
                  setState(() {
                    _content = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Content must not be empty";
                  }
                  return null;
                },
              ),
            ),

            // News Category
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                initialValue: _category,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(_displayCatMap[cat]!),
                      ),
                    )
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
              ),
            ),

            // News Thumbnail URL (optional)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Thumbnail URL",
                  labelText: "https://example.com/image.jpg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                initialValue: _thumbnail,
                onChanged: (String? value) {
                  setState(() {
                    _thumbnail = value!;
                  });
                },
                validator: (String? value) {
                  if (value != null && Uri.tryParse(value) == null) {
                    return "Thumbnail URL is invalid";
                  }
                  return null;
                },
              ),
            ),

            // News Featured Status
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SwitchListTile(
                title: const Text("Mark as Featured News"),
                value: _isFeatured,
                onChanged: (bool value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),
            ),

            // Submit Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Post news to Django
                      final response = await request.postJson(
                        "http://localhost:8000/news/$_id/edit-flutter/",
                        jsonEncode({
                          "id": _id,
                          "title": _title,
                          "content": _content,
                          "thumbnail": _thumbnail,
                          "category": _category,
                          "is_featured": _isFeatured,
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("News successfully saved!"),
                            ),
                          );

                          // Refresh news and return to news page
                          context.pop(true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Something went wrong, please try again.",
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Confirm Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
