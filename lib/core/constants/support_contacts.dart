import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The one place for Taksh customer-support contacts.
///
/// The admin panel (System > App Contact & Support) is the source of truth:
/// [init] reads the last saved copy at once, then refreshes from
/// `GET /app/contact-info`. If the server cannot be reached the saved copy,
/// or the built-in defaults below, are used, so the app always has working
/// contact details. Nothing here ever throws.
class SupportContacts {
  SupportContacts._();

  // ---- Built-in defaults (used until / unless the server answers) ----------
  static const String _defaultEmail = 'customersupport@takshallinone.in';
  static const String _defaultChatNumber = '918982893690';
  static const String _defaultAddress = 'Bhopal, Madhya Pradesh, India';

  static const String _cacheKey = 'support_contacts_v1';

  static String _email = _defaultEmail;
  static String _chatNumber = _defaultChatNumber;
  static String _phone = '';
  static String _phoneInternational = '';
  static String _address = _defaultAddress;
  static String _hours = '';
  static String _website = '';
  static String _facebook = '';
  static String _instagram = '';

  /// Bumps whenever the details change, so screens can rebuild.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static String get email => _email;

  /// WhatsApp / live-chat number in international format without "+".
  static String get whatsappNumber => _chatNumber;

  /// Optional support phone number as entered by the admin ('' when unset).
  static String get phone => _phone;

  /// Support phone in international format without "+" ('' when unset).
  static String get phoneInternational => _phoneInternational;

  static String get address => _address;
  static String get hours => _hours;
  static String get website => _website;
  static String get facebook => _facebook;
  static String get instagram => _instagram;

  /// WhatsApp chat link, with an optional pre-filled message.
  static Uri whatsappUri([String? message]) => Uri.https(
    'wa.me',
    '/$_chatNumber',
    message == null || message.isEmpty ? null : {'text': message},
  );

  /// `mailto:` link, with optional subject and body.
  static Uri mailtoUri({String? subject, String? body}) {
    final params = <String, String>{
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (body != null && body.isNotEmpty) 'body': body,
    };
    return Uri(
      scheme: 'mailto',
      path: _email,
      query: params.isEmpty
          ? null
          : params.entries
                .map(
                  (e) =>
                      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                )
                .join('&'),
    );
  }

  /// Policy texts are bundled translations that name the default email and
  /// address. This swaps in the live values so they always match the admin.
  static String applyTo(String text) {
    var out = text;
    if (_email != _defaultEmail) out = out.replaceAll(_defaultEmail, _email);
    if (_address != _defaultAddress) {
      out = out
          .replaceAll(_defaultAddress, _address)
          .replaceAll('भोपाल, मध्य प्रदेश, भारत', _address);
    }
    return out;
  }

  /// Loads the saved copy, then refreshes from the server in the background.
  static Future<void> init({required String baseUrl, Dio? dio}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_cacheKey);
      if (saved != null) {
        final json = jsonDecode(saved);
        if (json is Map) _apply(Map<String, dynamic>.from(json));
      }
    } catch (_) {
      // No saved copy: the defaults stay.
    }
    unawaited(refresh(baseUrl: baseUrl, dio: dio));
  }

  /// Fetches the latest details. Returns true when they were updated.
  static Future<bool> refresh({required String baseUrl, Dio? dio}) async {
    try {
      final client =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: const {'Accept': 'application/json'},
            ),
          );
      final response = await client.get<dynamic>('/app/contact-info');
      final body = response.data;
      if (body is! Map || body['success'] != true) return false;
      final data = body['data'];
      if (data is! Map) return false;

      final map = Map<String, dynamic>.from(data);
      _apply(map);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(map));
      } catch (_) {}
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _str(Object? v) => v is String ? v.trim() : '';

  static void _apply(Map<String, dynamic> m) {
    final email = _str(m['email']);
    final chat = _str(m['chat_number']).replaceAll(RegExp(r'\D'), '');
    final address = _str(m['address']);

    _email = email.contains('@') ? email : _defaultEmail;
    _chatNumber = chat.length >= 11 ? chat : _defaultChatNumber;
    _address = address.isNotEmpty ? address : _defaultAddress;
    _phone = _str(m['phone']);
    _phoneInternational = _str(m['phone_international']);
    _hours = _str(m['hours']);
    _website = _str(m['website']);
    _facebook = _str(m['facebook']);
    _instagram = _str(m['instagram']);
    changes.value++;
  }
}
