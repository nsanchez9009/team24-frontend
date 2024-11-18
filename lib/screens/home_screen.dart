import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session_manager.dart';
import 'package:baseapp/screens/login_screen.dart';
import 'lobbylist_page.dart';
import 'dart:async';


List<dynamic> _schools = []; // update list to display

class HomeScreenState extends StatefulWidget {
  @override
  HomeScreen createState() => HomeScreen();
}

class HomeScreen extends State<HomeScreenState> {
  bool isConfirmed = false;
  String _selectedSchool = ''; // string being searched
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();


  List<dynamic> courses = []; // list of current courses
  String addClass = ''; // string being passed



  @override
  void initState() {
    super.initState();
    fetchUser(); // Call fetchUser when the widget is initialized
  }


void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  // Fetch schools from API
  Future<void> fetchSchools(String query) async {
    final Uri url = Uri.parse('https://studybuddy.ddns.net/api/schools/search?name=$query');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Parse the data to map it into a format that's easy to use
        List<dynamic> parsedSchools = data.map((school) {
          return {
            'name': school['school.name'],
            'city': school['school.city'],
            'state': school['school.state'],
          };
        }).toList();

        setState(() {
        _schools = parsedSchools;
      });

      } else {
        print("Request failed with status: ${response.statusCode}");
        setState(() {
        _schools = [];
      });
        
      }
    } catch (e) {
      print('Error during fetch: $e');
      setState(() {
        _schools = [];
      });
      
    }
  }

  

  Future<void> setSchool(String selectedSchool) async {
  final Uri url = Uri.parse('https://studybuddy.ddns.net/api/user/updateSchool');

  try {
    String? token = await getToken();
    final response = await http.put(
      url,
      body: json.encode({'school': selectedSchool}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      // Assuming the API returns success, you can update the UI as needed
      print('School set successfully');
      setState(() {
        // Update the UI to reflect the selected school only
        _selectedSchool = selectedSchool;
        isConfirmed = true;
        _schools.clear(); // Clear the list if desired
      });
    } else {
      print('Failed to set school');
    }
  } catch (e) {
    print('Error during API request: $e');
  }
}

Future<void> fetchUser() async {
  final Uri url = Uri.parse('https://studybuddy.ddns.net/api/user/getuser');
  
  try {
    String? token = getToken();
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Pass the token in the header
      },
    );

    // Check the response status
    if (response.statusCode == 200) {
      // If successful, print the response body
      var user = json.decode(response.body);
      print('User fetched successfully: $user');
      if (user['school'] != null && user['school'] is String) {
        setState(() {
          _selectedSchool = user['school']; // Display the school if already set
          isConfirmed = true;
        });
      }
      if (user['classes'] != null) {
        setState(() {
          courses = List<String>.from(user['classes']);
        });
      }
      // Optionally, you can handle the user data here
    } else {
      print('Failed to fetch user: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during API request: $e');
  }
}

