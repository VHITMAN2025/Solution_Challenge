import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VotersList extends StatelessWidget {
  const VotersList({Key? key, this.employeePartNo}) : super(key: key);
  final int? employeePartNo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voters List')),
      body: SearchList(employeePartNo: employeePartNo), // Use the stateful widget here
    );
  }
}

class SearchList extends StatefulWidget {
  const SearchList({Key? key, this.employeePartNo}) : super(key: key);
  final int? employeePartNo;

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  List _allResults = [];
  List _resultList = [];

  final TextEditingController _searchController = TextEditingController();

 @override
  void initState() {
    super.initState();
    print("Employee Part No in initState: ${widget.employeePartNo}");
    _searchController.addListener(_onSearchChanged);
    _getClientStream(); // Load data initially
  }

  _onSearchChanged() {
    searchResultList();
  }

 searchResultList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var clientSnapShot in _allResults) {
        var name = clientSnapShot['voter_name']?.toString().toLowerCase() ?? '';
        var epicNo = clientSnapShot['voter_epic_no']?.toString().toLowerCase() ?? '';
        String searchText = _searchController.text.toLowerCase();
        if ((name.contains(searchText) || epicNo.contains(searchText)) &&
            clientSnapShot['part_no'] == widget.employeePartNo) {
          showResults.add(clientSnapShot);
        }
      }
    } else {
      showResults = _allResults.where((element) => element['part_no'] == widget.employeePartNo).toList();
    }

    setState(() {
      _resultList = showResults;
    });
  }

 _getClientStream() async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('electoral_roll');

      // Filter by employeePartNo if it's not null
      if (widget.employeePartNo != null) {
        query = query.where('part_no', isEqualTo: widget.employeePartNo);
      }

      var data = await query.get();

      _allResults = data.docs;
      searchResultList();
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

 @override
  Widget build(BuildContext context) {
    print("Employee Part No in Build: ${widget.employeePartNo}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
        title: CupertinoSearchTextField(controller: _searchController),
      ),
      body: SizedBox(
        height: 600.0,
        child: ListView.builder(
          itemCount: _resultList.length,
          itemBuilder: (context, index) {
            // Add alternating background colors
            Color backgroundColor =
                index % 2 == 0
                    ? Colors.grey[200]! // Light grey for even indices
                    : Colors.white; // White for odd indices

            return Container(
              color: backgroundColor,
              child: ListTile(
                title: Text(
                  _resultList[index]['voter_name'],
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black), // Increase name font size
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender: ${_resultList[index]['gender']}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black, // Change gender font color
                      ),
                    ),
                    Text(
                      'Father: ${_resultList[index]['father_name:']}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black, // Change father's name font color
                      ),
                    ),
                    Text(
                      _resultList[index]['is_voted'] == true ? 'Voted' : 'Not Voted Yet',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: _resultList[index]['is_voted'] == true ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  _resultList[index]['voter_epic_no'],
                  style: TextStyle(
                    fontSize: 16.0,
                  ), // Increase epic number font size
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
