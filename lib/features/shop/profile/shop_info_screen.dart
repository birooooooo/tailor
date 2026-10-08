import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../providers/shop_provider.dart';

/// Edit the shop: owner, name, phone, address, logo and map location.
class ShopInfoScreen extends StatefulWidget {
  const ShopInfoScreen({super.key});

  @override
  State<ShopInfoScreen> createState() => _ShopInfoScreenState();
}

class _ShopInfoScreenState extends State<ShopInfoScreen> {
  late final ShopProvider _shop = context.read<ShopProvider>();
  late final TextEditingController _owner;
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  String _logoPath = '';

  @override
  void initState() {
    super.initState();
    final p = _shop.profile;
    _owner = TextEditingController(text: p.ownerName);
    _name = TextEditingController(text: p.shopName);
    _phone = TextEditingController(text: p.phone);
    _address = TextEditingController(text: p.address);
    _lat = TextEditingController(text: p.lat?.toString() ?? '');
    _lng = TextEditingController(text: p.lng?.toString() ?? '');
    _logoPath = p.logoPath;
  }

  @override
  void dispose() {
    for (final c in [_owner, _name, _phone, _address, _lat, _lng]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 85,
      );
      if (picked != null) setState(() => _logoPath = picked.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('وێنە هەڵبژێردرا نییە ($e)')));
      }
    }
  }

  void _save() {
    final lat = double.tryParse(_lat.text.trim());
    final lng = double.tryParse(_lng.text.trim());
    _shop.update(
      _shop.profile.copyWith(
        ownerName: _owner.text.trim(),
        shopName: _name.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        logoPath: _logoPath,
        lat: lat,
        lng: lng,
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('زانیاری دوکان پاشەکەوتکرا')));
    Navigator.of(context).maybePop();
  }

  Future<void> _openMap() async {
    final lat = double.tryParse(_lat.text.trim());
    final lng = double.tryParse(_lng.text.trim());
    final url = (lat != null && lng != null)
        ? 'https://www.google.com/maps?q=$lat,$lng'
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_address.text.trim())}';
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نەتوانرا نەخشە بکرێتەوە')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('زانیاری دوکان')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickLogo,
              child: Column(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      gradient: AppColors.brand,
                      shape: BoxShape.circle,
                      image: _logoPath.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(File(_logoPath)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _logoPath.isEmpty
                        ? const Icon(
                            Icons.add_a_photo_rounded,
                            color: Colors.white,
                            size: 34,
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لۆگۆی دوکان (بگۆڕە)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _field('ناوی خاوەن', _owner, 'ناوی خاوەن'),
          _field('ناوی دوکان', _name, 'ناوی دوکان'),
          _field(
            'ژمارەی مۆبایل',
            _phone,
            '0770 000 0000',
            keyboard: TextInputType.phone,
          ),
          _field('ناونیشان', _address, 'شار / گەرەک'),
          SectionHeader(title: 'شوێن لە نەخشە'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _field('Latitude', _lat, '36.19', compact: true)),
              const SizedBox(width: 10),
              Expanded(
                child: _field('Longitude', _lng, '44.01', compact: true),
              ),
            ],
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _openMap,
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('بینین لە گووگڵ مەپس'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('پاشەکەوتکردن'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    String hint, {
    TextInputType? keyboard,
    bool compact = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          TextField(
            controller: c,
            keyboardType: keyboard,
            decoration: InputDecoration(
              labelText: compact ? label : null,
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }
}
