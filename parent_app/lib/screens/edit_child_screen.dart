import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bunnybank_parent/models/models.dart';
import 'package:bunnybank_parent/services/auth_service.dart';
import 'package:bunnybank_parent/services/children_service.dart';

class EditChildScreen extends StatefulWidget {
  final Child child;

  const EditChildScreen({super.key, required this.child});

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _pinCtrl;
  late DateTime _birthday;
  Uint8List? _imageBytes;
  String? _imageUrl;
  final _picker = ImagePicker();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final child = widget.child;
    _nameCtrl = TextEditingController(text: child.name);
    _ageCtrl = TextEditingController(text: child.age.toString());
    _pinCtrl = TextEditingController();
    _birthday = DateTime.parse(child.birthday);
    if (child.imageUrl != null && child.imageUrl!.startsWith('data:image')) {
      _imageUrl = child.imageUrl;
      try {
        _imageBytes = base64Decode(child.imageUrl!.split(',').last);
      } catch (_) {}
    }
  }

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

    final pin = _pinCtrl.text.trim();
    setState(() => _saving = true);
    final auth = context.read<AuthService>();
    final service = ChildrenService(auth.api);
    try {
      await service.updateChild(
        childId: widget.child.id,
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text),
        birthday: _birthday.toIso8601String().split('T').first,
        imageUrl: _imageUrl,
      );
      if (pin.length >= 4) {
        await service.updatePin(widget.child.id, pin);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.child.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.person_pin, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Child ID', style: Theme.of(context).textTheme.labelSmall),
                            SelectableText(
                              widget.child.id,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.child.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Child ID copied')),
                          );
                        },
                        tooltip: 'Copy ID',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                  labelText: 'New PIN (optional)',
                  border: OutlineInputBorder(),
                  helperText: 'Leave empty to keep current PIN',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
