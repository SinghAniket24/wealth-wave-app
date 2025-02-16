import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AnalysisScreen extends StatelessWidget {
  final String colabUrl = "https://colab.research.google.com/drive/1tNfun7In_fZitsk1FHog-Y_zNo_f6kDM?usp=sharing";

  @override
  Widget build(BuildContext context) {
    _launchURL();
    return Scaffold(
      appBar: AppBar(title: Text("Analysis of Nifty 50")),
      body: Center(child: Text("Redirecting to Colab...", style: TextStyle(fontSize: 16))),
    );
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(colabUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $colabUrl";
    }
  }
}
