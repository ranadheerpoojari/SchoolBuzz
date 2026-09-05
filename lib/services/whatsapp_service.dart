import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<bool> share(String message) async {
    // Try WhatsApp direct share first
    final whatsappUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
      return true;
    }

    // Fallback to system share sheet
    await Share.share(message, subject: 'School Update');
    return true;
  }

  static Future<bool> shareToSpecificChat(String phone, String message) async {
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}
