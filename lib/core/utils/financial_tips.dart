import 'dart:math';

class FinancialTips {
  static const List<String> tips = [
    'Economize 10-20% da sua renda mensal. Comece pequeno e aumente gradualmente.',
    'Acompanhe cada gasto por 30 dias. Conhecer os padrões de gastos é o primeiro passo.',
    'Crie um fundo de emergência com 3-6 meses de despesas. Você estará preparado para surpresas.',
    'Use a regra 50/30/20: 50% necessidades, 30% desejos, 20% economias.',
    'Evite compras por impulso. Espere 24h antes de comprar algo que não é essencial.',
    'Cancele assinaturas que não usa. Pequeninhas despesas podem somar muito.',
    'Compare preços antes de comprar. Pesquise e encontre as melhores ofertas.',
    'Pague suas contas no prazo para evitar multas e juros.',
    'Crie um orçamento mensal e mantenha-se disciplinado. Controle seus gastos!',
    'Evite dívidas com juros altos. Se precisar de crédito, procure as melhores taxas.',
    'Invista em sua educação financeira. Aprenda sobre investimentos e planejamento.',
    'Defina metas financeiras claras. Poupança, investimento, ou quitação de dívidas.',
    'Compre genéricos quando possível. A qualidade é semelhante e o preço é menor.',
    'Cozinhe em casa. Refeições caseiras custam bem menos que comer fora.',
    'Use o transporte público. Economize com combustível e estacionamento.',
    'Agrupe suas compras. Fazer uma compra grande economiza mais do que várias pequenas.',
    'Cancele serviços desnecessários. Reavalie regularmente suas despesas.',
    'Automatize suas economias. Configure transferências automáticas para uma conta poupança.',
    'Venda itens que não usa mais. Ganhe dinheiro extra com coisas antigas.',
    'Procure cashback e promoções. Use cartões de crédito que ofereçam benefícios.',
    'Dedique tempo ao planejamento financeiro. Organização é a chave do sucesso.',
    'Envolvam a família no orçamento. Todos devem conhecer os objetivos financeiros.',
    'Negocie suas contas. Telefonemas para provedores podem reduzir suas despesas.',
    'Mantenha registros de suas transações. Organize suas finanças digitalmente.',
    'Comece a investir cedo. O tempo é seu melhor aliado no crescimento financeiro.',
  ];

  static String getRandomTip() {
    final random = Random();
    return tips[random.nextInt(tips.length)];
  }

  static String getTipForDay() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }
}
