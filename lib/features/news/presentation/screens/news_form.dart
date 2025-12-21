import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();
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
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("Create New Article")),
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
                      "Create New Article",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Contribute to PitTalk News",
                      style: TextStyle(fontSize: 24, color: Colors.white),
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
                        "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/news/create-flutter/",
                        jsonEncode({
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
                    "Publish News",
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
