import 'package:flutter/material.dart';
class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'This privacy policy applies to the Lexi Browser app (hereby referred to as "Application") for mobile devices that was created by Lexi Browser (hereby referred to as "Service Provider") as a Free service. This service is intended for use "AS IS".',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Information Collection and Use'),
            _buildSectionText(
              'The Application collects information when you download and use it. This information may include information such as:\n\n'
                  '- Your device\'s Internet Protocol address (e.g. IP address)\n'
                  '- The pages of the Application that you visit, the time and date of your visit, the time spent on those pages\n'
                  '- The time spent on the Application\n'
                  '- The operating system you use on your mobile device\n\n'
                  'The Application collects your device\'s location, which helps the Service Provider determine your approximate geographical location and make use of it in the following ways:\n\n'
                  '- Geolocation Services: The Service Provider utilizes location data to provide features such as personalized content, relevant recommendations, and location-based services.\n'
                  '- Analytics and Improvements: Aggregated and anonymized location data helps the Service Provider to analyze user behavior, identify trends, and improve the overall performance and functionality of the Application.\n'
                  '- Third-Party Services: Periodically, the Service Provider may transmit anonymized location data to external services. These services assist them in enhancing the Application and optimizing their offerings.\n\n'
                  'The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices, and marketing promotions.',
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Third Party Access'),
            _buildSectionText(
              'Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.\n\n'
                  'Please note that the Application utilizes third-party services that have their own Privacy Policy about handling data. Below are the links to the Privacy Policy of the third-party service providers used by the Application:\n\n'
                  '- Google Play Services\n'
                  '- AdMob\n\n'
                  'The Service Provider may disclose User Provided and Automatically Collected Information:\n\n'
                  '- as required by law, such as to comply with a subpoena, or similar legal process;\n'
                  '- when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;\n'
                  '- with their trusted service providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.',
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Opt-Out Rights'),
            _buildSectionText(
              'You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.',
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Data Retention Policy'),
            _buildSectionText(
              'The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. If you\'d like them to delete User Provided Data that you have provided via the Application, please contact them at app@lexibrowser.com and they will respond in a reasonable time.',
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Children'),
            _buildSectionText(
              'The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.\n\n'
                  'The Application does not address anyone under the age of 13. The Service Provider does not knowingly collect personally identifiable information from children under 13 years of age. In the case the Service Provider discover that a child under 13 has provided personal information, the Service Provider will immediately delete this from their servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact the Service Provider (app@lexibrowser.com) so that they will be able to take the necessary actions.',
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Security'),
            _buildSectionText(
              'The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.',
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Changes'),
            _buildSectionText(
              'This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.\n\n'
                  'This privacy policy is effective as of 2024-06-29.',
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Your Consent'),
            _buildSectionText(
              'By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.',
            ),
            SizedBox(height: 16.0),
            _buildSectionTitle('Contact Us'),
            _buildSectionText(
              'If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at app@lexibrowser.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16),
    );
  }
}