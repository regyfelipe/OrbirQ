# Guia de Contribuição

## 🌟 Bem-vindo!

Primeiramente, obrigado por considerar contribuir para o Orbirq! Pessoas como você fazem do Orbirq uma ferramenta educacional cada vez melhor.

## 📋 Índice

1. [Código de Conduta](#código-de-conduta)
2. [Como Posso Contribuir?](#como-posso-contribuir)
3. [Reportando Bugs](#reportando-bugs)
4. [Sugerindo Melhorias](#sugerindo-melhorias)
5. [Desenvolvimento](#desenvolvimento)
6. [Estilo de Código](#estilo-de-código)
7. [Commits](#commits)
8. [Pull Requests](#pull-requests)

## 📜 Código de Conduta

Este projeto segue um Código de Conduta. Ao participar, espera-se que você respeite este código. 

### Nossos Valores

- **Respeito**: Trate todos com respeito e consideração
- **Inclusão**: Acolhemos todas as pessoas e perspectivas
- **Colaboração**: Trabalhe em conjunto para melhorar o projeto
- **Transparência**: Comunique-se de forma clara e aberta

## 🤝 Como Posso Contribuir?

### 🐛 Reportando Bugs

1. Verifique se o bug já não foi reportado
2. Use o template de bug report
3. Inclua:
   - Versão do Flutter/Dart
   - Passos para reproduzir
   - Comportamento esperado
   - Screenshots (se aplicável)
   - Logs de erro

### 💡 Sugerindo Melhorias

1. Verifique se a sugestão já não existe
2. Use o template de feature request
3. Descreva detalhadamente:
   - O problema que sua sugestão resolve
   - Como funcionaria
   - Possíveis impactos

## 🛠️ Desenvolvimento

### Ambiente Local

1. Fork o repositório
2. Clone seu fork:
```bash
git clone https://github.com/seu-usuario/orbirq.git
```

3. Configure o ambiente:
```bash
flutter pub get
cp .env.example .env
```

4. Crie uma branch:
```bash
git checkout -b feature/sua-feature
```

### Testes

- Execute os testes antes de submeter:
```bash
flutter test
```

- Adicione testes para novas funcionalidades

## 📝 Estilo de Código

### Dart/Flutter

- Siga o [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `camelCase` para variáveis e funções
- Use `PascalCase` para classes
- Mantenha linhas com no máximo 80 caracteres
- Organize imports em blocos:
  ```dart
  // Dart imports
  import 'dart:async';
  
  // Flutter imports
  import 'package:flutter/material.dart';
  
  // Package imports
  import 'package:provider/provider.dart';
  
  // Project imports
  import 'package:orbirq/models/user.dart';
  ```

### Documentação

- Documente classes e métodos públicos
- Use comentários para código complexo
- Mantenha a documentação atualizada

## 💬 Commits

### Formato

```
tipo(escopo): descrição curta

descrição longa (opcional)

footer (opcional)
```

### Tipos

- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação
- `refactor`: Refatoração
- `test`: Testes
- `chore`: Manutenção

### Exemplos

```
feat(auth): adiciona login com Google

fix(ui): corrige layout em telas pequenas

docs(readme): atualiza instruções de instalação
```

## 🚀 Pull Requests

1. Atualize sua branch:
```bash
git fetch upstream
git rebase upstream/main
```

2. Execute os testes:
```bash
flutter test
```

3. Faça push:
```bash
git push origin feature/sua-feature
```

4. Abra o PR:
   - Use o template
   - Vincule issues relacionadas
   - Adicione screenshots se aplicável
   - Aguarde review

### Checklist do PR

- [ ] Testes passando
- [ ] Código documentado
- [ ] Changelog atualizado
- [ ] Conflitos resolvidos
- [ ] Screenshots (se UI)

## ✨ Reconhecimento

Contribuidores serão reconhecidos em:
- README do projeto
- Página de contribuidores
- Release notes

## 📫 Dúvidas?

- Abra uma issue
- Entre em contato com o desenvolvedor:
  - Instagram: [@llippe.r](https://www.instagram.com/llippe.r/)
  - LinkedIn: [Regy Robson](https://www.linkedin.com/in/fepink/)
  - WhatsApp: [(92) 99280-1698](https://wa.me/55992801698)
- Email: contribuicoes@orbirq.com

---

🙏 Obrigado por contribuir! 