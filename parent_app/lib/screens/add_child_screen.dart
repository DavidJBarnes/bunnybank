import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/services/auth_service.dart';
import 'package:bunnybank_parent/services/children_service.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  DateTime _birthday = DateTime(2018, 1, 1);
  Uint8List? _imageBytes;
  String? _imageUrl;
  final _picker = ImagePicker();
  bool _uploading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 70,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _uploading = true);
    final auth = context.read<AuthService>();
    final service = ChildrenService(auth.api);
    try {
      await service.createChild(
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text),
        birthday: _birthday.toIso8601String().split('T').first,
        imageUrl: _imageUrl,
        pin: _pinCtrl.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                    child: _imageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 32, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 4),
                              Text('Photo', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              if (_imageBytes != null)
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Change photo'),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final age = int.tryParse(v);
                  if (age == null || age < 0 || age > 18) return 'Age 0-18';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthday,
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _birthday = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                  ),
                  child: Text(
                    '${_birthday.year}-${_birthday.month.toString().padLeft(2, '0')}-${_birthday.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Login PIN (4-6 digits)',
                  border: OutlineInputBorder(),
                  helperText: 'Child will use this PIN to log in',
                ),
                validator: (v) {
                  if (v == null || v.length < 4) return 'At least 4 digits';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _uploading ? null : _save,
                  child: _uploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Add Child'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
