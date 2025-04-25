import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_type.dart';
import 'dart:developer' as developer;

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _error;
  bool _isLoading = false;
  UserType? _userType;
  User? _currentUser;
  String? _userName;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserType? get userType => _userType;
  User? get currentUser => _currentUser;
  String? get userName => _userName;

  Future<void> initialize() async {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _createInitialProfile(session.user);
      }
    });
  }

  Future<void> _createInitialProfile(User user) async {
    try {
      print('Verificando/criando perfil para usuário ${user.id}');

      final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        print('Perfil não encontrado, criando novo perfil...');

        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'name': user.email?.split('@')[0] ?? 'Usuário',
          'user_type': 'aluno'
        });

        print('Perfil criado com sucesso');
      } else {
        print('Perfil já existe');
      }
    } catch (e, stackTrace) {
      print('=== ERRO AO CRIAR PERFIL ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      print('=== INICIANDO LOGIN ===');
      print('Email: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        print('Login falhou: usuário é null');
        _error = 'Usuário ou senha inválidos';
        return false;
      }

      print('Login bem sucedido. ID do usuário: ${response.user!.id}');
      _currentUser = response.user;

      print('Verificando perfil existente...');
      final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (existingProfile == null) {
        print('Perfil não encontrado, criando novo perfil...');
        final newProfile = {
          'id': response.user!.id,
          'email': response.user!.email,
          'name': response.user!.email?.split('@')[0] ?? 'Usuário',
          'user_type': 'aluno'
        };

        await _supabase.from('profiles').insert(newProfile);
        print('Novo perfil criado com sucesso');

        _userType = UserType.aluno;
        _userName = newProfile['name'];
      } else {
        print('Perfil encontrado: $existingProfile');
        _userType = UserType.fromString(existingProfile['user_type']);
        _userName = existingProfile['name'];
      }

      print('=== LOGIN COMPLETO ===');
      print('Nome: $_userName');
      print('Tipo: ${_userType?.name}');

      return true;
    } catch (e, stackTrace) {
      print('=== ERRO NO LOGIN ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      _error = _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      String name, String email, String password, UserType userType) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      print('=== INICIANDO REGISTRO ===');
      print('Email: $email');

      final existingUser = await _supabase
          .from('profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        print('Email já registrado');
        _error = 'Este email já está cadastrado no sistema';
        return false;
      }

      print('Email disponível, prosseguindo com registro...');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'user_type': userType.name},
      );

      if (response.user == null) {
        print('Falha ao criar usuário no Auth');
        _error = 'Falha ao criar usuário';
        return false;
      }

      print('Usuário criado no Auth com sucesso. ID: ${response.user!.id}');

      try {
        await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'user_type': userType.name,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');

        print('Perfil criado/atualizado com sucesso na tabela profiles');

        _currentUser = response.user;
        _userType = userType;
        _userName = name;

        print('=== REGISTRO COMPLETO COM SUCESSO ===');
        return true;
      } catch (profileError) {
        print('Erro ao criar perfil: $profileError');
        await _supabase.auth.signOut();
        throw profileError;
      }
    } catch (e, stackTrace) {
      print('=== ERRO NO REGISTRO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      _error = _handleError(e);

      try {
        await _supabase.auth.signOut();
      } catch (e) {
        print('Erro ao fazer logout: $e');
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.orbirq://reset-callback/',
      );

      return true;
    } catch (e) {
      _error = _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _userType = null;
    } catch (e) {
      _error = _handleError(e);
    }
    notifyListeners();
  }

  Future<bool> checkCurrentSession() async {
    try {
      final session = _supabase.auth.currentSession;

      if (session != null) {
        _currentUser = session.user;

        final userData = await _supabase
            .from('profiles')
            .select('user_type, name')
            .eq('id', session.user!.id)
            .limit(1) 
            .maybeSingle();

        if (userData != null) {
          _userType = UserType.fromString(userData['user_type']);
          _userName = userData['name'];
          await _createInitialProfile(session.user!);
          return true;
        } else {
          _error = 'Perfil do usuário não encontrado';
          return false;
        }
      }
      return false;
    } catch (e) {
      _error = _handleError(e);
      return false;
    } finally {
      notifyListeners();
    }
  }

  String _handleError(dynamic e) {
    if (e is AuthException) {
      switch (e.message) {
        case 'Invalid login credentials':
          return 'Email ou senha inválidos';
        case 'Email not confirmed':
          return 'Por favor, confirme seu email antes de fazer login';
        case 'User already registered':
          return 'Este email já está cadastrado no sistema';
        case 'Password should be at least 6 characters':
          return 'A senha deve ter pelo menos 6 caracteres';
        case 'Invalid email':
          return 'O email fornecido é inválido';
        case 'Email rate limit exceeded':
          return 'Muitas tentativas. Por favor, aguarde alguns minutos antes de tentar novamente';
        case 'Signup requires a valid password':
          return 'É necessário fornecer uma senha válida';
        case 'Unable to validate email address: invalid format':
          return 'O formato do email é inválido';
        default:
          print('Erro original: ${e.message}'); 
          return 'Erro no cadastro: ${e.message}';
      }
    } else if (e is PostgrestException) {
      switch (e.code) {
        case '23505': 
          return 'Este usuário já existe no sistema';
        case '23502': 
          return 'Por favor, preencha todos os campos obrigatórios';
        default:
          print('Erro Postgres: ${e.message}'); 
          return 'Erro no banco de dados: ${e.message}';
      }
    }
    print('Erro não categorizado: $e');
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }
}
