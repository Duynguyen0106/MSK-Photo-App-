import 'package:shared_preferences/shared_preferences.dart';

/// Tracks explicit photo-upload consent — photos stay on-device by default.
class PhotoConsentService {
  static const _consentKey = 'msk_photo_upload_consent';

  Future<bool> hasUploadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  Future<void> grantUploadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
  }

  Future<void> revokeUploadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, false);
  }
}
