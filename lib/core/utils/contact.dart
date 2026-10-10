import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

String _digits(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');

/// WhatsApp needs an international number. Iraqi local numbers start with `0`;
/// turn `0770…` into `964770…`.
String whatsappNumber(String raw) {
  var d = _digits(raw);
  if (d.startsWith('00')) d = d.substring(2);
  if (d.startsWith('0')) d = '964${d.substring(1)}';
  return d;
}

/// Shows a small sheet offering to call the customer by phone or WhatsApp.
Future<void> showContactOptions(BuildContext context, String rawPhone) async {
  final phone = rawPhone.trim();
  final messenger = ScaffoldMessenger.of(context);

  if (phone.isEmpty) {
    messenger.showSnackBar(const SnackBar(content: Text('ژمارەی مۆبایل نییە')));
    return;
  }

  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    phone,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.call_rounded),
            title: const Text('پەیوەندیکردن بە تەلەفۆن'),
            onTap: () => Navigator.pop(ctx, 'dial'),
          ),
          ListTile(
            leading: const Icon(Icons.chat_rounded),
            title: const Text('پەیوەندیکردن بە واتسئەپ'),
            onTap: () => Navigator.pop(ctx, 'whatsapp'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (!context.mounted || choice == null) return;

  try {
    if (choice == 'dial') {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('نەتوانرا پەیوەندی بکرێت')),
        );
      }
    } else if (choice == 'whatsapp') {
      final uri = Uri.parse('https://wa.me/${whatsappNumber(phone)}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('واتسئەپ لەم ئامێرەدا نییە')),
        );
      }
    }
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('نەتوانرا پەیوەندی بکرێت')),
    );
  }
}
