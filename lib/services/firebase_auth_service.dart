import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  String get userId => _user?.uid ?? '';
  String get userEmail => _user?.email ?? '';
  String get userName => _user?.displayName ?? 'Usuário';
  String get userPhotoUrl => _user?.photoURL ?? '';

  FirebaseAuthService() {
    // Escuta mudanças no estado de autenticação
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });

    // Usuário atual (se já estiver logado)
    _user = _auth.currentUser;
  }

  // Limpar mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Login com email e senha
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = result.user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleAuthError(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Erro inesperado: ${e.toString()}');
      return false;
    }
  }

  // Registro com email e senha
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Atualiza o nome do usuário
      await result.user?.updateDisplayName(name);
      await result.user?.reload();
      _user = _auth.currentUser;

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleAuthError(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Erro inesperado: ${e.toString()}');
      return false;
    }
  }

  // Login com Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      // Inicia o processo de login
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _setLoading(false);
        return false; // Usuário cancelou
      }

      // Obtém os detalhes de autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Cria uma credencial
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Faz login no Firebase
      final UserCredential result = await _auth.signInWithCredential(credential);
      _user = result.user;

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao fazer login com Google: ${e.toString()}');
      return false;
    }
  }

  // Reset de senha
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.sendPasswordResetEmail(email: email.trim());

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleAuthError(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Erro inesperado: ${e.toString()}');
      return false;
    }
  }

  // Verificar email
  Future<bool> sendEmailVerification() async {
    try {
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao enviar verificação: ${e.toString()}');
      return false;
    }
  }

  // Atualizar perfil
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    try {
      _setLoading(true);

      if (_user != null) {
        await _user!.updateDisplayName(name);
        await _user!.updatePhotoURL(photoUrl);
        await _user!.reload();
        _user = _auth.currentUser;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao atualizar perfil: ${e.toString()}');
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _user = null;
      _clearError();
    } catch (e) {
      _setError('Erro ao fazer logout: ${e.toString()}');
    }
  }

  // Deletar conta
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);

      if (_user != null) {
        await _user!.delete();
        _user = null;
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'requires-recent-login') {
        _setError('Para deletar a conta, você precisa fazer login novamente.');
      } else {
        _handleAuthError(e);
      }
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao deletar conta: ${e.toString()}');
      return false;
    }
  }

  // Métodos auxiliares privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _setError('Usuário não encontrado.');
        break;
      case 'wrong-password':
        _setError('Senha incorreta.');
        break;
      case 'email-already-in-use':
        _setError('Este email já está em uso.');
        break;
      case 'weak-password':
        _setError('A senha é muito fraca.');
        break;
      case 'invalid-email':
        _setError('Email inválido.');
        break;
      case 'too-many-requests':
        _setError('Muitas tentativas. Tente novamente mais tarde.');
        break;
      case 'network-request-failed':
        _setError('Erro de conexão. Verifique sua internet.');
        break;
      case 'requires-recent-login':
        _setError('Para essa ação, você precisa fazer login novamente.');
        break;
      default:
        _setError('Erro de autenticação: ${e.message}');
    }
  }
}
