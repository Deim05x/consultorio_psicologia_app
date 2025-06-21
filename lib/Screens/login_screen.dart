import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

  // Función para iniciar sesión con correo y contraseña
  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Error desconocido';
      });
    }
  }

  // Función para registrarse con correo y contraseña
  Future<void> _register() async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Guardar datos del nuevo usuario en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'uid': userCredential.user!.uid,
      });

      setState(() {
        errorMessage = 'Usuario creado, ahora puedes iniciar sesión.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Error desconocido';
      });
    }
  }

  // Función para iniciar sesión con Google
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Canceló el login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear credencial con tokens de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión con Firebase usando credencial de Google
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      // Verificar si es un nuevo usuario
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .get();

      if (!userDoc.exists) {
        // Si no existe en Firestore, guardarlo
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'nombre': user.displayName,
          'email': user.email,
          'uid': user.uid,
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error al iniciar sesión con Google: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Iniciar sesión'),
            ),
            TextButton(
              onPressed: _register,
              child: const Text('Registrarse'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loginWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Iniciar con Google'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
