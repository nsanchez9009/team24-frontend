import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'home_screen.dart';

// Auth Service
class AuthService {
  static String? _token;
  static String? _username;

  static void setToken(String token) {
    _token = token;
  }

  static String? getToken() {
    return _token;
  }

  static void setUsername(String username) {
    _username = username;
  }

  static String? getUsername() {
    return _username;
  }

  static void clear() {
    _token = null;
    _username = null;
  }

  static bool isAuthenticated() {
    return _token != null && _username != null;
  }
}

// Lobby Model
class Lobby {
  final String id;
  final String lobbyId;
  final String name;
  final String className;
  final String school;
  final String host;
  final int maxUsers;
  final int currentUsers;

  Lobby({
    required this.id,
    required this.lobbyId,
    required this.name,
    required this.className,
    required this.school,
    required this.host,
    required this.maxUsers,
    required this.currentUsers,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    return Lobby(
      id: json['_id'] ?? '',
      lobbyId: json['lobbyId'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      className: json['className'] ?? '',
      school: json['school'] ?? '',
      host: json['host'] ?? '',
      maxUsers: json['maxUsers'] ?? 4,
      currentUsers: json['currentUsers'] ?? 0,
    );
  }
}

// Socket Service
class SocketService {
  late IO.Socket socket;
  final String serverUrl;
  List<Lobby> _lobbies = [];

  final Function(List<Lobby>) onLobbiesUpdate;
  final Function(String)? onError;
  final Function(Lobby)? onJoinSuccess;
  final Function()? onDisconnect;

  SocketService({
    required this.serverUrl,
    required this.onLobbiesUpdate,
    this.onError,
    this.onJoinSuccess,
    this.onDisconnect,
  }) {
    initSocket();
  }

  void initSocket() {
    debugPrint('📡 Connecting to: $serverUrl');

    socket = IO.io(serverUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'auth': {
        'token': AuthService.getToken(),
      },
    });

    socket.onConnect((_) {
      debugPrint('✅ Socket connected | ID: ${socket.id}');
    });

    socket.onConnectError((error) {
      debugPrint('❌ Connection Error: $error');
      onError?.call('Connection error: Please check your internet connection');
    });

    socket.onDisconnect((_) {
      debugPrint('❌ Socket disconnected');
      onDisconnect?.call();
    });

    socket.on('updateLobbyList', (_) {
      _fetchLobbies();
    });

    socket.on('lobbyCreated', (data) {
      debugPrint('✅ Lobby created: $data');
      _fetchLobbies();
    });

    socket.on('lobbyJoined', (data) {
      debugPrint('✅ Joined lobby: $data');
      try {
        final lobby = Lobby.fromJson(data);
        onJoinSuccess?.call(lobby);
      } catch (e) {
        debugPrint('❌ Error parsing join response: $e');
      }
    });

    socket.on('lobbyError', (message) {
      debugPrint('❌ Lobby error: $message');
      onError?.call(message.toString());
    });
  }

  Future<void> _fetchLobbies() async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/lobbies/list'),
        headers: {
          'Authorization': 'Bearer ${AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _lobbies = data.map((json) => Lobby.fromJson(json)).toList();
        onLobbiesUpdate(_lobbies);
      } else {
        onError?.call('Failed to fetch lobbies');
      }
    } catch (e) {
      onError?.call('Error fetching lobbies: $e');
    }
  }

  Future<void> createLobby(Map<String, dynamic> lobbyData) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/lobbies/create'),
        headers: {
          'Authorization': 'Bearer ${AuthService.getToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode(lobbyData),
      );

      if (response.statusCode == 200) {
        final newLobby = Lobby.fromJson(json.decode(response.body));
        socket.emit('lobbyCreated', newLobby.lobbyId);
        _fetchLobbies();
      } else {
        onError?.call('Failed to create lobby');
      }
    } catch (e) {
      onError?.call('Error creating lobby: $e');
    }
  }

  Future<void> joinLobby(String lobbyId, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/lobbies/join'),
        headers: {
          'Authorization': 'Bearer ${AuthService.getToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'lobbyId': lobbyId,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        socket.emit('joinLobby', {
          'lobbyId': lobbyId,
          'username': username,
        });
      } else {
        onError?.call('Failed to join lobby');
      }
    } catch (e) {
      onError?.call('Error joining lobby: $e');
    }
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}

