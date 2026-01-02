import 'package:lindelany/signIn&out/authService.dart';
import 'package:url_launcher/url_launcher.dart';

class Delete_account{

  static Future<void> openDeleteAccountPage() async {

    const deletePageUrl = 'https://patience-da636.web.app/delete_account.html';

    final Uri url = Uri.parse(deletePageUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens in browser
      );
    } else {
      throw 'Could not launch $deletePageUrl';
    }
  }

}