Future<void> addCourse(String selectedCourse) async {
  final Uri url = Uri.parse('https://studybuddy.ddns.net/api/user/addclass');

  try {
    String? token = await getToken();
    final response = await http.put(
      url,
      body: json.encode({'className': selectedCourse}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      // Assuming the API returns success, you can update the UI as needed
      print('Course set successfully');
      setState(() {
        fetchUser();
      });
    } else {
      print('Failed to set course');
    }
  } catch (e) {
    print('Error during API request: $e');
  }
}

Future<void> deleteCourse(String selectedCourse) async {
  final Uri url = Uri.parse('https://studybuddy.ddns.net/api/user/deleteclass');

  try {
    String? token = await getToken();
    final response = await http.delete(
      url,
      body: json.encode({'className': selectedCourse}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      // Assuming the API returns success, you can update the UI as needed
      print('Course delted successfully');
      setState(() {
        fetchUser();
      });
    } else {
      print('Failed to delete course');
    }
  } catch (e) {
    print('Error during API request: $e');
  }
}


  
  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logout Button (Inside the scroll view)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginState()),
                        );
                        clearToken();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB0C4DE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // School Selection Section
                  Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Choose your School',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const SizedBox(height: 8),

      // Check if the school is confirmed
      isConfirmed
          ? Text('Selected School: $_selectedSchool',style: TextStyle(
          fontSize: 18, 
          color: Color.fromARGB(252, 100, 99, 99),      // Adjust font size
          fontWeight: FontWeight.bold, // Bold text  // Change the color of the text
          letterSpacing: 1.2,  // Add spacing between letters
        ),)
          : Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    fetchSchools(query);  // Trigger search as the user types
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter school name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                // Dropdown for schools if not confirmed
                _schools.isNotEmpty
                    ? Column(
                        children: [
                          DropdownButton<String>(
                            value: _selectedSchool.isEmpty ? null : _selectedSchool,
                            hint: const Text('Select a School'),
                            isExpanded: true,
                            items: _schools.map((school) {
                              final schoolName = '${school['name']} - ${school['city']}, ${school['state']}';
                              return DropdownMenuItem<String>(
                                value: schoolName,
                                child: Text(schoolName),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedSchool = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_selectedSchool.isNotEmpty) {
                                setSchool(_selectedSchool);
                                setState(() {
                                  isConfirmed = true; // Mark as confirmed
                                });
                              }
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      )
                    : const Center(child: Text('No schools found')),
              ],
            ),
      const SizedBox(height: 24),
    ],
  ),
),
 // <-- End of School Selection Section Container

const SizedBox(height: 10),

                  const SizedBox(height: 24),

                  // View Classes Section
                   Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Your Courses',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const SizedBox(height: 1),
      ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 300.0, // Limit the height of the ListView
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: courses.length, // Use the actual length of courseList
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                tileColor: Colors.grey.shade200.withOpacity(0.8),
                title: Text(courses[index]),
                onTap: (){
                  //here add logic in order to get to chat messaging
                  //insead of a select button I mimplemented a on click.

                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LobbyPage(className: courses[index], school: _selectedSchool)),
                  );


                }, 
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      deleteCourse(courses[index]);
                      courses.removeAt(index);
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    ],
  ),
),
                  const SizedBox(height: 24),

                  // Add Course Section
                  Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Add a Course',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      const SizedBox(height: 12),
      
      // Prefix TextField
      TextField(
        controller: _prefixController,
        maxLength: 3,
        decoration: InputDecoration(
          hintText: 'Enter course prefix (3 characters)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        textCapitalization: TextCapitalization.characters, // Ensures input is uppercase
        keyboardType: TextInputType.text,
      ),
      const SizedBox(height: 12),

      // Number TextField
      TextField(
        controller: _numberController,
        maxLength: 4,
        decoration: InputDecoration(
          hintText: 'Enter course number (4 digits)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),

      // Add Course Button
      ElevatedButton(
        onPressed: () {
          String prefix = _prefixController.text.trim();
          prefix = prefix.toUpperCase();
          String number = _numberController.text.trim();

          // Validate prefix and number
          if (prefix.length == 3 && prefix == prefix.toUpperCase() && number.length == 4 && int.tryParse(number) != null) {
            // Merge the prefix and number to form the final course code
            String finalCourseCode = '$prefix$number';
             addCourse(finalCourseCode);

            // Optionally, you can reset both text fields after successful submission
            _prefixController.clear();
            _numberController.clear();
          } else {
            // Show error if validation fails
            _showError("Prefix must be 3 uppercase letters and number must be 4 digits.");
          }
        },
        style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB0C4DE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                  child: const Text('Add Course',
                  style: TextStyle(
                    color: Colors.white,
                  ),),
      ),
      const SizedBox(height: 12),

      // Displaying the added courses (you can remove or modify this as needed)
      if (courses.isNotEmpty) ...[
        const SizedBox(height: 12),
      ],
    ],
  ),
),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
