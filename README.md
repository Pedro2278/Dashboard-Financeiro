# 💰 PH Finanças - Dashboard Financeiro

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/SQLite-3-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite">
  <img src="https://img.shields.io/badge/BLoC-Pattern-purple?style=for-the-badge" alt="BLoC">
</div>

## 📋 Sobre o Projeto

**PH Finanças** é um aplicativo de gerenciamento financeiro pessoal desenvolvido em Flutter, oferecendo uma interface moderna e intuitiva para controle de receitas e despesas. O app utiliza arquitetura BLoC (Business Logic Component) para gerenciamento de estado e SQLite para persistência local de dados.

### ✨ Principais Funcionalidades

- ✅ **Gestão de Transações**: Cadastro, edição e exclusão de receitas e despesas
- 📊 **Dashboard Visual**: Gráficos e análises financeiras com FL Chart
- 🏷️ **Categorias Personalizadas**: Organize suas transações com categorias customizáveis
- 🎨 **Seletor de Cores**: Interface visual para escolha de cores de categorias
- 🔍 **Filtros Avançados**: Filtre transações por período, categoria e tipo
- 💾 **Persistência Local**: Dados salvos localmente com SQLite
- 🎯 **Material Design 3**: Interface moderna seguindo as diretrizes do Material 3
- 📱 **Responsivo**: Layout adaptável para diferentes tamanhos de tela

## 🏗️ Arquitetura

O projeto segue a arquitetura **BLoC Pattern** para separação de responsabilidades:

```
lib/
├── blocs/                 # Gerenciamento de estado
│   ├── category/          # Lógica de categorias
│   ├── filter/            # Lógica de filtros
│   └── transaction/       # Lógica de transações
├── core/
│   ├── database/          # Configuração SQLite
│   └── utils/             # Utilitários (dicas financeiras, etc.)
├── models/                # Modelos de dados
├── pages/                 # Telas do aplicativo
│   ├── home_page.dart
│   ├── dashboard_page.dart
│   ├── transactions/
│   ├── categories/
│   └── filters/
├── ui/                    # Componentes de UI reutilizáveis
├── widgets/               # Widgets customizados (gráficos)
├── app.dart               # Configuração do app
└── main.dart              # Ponto de entrada
```

### 🔄 Fluxo de Dados (BLoC)

```
UI → Event → BLoC → State → UI
```

## 🛠️ Tecnologias Utilizadas

### Core
- **Flutter 3.10+**: Framework de desenvolvimento cross-platform
- **Dart 3.10+**: Linguagem de programação

### Gerenciamento de Estado
- **flutter_bloc ^8.1.4**: Implementação do padrão BLoC
- **equatable ^2.0.5**: Comparação de objetos imutáveis

### Persistência de Dados
- **sqflite ^2.3.0**: Banco de dados SQLite local
- **path_provider ^2.1.3**: Acesso a diretórios do sistema
- **shared_preferences ^2.0.15**: Armazenamento de preferências

### Visualização de Dados
- **fl_chart ^0.68.0**: Gráficos interativos
- **syncfusion_flutter_charts ^31.2.12**: Gráficos avançados
- **flutter_echarts ^2.5.0**: Biblioteca de gráficos ECharts

### UI/UX
- **cupertino_icons ^1.0.8**: Ícones iOS
- **flutter_colorpicker ^1.0.3**: Seletor de cores
- **device_preview ^1.1.0**: Preview em múltiplos dispositivos
- **data_table_2 ^2.7.1**: Tabelas de dados avançadas

### Integração (Preparado)
- **graphql_flutter ^5.2.0**: Cliente GraphQL (para futuras integrações)

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK 3.10 ou superior
- Dart SDK 3.10 ou superior
- Android Studio / VS Code
- Dispositivo Android/iOS ou Emulador

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/dashboard_financeiro.git
cd dashboard_financeiro
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o aplicativo**
```bash
flutter run
```

### Comandos Úteis

```bash
# Executar em modo debug
flutter run

# Executar em modo release
flutter run --release

# Executar testes
flutter test

# Analisar código
flutter analyze

# Formatar código
flutter format .

# Limpar build
flutter clean
```

## 📱 Telas do Aplicativo

