enum UserType {
  aluno,
  professor;

  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => UserType.aluno,
    );
  }

  String get label {
    switch (this) {
      case UserType.professor:
        return 'Professor';
      case UserType.aluno:
        return 'Aluno';
    }
  }
}