// Lobby Page
class LobbyPage extends StatefulWidget {
  final String className;
  final String school;

  const LobbyPage({
    Key? key,
    required this.className,
    required this.school,
  }) : super(key: key);

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  List<Lobby> lobbies = [];
  String? error;
  bool isLoading = true;
  late SocketService socketService;

  @override
  void initState() {
    super.initState();
    _initializeSocketService();
    _fetchInitialLobbies();
    _initializeUserData();
  }

  void _initializeSocketService() {
    socketService = SocketService(
      serverUrl: 'https://studybuddy.ddns.net',
      onLobbiesUpdate: (updatedLobbies) {
        setState(() {
          lobbies = updatedLobbies;
          isLoading = false;
        });
      },
      onError: (errorMessage) {
        setState(() {
          error = errorMessage;
          isLoading = false;
        });
      },
      onJoinSuccess: (lobby) {
        Navigator.pushNamed(
          context,
          '/lobby/${lobby.lobbyId}',
          arguments: {
            'lobbyId': lobby.lobbyId,
            'lobbyName': lobby.name,
            'className': widget.className,
            'school': widget.school,
            'username': AuthService.getUsername(),
          },
        );
      },
      onDisconnect: () {
        setState(() {
          error = 'Disconnected from server';
        });
      },
    );
  }

  Future<void> _fetchInitialLobbies() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://studybuddy.ddns.net/api/lobbies/list?className=${widget.className}&school=${widget.school}'),
        headers: {
          'Authorization': 'Bearer ${AuthService.getToken()}',
        },
      );

      debugPrint(
          'getting lobbies from ${widget.className} and ${widget.school}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          lobbies = data.map((json) => Lobby.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load lobbies';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading lobbies';
        isLoading = false;
      });
    }
  }

  Future<void> _initializeUserData() async {
    try {
      final token = AuthService.getToken();
      if (token == null) {
        setState(() {
          error = 'Not authenticated';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://studybuddy.ddns.net/api/user/getuser'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        AuthService.setUsername(userData['username']);
      } else {
        setState(() {
          error = 'Failed to get user data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching user data';
        isLoading = false;
      });
    }
  }

  void _showCreateLobbyDialog() {
    String lobbyName = '';
    int maxUsers = 4;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Lobby'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Lobby Name'),
                onChanged: (value) => lobbyName = value,
              ),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: maxUsers,
                items: [2, 3, 4]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text('$e players'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      maxUsers = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (lobbyName.isNotEmpty) {
                  final username = AuthService.getUsername();
                  if (username != null) {
                    socketService.createLobby({
                      'name': lobbyName,
                      'className': widget.className,
                      'school': widget.school,
                      'host': username,
                      'maxUsers': maxUsers,
                    });
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'STUDY BUDDY',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, size: 30),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreenState()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Classes'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Available Lobbies for ${widget.className}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showCreateLobbyDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6193A9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Lobby',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Expanded(
                    child: lobbies.isEmpty
                        ? const Center(
                            child: Text(
                              'No lobbies available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: lobbies.length,
                            itemBuilder: (context, index) {
                              final lobby = lobbies[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(lobby.name),
                                  subtitle: Text('Host: ${lobby.host}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${lobby.currentUsers}/${lobby.maxUsers}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (lobby.currentUsers < lobby.maxUsers)
                                        ElevatedButton(
                                          onPressed: () {
                                            final username =
                                                AuthService.getUsername();
                                            if (username == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please log in first'),
                                                ),
                                              );
                                              return;
                                            }
                                            socketService.joinLobby(
                                              lobby.lobbyId,
                                              username,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF6193A9),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text('Join'),
                                        )
                                      else
                                        TextButton(
                                          onPressed: null,
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.grey,
                                          ),
                                          child: const Text('Full'),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }
}