### 1. **Home** (`home_page.dart`)
- Visão geral do saldo atual
- Grid de navegação rápida
- Ações rápidas (Nova transação/categoria)
- Dicas financeiras rotativas

### 2. **Dashboard** (`dashboard_page.dart`)
- Gráficos de receitas e despesas
- Análise de categorias
- KPIs financeiros
- Distribuição visual de gastos

### 3. **Transações** (`transactions_page.dart`)
- Lista completa de transações
- Filtros por data, categoria e tipo
- Edição e exclusão de transações
- Indicadores visuais (receita/despesa)

### 4. **Categorias** (`categories_page.dart`)
- Gerenciamento de categorias
- Seletor de cores personalizadas
- Contador de transações por categoria
- Criação e edição de categorias

### 5. **Filtros** (`filters_page.dart`)
- Filtro por período (semana, mês, ano)
- Filtro por tipo (receita/despesa/todos)
- Filtro por categoria
- Aplicação instantânea de filtros

## 💾 Estrutura do Banco de Dados

### Tabela: `transactions`
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  categoryId INTEGER NOT NULL,
  amount REAL NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  isIncome INTEGER NOT NULL,
  FOREIGN KEY (categoryId) REFERENCES categories(id)
);
```

### Tabela: `categories`
```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  color INTEGER NOT NULL,
  icon TEXT,
  isIncome INTEGER NOT NULL
);
```

## 🎨 Paleta de Cores

O aplicativo utiliza Material Design 3 com a cor primária **Deep Purple**:

- **Primary**: Deep Purple (`Colors.deepPurple`)
- **Background**: `#F6F7FB`
- **Surface**: White
- **Gradientes**: Utilizados em cards e headers para destaque visual

## 📊 Funcionalidades dos BLoCs

### TransactionBloc
- `LoadTransactions`: Carrega todas as transações
- `AddTransaction`: Adiciona nova transação
- `UpdateTransaction`: Atualiza transação existente
- `DeleteTransaction`: Remove transação
- Filtros integrados com `FilterBloc`

### CategoryBloc
- `LoadCategories`: Carrega todas as categorias
- `AddCategory`: Cria nova categoria
- `UpdateCategory`: Edita categoria
- `DeleteCategory`: Remove categoria

### FilterBloc
- `SetDateFilter`: Define filtro de data
- `SetTypeFilter`: Define tipo (receita/despesa/todos)
- `SetCategoryFilter`: Filtra por categoria
- `ClearFilters`: Limpa todos os filtros

## 🔧 Customização

### Adicionar Nova Categoria
```dart
context.read<CategoryBloc>().add(
  AddCategory(
    Category(
      name: 'Salário',
      color: Colors.green.value,
      isIncome: true,
    ),
  ),
);
```

### Adicionar Transação
```dart
context.read<TransactionBloc>().add(
  AddTransaction(
    Transaction(
      categoryId: 1,
      amount: 150.50,
      description: 'Supermercado',
      date: DateTime.now(),
      isIncome: false,
    ),
  ),
);
```

## 🐛 Solução de Problemas

### Banco de dados antigo
Para resetar o banco de dados:
```bash
# Android
adb shell pm clear com.example.dashboard_financeiro

# Ou manualmente:
# Configurações → Aplicativos → Dashboard Financeiro → Armazenamento → Limpar dados
```

### Erros de build
```bash
flutter clean
flutter pub get
flutter run
```

## 📈 Melhorias Futuras

- [ ] Backup/Restauração em nuvem
- [ ] Exportação para PDF/Excel
- [ ] Gráficos comparativos mês a mês
- [ ] Metas de economia
- [ ] Notificações de vencimentos
- [ ] Autenticação de usuário
- [ ] Sincronização multi-dispositivo
- [ ] Modo escuro
- [ ] Suporte a múltiplas moedas

## 👨‍💻 Autor

**Pedro Maia**
- Curso: Análise e Desenvolvimento de Sistemas 2025.2
- Disciplina: PPDM (Programação para Dispositivos Móveis)

## 📄 Licença

Este projeto é um trabalho acadêmico e está disponível para fins educacionais.

---

<div align="center">
  Desenvolvido com ❤️ usando Flutter
</div>
