import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'home_screen.dart';
import 'lobby_chat.dart';

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
  final Function(Lobby)? onCreateSuccess;
  final Function()? onDisconnect;
  final Future<void> Function() onRefresh;

  SocketService({
    required this.serverUrl,
    required this.onLobbiesUpdate,
    required this.onRefresh,
    this.onError,
    this.onJoinSuccess,
    this.onCreateSuccess,
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
      try {
        final lobby = Lobby.fromJson(data);
        onCreateSuccess?.call(lobby);
        _fetchLobbies();
      } catch (e) {
        debugPrint('❌ Error parsing create response: $e');
        onError?.call('Error creating lobby');
      }
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
      debugPrint('📤 Creating lobby with data: $lobbyData');

      final response = await http.post(
        Uri.parse('$serverUrl/api/lobbies/create'),
        headers: {
          'Authorization': 'Bearer ${AuthService.getToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode(lobbyData),
      );

      debugPrint('📥 Create lobby response status: ${response.statusCode}');
      debugPrint('📥 Create lobby response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          final newLobby = Lobby.fromJson(responseData);

          // Emit the socket event with the lobby ID
          socket.emit('lobbyCreated', newLobby.lobbyId);

          // Call the success callback
          onCreateSuccess?.call(newLobby);

          // Refresh the lobby list
          await onRefresh();

          debugPrint('✅ Lobby created successfully: ${newLobby.lobbyId}');
        } catch (parseError) {
          debugPrint('❌ Error parsing lobby response: $parseError');
          onError?.call('Error processing server response');
          return;
        }
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['message'] as String? ?? 'Failed to create lobby';
        } catch (_) {
          errorMessage =
              'Failed to create lobby (Status: ${response.statusCode})';
        }

        debugPrint('❌ Create lobby failed: $errorMessage');
        onError?.call(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Create lobby exception: $e');
      onError?.call('Network error while creating lobby: $e');
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
  final String username;
  final String token;

  const LobbyPage({
    Key? key,
    required this.className,
    required this.school,
    required this.username,
    required this.token,
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
    // Set the authentication info

    debugPrint('Current token: ${AuthService.getToken()}');
    debugPrint('Current username: ${AuthService.getUsername()}');

    AuthService.setToken(widget.token);
    AuthService.setUsername(widget.username);

    _initializeSocketService();
    _fetchInitialLobbies();
  }

  void _initializeSocketService() {
    socketService = SocketService(
      serverUrl: 'https://studybuddy.ddns.net',
      onRefresh: _fetchInitialLobbies,
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
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreenState()),
                      );
                  },
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
                                child: InkWell(
                                  onTap: () async {
                                    final username = AuthService.getUsername();
                                    if (username == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please log in first')),
                                      );
                                      return;
                                    }

                                    if (lobby.currentUsers >= lobby.maxUsers) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('This lobby is full')),
                                      );
                                      return;
                                    }

                                    try {
                                      // First, try to join the lobby through socket
                                      await socketService.joinLobby(lobby.lobbyId, username);
                                      
                                      // If successful, navigate to chat room
                                      if (!mounted) return;
                                      
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LobbyChat(
                                            lobbyId: lobby.lobbyId,
                                            lobbyName: lobby.name,
                                            className: widget.className,
                                            school: widget.school,
                                            username: username,
                                            isHost: lobby.host == username,
                                            maxUsers: lobby.maxUsers,
                                            currentUsers: lobby.currentUsers,
                                          ),
                                        ),
                                      ).then((_) {
                                        // When returning from chat room, refresh lobby list
                                        _fetchInitialLobbies();
                                      });
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to join lobby: ${e.toString()}')),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lobby.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Host: ${lobby.host}',
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${lobby.currentUsers}/${lobby.maxUsers}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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