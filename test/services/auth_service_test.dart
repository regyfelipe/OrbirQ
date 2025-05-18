import 'package:flutter_test/flutter_test.dart';
import 'package:orbirq/models/user_type.dart';
import 'package:orbirq/services/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  group('AuthService - Login', () {
    test('deve fazer login com sucesso usando credenciais corretas', () async {
      final result = await authService.login('teste@teste.com', '123456');

      expect(result, true);
      expect(authService.currentUser, 'teste@teste.com');
      expect(authService.error, null);
      expect(authService.isLoading, false);
    });

    test('deve falhar o login com credenciais incorretas', () async {
      final result = await authService.login('wrong@email.com', 'wrongpass');

      expect(result, false);
      expect(authService.currentUser, null);
      expect(authService.error, 'Exception: Credenciais inválidas');
      expect(authService.isLoading, false);
    });
  });

  group('AuthService - Registro', () {
    test('deve registrar um novo usuário com sucesso', () async {
      final result = await authService.register(
        'Test User',
        'new@user.com',
        '123456',
        UserType.aluno,
      );

      expect(result, true);
      expect(authService.currentUser, 'new@user.com');
      expect(authService.error, null);
      expect(authService.isLoading, false);
    });

    test('deve falhar o registro com senha curta', () async {
      final result = await authService.register(
        'Test User',
        'new@user.com',
        '123',
        UserType.aluno,
      );

      expect(result, false);
      expect(authService.currentUser, null);
      expect(authService.error,
          'Exception: A senha deve ter pelo menos 6 caracteres');
      expect(authService.isLoading, false);
    });

    test('deve falhar o registro com email inválido', () async {
      final result = await authService.register(
        'Test User',
        'invalidemail',
        '123456',
        UserType.aluno,
      );

      expect(result, false);
      expect(authService.currentUser, null);
      expect(authService.error, 'Exception: E-mail inválido');
      expect(authService.isLoading, false);
    });

    test('deve falhar o registro com campos vazios', () async {
      final result = await authService.register(
        '',
        '',
        '',
        UserType.aluno,
      );

      expect(result, false);
      expect(authService.currentUser, null);
      expect(authService.error, 'Exception: Todos os campos são obrigatórios');
      expect(authService.isLoading, false);
    });
  });

  group('AuthService - Recuperação de Senha', () {
    test('deve enviar email de recuperação com sucesso', () async {
      final result = await authService.resetPassword('valid@email.com');

      expect(result, true);
      expect(authService.error, null);
      expect(authService.isLoading, false);
    });

    test('deve falhar ao enviar email de recuperação com email inválido',
        () async {
      final result = await authService.resetPassword('invalidemail');

      expect(result, false);
      expect(authService.error, 'Exception: E-mail inválido');
      expect(authService.isLoading, false);
    });

    test('deve falhar ao enviar email de recuperação com email vazio',
        () async {
      final result = await authService.resetPassword('');

      expect(result, false);
      expect(authService.error, 'Exception: O e-mail é obrigatório');
      expect(authService.isLoading, false);
    });
  });

  group('AuthService - Logout', () {
    test('deve fazer logout com sucesso', () async {
      // Primeiro faz login
      await authService.login('teste@teste.com', '123456');
      expect(authService.currentUser, 'teste@teste.com');

      // Depois faz logout
      await authService.logout();
      expect(authService.currentUser, null);
    });
  });
}
