import 'package:url_launcher/url_launcher.dart';

Future<void> openDialPad(String phoneNumber) async {
  String formattedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: formattedNumber,
  );

  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    print('Could not launch $launchUri');
    throw 'Could not launch $launchUri';
  }
}
