class AppConstants {
  // Categorias de gastos
  static const List<String> categories = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Saúde',
    'Casa',
    'Trabalho',
    'Educação',
    'Roupas',
    'Outros',
  ];

  // Ícones para cada categoria
  static const Map<String, String> categoryIcons = {
    'Alimentação': '🍽️',
    'Transporte': '🚗',
    'Lazer': '🎮',
    'Saúde': '⚕️',
    'Casa': '🏠',
    'Trabalho': '💼',
    'Educação': '📚',
    'Roupas': '👕',
    'Outros': '📦',
  };

  // Textos da aplicação
  static const String appName = 'Controle de Gastos';
  static const String loginTitle = 'Bem-vindo!';
  static const String loginSubtitle = 'Gerencie seus gastos de forma inteligente';

  // Chaves para SharedPreferences
  static const String transactionsKey = 'transactions';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';

  // Configurações
  static const int maxTransactionsToShow = 50;
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999.99;

  // Mensagens de erro
  static const String errorEmptyFields = 'Por favor, preencha todos os campos!';
  static const String errorInvalidAmount = 'Valor deve ser maior que zero!';
  static const String errorLoginFailed = 'Email ou senha incorretos!';
  static const String errorSaveData = 'Erro ao salvar dados!';
  static const String errorLoadData = 'Erro ao carregar dados!';

  // Mensagens de sucesso
  static const String successTransactionAdded = 'Transação adicionada com sucesso!';
  static const String successTransactionDeleted = 'Transação removida!';
  static const String successLogin = 'Login realizado com sucesso!';
}
