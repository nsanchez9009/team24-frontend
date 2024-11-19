import 'package:baseapp/screens/lobbylist_page.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class LobbyChat extends StatefulWidget {
  final String lobbyId;
  final String lobbyName;
  final String className;
  final String school;
  final String username;
  final bool isHost;
  final int maxUsers;
  final int currentUsers;

  const LobbyChat({
    Key? key,
    required this.lobbyId,
    required this.lobbyName,
    required this.className,
    required this.school,
    required this.username,
    required this.isHost,
    required this.maxUsers,
    required this.currentUsers,
  }) : super(key: key);

  @override
  _LobbyChatState createState() => _LobbyChatState();
}

class ChatMessage {
  final String username;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.username,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      username: json['username'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class _LobbyChatState extends State<LobbyChat> {
  late IO.Socket socket;
  List<ChatMessage> messages = [];
  List<String> activeUsers = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? error;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  void _initializeSocket() {
    final token = AuthService.getToken();
    
    if (token == null) {
      setState(() {
        error = 'Authentication token not found';
      });
      return;
    }

    // Force a new connection
    socket = IO.io(
      'https://studybuddy.ddns.net',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .enableForceNew() // Force a new connection
        .enableAutoConnect()
        .build()
    );

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socket.onConnect((_) {
      print('Connected to chat');
      setState(() {
        isConnected = true;
        error = null;
      });
      
      // Rejoin the lobby after connection
      socket.emit('joinLobby', {
        'lobbyId': widget.lobbyId,
        'username': widget.username,
      });
    });

    socket.on('userList', (users) {
      if (mounted) {
        setState(() {
          activeUsers = List<String>.from(users);
        });
      }
    });

    socket.on('receiveMessage', (data) {
      print('Received message data: $data');
      if (mounted && data != null) {
        try {
          final newMessage = ChatMessage(
            username: data['username'] ?? 'Unknown',
            text: data['text'] ?? '',  
            timestamp: DateTime.now(),
          );
          
          setState(() {
            messages.add(newMessage);
          });
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } catch (e) {
          print('Error processing received message: $e');
        }
      }
    });

    socket.on('initialMessages', (loadedMessages) {
      print('Received initial messages: $loadedMessages');
      if (mounted && loadedMessages != null) {
        try {
          final List<ChatMessage> initialMessages = (loadedMessages as List)
              .map((msg) => ChatMessage(
                    username: msg['username'] ?? 'Unknown',
                    text: msg['text'] ?? '', 
                    timestamp: msg['timestamp'] != null
                        ? DateTime.parse(msg['timestamp'])
                        : DateTime.now(),
                  ))
              .toList();

          setState(() {
            messages = initialMessages;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } catch (e) {
          print('Error processing initial messages: $e');
        }
      }
    });

    socket.on('lobbyClosed', (_) {
      if (mounted) {
        setState(() {
          error = 'The lobby was closed by the host.';
        });
        Navigator.of(context).pushReplacementNamed('/course-home');
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from chat');
      if (mounted) {
        setState(() {
          isConnected = false;
        });
      }
    });

    socket.on('connect_error', (err) {
      print('Connect error: $err');
      if (mounted) {
        setState(() {
          error = 'Connection error: $err';
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty && isConnected) {
      final messageText = _messageController.text.trim();
      print('Sending message: $messageText');
      
      final message = {
        'lobbyId': widget.lobbyId,
        'message': messageText,
        'username': widget.username,
      };
      
      socket.emit('sendMessage', message);
      _messageController.clear();
      
      
      
      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _leaveLobby() {
    if (isConnected) {
      socket.emit('leaveLobby', {
        'lobbyId': widget.lobbyId,
        'username': widget.username,
      });
    }
    
    // Clean up socket connection
    socket.disconnect();
    socket.dispose();
    
    // Navigate back
    Navigator.of(context).pushReplacementNamed('/course-home');
  }

  @override
  void dispose() {
    // Ensure proper cleanup
    if (socket.connected) {
      socket.emit('leaveLobby', {
        'lobbyId': widget.lobbyId,
        'username': widget.username,
      });
    }
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lobbyName),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _leaveLobby,
          ),
        ],
      ),
      body: error != null
          ? _buildErrorDialog()
          : Row(
              children: [
                _buildUsersList(),
                Expanded(child: _buildChatArea()),
              ],
            ),
    );
  }

  Widget _buildErrorDialog() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Lobby Closed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/course-home'),
                child: const Text('Back to Classes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class: ${widget.className}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'School: ${widget.school}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Active Users:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: activeUsers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person),
                      title: Text(activeUsers[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${message.username}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(message.text)),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isConnected ? _sendMessage : null, // Disable when not connected
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}