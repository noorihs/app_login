import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;
  final String? userEmail;

  const HomeScreen({
    Key? key,
    this.initialUserData,
    this.userEmail,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _email;
  String? _fullName;
  String? _photoUrl;
  String? _userId;
  bool _isLoading = true;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialUserData != null) {
      setState(() {
        _email = widget.userEmail;
        _userId = widget.initialUserData!['id'] ?? '';
        _fullName = widget.initialUserData!['full_name'] ?? 'Utilisateur';
        _photoUrl = widget.initialUserData!['photo_url'];
        _isLoading = false;
      });
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _isLoading = false;
          _loadError = true;
        });
        return;
      }

      final response = await supabase
          .from('users')
          .select('id, full_name, photo_url')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _email = user.email;
        _userId = response?['id'];
        _fullName = response?['full_name'] ?? 'Utilisateur';
        _photoUrl = response?['photo_url'];
        _isLoading = false;
      });

      print('✅ Données utilisateur chargées: $_fullName, $_email');
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
      setState(() {
        _isLoading = false;
        _loadError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _loadError
              ? _buildErrorState()
              : _buildUserContent(authService),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger vos informations',
              style: AppTheme.headingStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _loadError = false;
                });
                _loadUserData();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserContent(AuthService authService) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
              border: Border.all(color: Colors.white38, width: 2),
              image: _photoUrl != null && _photoUrl!.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(_photoUrl!),
                fit: BoxFit.cover,
                onError: (e, s) => {},
              )
                  : null,
            ),
            child: _photoUrl == null || _photoUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white70, size: 60)
                : null,
          ),

          const SizedBox(height: 24),

          Text(
            'Welcome $_fullName!',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Card(
            color: Colors.white10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Text(
                    'Signed in with :',
                    style: AppTheme.inputTextStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _email ?? 'Inconnu',
                    style: AppTheme.inputTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          ElevatedButton.icon(
            onPressed: () {
              if (_userId != null && _email != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      userId: _userId!,
                      userEmail: _email!,
                    ),
                  ),
                ).then((edited) async {
                  if (edited == true) {
                    final updated = await Supabase.instance.client
                        .from('users')
                        .select('id, full_name, photo_url')
                        .eq('email', _email)
                        .maybeSingle();

                    if (updated != null) {
                      setState(() {
                        _userId = updated['id'];
                        _fullName = updated['full_name'];
                        _photoUrl = updated['photo_url'];
                        _isLoading = false;
                      });
                    }
                  }
                });
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit profil'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _showLoginHistory,
            icon: const Icon(Icons.history),
            label: const Text('Historique des connexions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () => authService.signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLoginHistory() async {
    final supabase = Supabase.instance.client;
    if (_userId == null) return;

    final logs = await supabase
        .from('login_logs')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: logs.isEmpty
            ? const Center(
          child: Text(
            'Aucune connexion enregistrée',
            style: TextStyle(color: Colors.white70),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historique des connexions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final timestamp = DateTime.parse(log['created_at']).toLocal();
                  return ListTile(
                    leading: const Icon(Icons.login, color: Colors.white70),
                    title: Text(
                      '${log['method']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${timestamp.toString().split('.')[0]}\nIP: ${log['ip_address'] ?? 'inconnue'}',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    isThreeLine: true,
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
