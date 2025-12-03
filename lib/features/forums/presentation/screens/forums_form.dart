import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';
import 'package:pittalk_mobile/features/forums/presentation/screens/forums_detail.dart';

class ForumFormPage extends StatefulWidget {
  final ForumResult? editForum;
  const ForumFormPage({Key? key, this.editForum}) : super(key: key);

  @override
  State<ForumFormPage> createState() => _ForumFormPageState();
}

class _ForumFormPageState extends State<ForumFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleC = TextEditingController();
  final TextEditingController _contentC = TextEditingController();
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.editForum != null) {
      _titleC.text = widget.editForum!.title;
      _contentC.text = widget.editForum!.content;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => submitting = true);
    try {
      if (widget.editForum != null) {
        // edit
        final uri = Uri.parse('$baseUrl/forums/${widget.editForum!.forumsId}/edit/json/');
        final resp = await http.post(uri,
            headers: defaultHeaders(),
            body: jsonEncode({'title': _titleC.text.trim(), 'content': _contentC.text.trim()}));
        if (resp.statusCode == 200) {
          Navigator.of(context).pop(true);
        } else {
          debugPrint('edit failed: ${resp.statusCode} ${resp.body}');
        }
      } else {
        // create
        final uri = Uri.parse('$baseUrl/forums/create/json/');
        final resp = await http.post(uri,
            headers: defaultHeaders(),
            body: jsonEncode({'title': _titleC.text.trim(), 'content': _contentC.text.trim()}));
        if (resp.statusCode == 201 || resp.statusCode == 200) {
          Navigator.of(context).pop(true);
        } else {
          debugPrint('create failed: ${resp.statusCode} ${resp.body}');
        }
      }
    } catch (e) {
      debugPrint('submit error: $e');
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.editForum != null ? 'Edit Discussion' : 'New Discussion';
    return Scaffold(
      appBar: AppBar(title: Text(action)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _titleC,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextFormField(
                controller: _contentC,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: submitting ? null : _submit, child: Text(action)),
            ])
          ]),
        ),
      ),
    );
  }
}
