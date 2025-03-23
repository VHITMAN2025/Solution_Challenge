import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  void searchVoter(String query) async {
    if (query.isEmpty) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('electoral_roll')
        .where('voter_name', isGreaterThanOrEqualTo: query)
        .where('voter_name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      searchResults = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Voter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Enter Voter Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => searchVoter(searchController.text),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  var voter = searchResults[index];
                  return Card(
                    child: ListTile(
                      title: Text(voter['voter_name']),
                      subtitle: Text('Voter ID: ${voter['voter_epic_no']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
