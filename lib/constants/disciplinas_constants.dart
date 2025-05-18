class DisciplinasConstants {
  static const Map<String, List<String>> disciplinasEAssuntos = {
    'Língua Portuguesa': [
      'Compreensão e Interpretação de Textos',
      'Ortografia e Acentuação',
      'Pontuação',
      'Concordância Verbal e Nominal',
      'Regência Verbal e Nominal',
      'Crase',
      'Redação Oficial'
    ],
    'Raciocínio Lógico': [
      'Lógica de Proposição',
      'Tabelas Verdade',
      'Diagramas Lógicos',
      'Sequências e Séries Numéricas',
      'Problemas Matemáticos',
      'Probabilidade e Estatística Básica'
    ],
    'Informática': [
      'Conceitos Básicos',
      'Pacote Office (Word, Excel, PowerPoint)',
      'Internet e Intranet',
      'Segurança da Informação',
      'Noções de Redes'
    ],
    'Direito Constitucional': [
      'Princípios Fundamentais',
      'Direitos e Garantias Fundamentais',
      'Organização do Estado',
      'Organização dos Poderes',
      'Controle de Constitucionalidade',
      'Segurança Pública na Constituição'
    ],
    'Direito Administrativo': [
      'Atos Administrativos',
      'Poderes da Administração',
      'Organização Administrativa',
      'Licitações e Contratos',
      'Servidores Públicos',
      'Responsabilidade Civil do Estado'
    ],
    'Direito Penal': [
      'Parte Geral do Código Penal',
      'Crimes contra a Pessoa',
      'Crimes contra o Patrimônio',
      'Crimes contra a Administração Pública',
      'Lei de Drogas (Lei nº 11.343/2006)',
      'Lei de Tortura (Lei nº 9.455/1997)',
      'Estatuto do Desarmamento (Lei nº 10.826/2003)',
      'Crimes Hediondos (Lei nº 8.072/1990)'
    ],
    'Direito Processual Penal': [
      'Inquérito Policial',
      'Ação Penal',
      'Prisão em Flagrante, Temporária e Preventiva',
      'Provas',
      'Procedimentos no Processo Penal',
      'Recursos'
    ],
    'Legislação Especial': [
      'Lei Maria da Penha (Lei nº 11.340/2006)',
      'Lei de Drogas (Lei nº 11.343/2006)',
      'Estatuto da Criança e do Adolescente (ECA)',
      'Código de Trânsito Brasileiro (CTB)',
      'Legislação de Crimes Militares (se aplicável)',
      'Estatuto da Igualdade Racial'
    ],
    'Direitos Humanos': [
      'Declaração Universal dos Direitos Humanos',
      'Tratados e Convenções Internacionais',
      'Direitos Humanos na Constituição Brasileira',
      'Uso da Força Policial',
      'Direitos Humanos e a Atividade Policial'
    ],
    'Noções de Criminalística': [
      'Local de Crime',
      'Vestígios',
      'Preservação de Local',
      'Cadeia de Custódia'
    ],
    'Noções de Medicina Legal': [
      'Tanatologia',
      'Lesões Corporais',
      'Sexologia Forense',
      'Toxicologia Forense'
    ],
    'Legislação Institucional': [
      'Normas da Polícia Federal / Polícia Civil / Polícia Militar (varia conforme edital)',
      'Código de Ética e Disciplina da Corporação'
    ]
  };

  static List<String> getAssuntos(String disciplina) {
    return disciplinasEAssuntos[disciplina] ?? [];
  }

  static List<String> getDisciplinas() {
    return disciplinasEAssuntos.keys.toList();
  }
}
