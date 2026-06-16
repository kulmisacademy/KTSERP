import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// KULMIS ERP WhatsApp support line.
class SupportWhatsApp {
  SupportWhatsApp._();

  static const e164 = '+252613609678';
  static const displayNumber = '+252 613 609678';

  static Uri chatUri({String? message}) {
    final digits = e164.replaceAll(RegExp(r'[^\d]'), '');
    final text = message?.trim();
    if (text != null && text.isNotEmpty) {
      return Uri.parse(
        'https://wa.me/$digits?text=${Uri.encodeComponent(text)}',
      );
    }
    return Uri.parse('https://wa.me/$digits');
  }

  static Future<bool> openChat({String? message}) async {
    final uri = chatUri(message: message);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<void> openChatOrSnackBar(
    BuildContext context, {
    required String message,
    required String unavailableMessage,
  }) async {
    final ok = await openChat(message: message);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(unavailableMessage)),
      );
    }
  }
}
