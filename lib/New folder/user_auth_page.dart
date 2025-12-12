import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_auth_provider.dart';

class UserAuthPage extends ConsumerStatefulWidget {
  const UserAuthPage({super.key});

  @override
  ConsumerState<UserAuthPage> createState() => _UserAuthPageState();
}

class _UserAuthPageState extends ConsumerState<UserAuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // register
  final regNameC = TextEditingController();
  final regEmailC = TextEditingController();
  final regPassC = TextEditingController();
  final regPhoneC = TextEditingController();

  // login
  final loginEmailC = TextEditingController();
  final loginPassC = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    regNameC.dispose();
    regEmailC.dispose();
    regPassC.dispose();
    regPhoneC.dispose();
    loginEmailC.dispose();
    loginPassC.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    setState(() => loading = true);
    final msg = await ref.read(userAuthProvider.notifier).register(
          name: regNameC.text.trim(),
          email: regEmailC.text.trim(),
          password: regPassC.text.trim(),
          phone: regPhoneC.text.trim(),
        );
    setState(() => loading = false);

    if (msg != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil, Anda sudah login')),
      );
    }
  }

  Future<void> _doLogin() async {
    setState(() => loading = true);
    final msg = await ref.read(userAuthProvider.notifier).login(
          email: loginEmailC.text.trim(),
          password: loginPassC.text.trim(),
        );
    setState(() => loading = false);

    if (msg != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login berhasil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk / Daftar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Register'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(),
          _buildRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: loginEmailC,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: loginPassC,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : _doLogin,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: regNameC,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regEmailC,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regPhoneC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No HP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regPassC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _doRegister,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
