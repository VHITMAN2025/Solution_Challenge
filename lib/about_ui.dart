import 'package:flutter/material.dart';

class AboutUsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset('assets/voting.png', height: 150),
                  const SizedBox(height: 10),
                  const Text(
                    'The Importance of Voting in India',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Voting is a fundamental right in India. It empowers citizens to choose their leaders and shape the future of the country. Participating in elections strengthens democracy and ensures representation for all.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Our Team',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _buildTeamMember('Vijay Raj', 'Project Manager', 'assets/ravi.jpg'),
                _buildTeamMember('Vennela', 'Lead Developer', 'assets/priya.jpg'),
                _buildTeamMember('Prasunna', 'UI/UX Designer', 'assets/arjun.jpg'),
                _buildTeamMember('Yoshitha', 'Data Analyst', 'assets/meera.jpg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, String imagePath) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 30,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(role),
      ),
    );
  }
}
