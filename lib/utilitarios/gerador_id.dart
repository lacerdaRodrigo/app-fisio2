/// Geração de IDs sequenciais no formato `<prefixo><número zero-padded>`
/// (ex.: `A007`, `E012`, `L003`).
///
/// Calcula o próximo ID a partir do **maior número já existente**, em vez de
/// usar `length + 1`. Isso evita colisões/duplicações quando há "buracos" na
/// numeração (ex.: registros removidos) ou quando a contagem da lista não
/// corresponde ao último ID gerado.
class GeradorId {
  /// Retorna o próximo ID para [prefixo] com base em [idsExistentes].
  ///
  /// - [prefixo]: letra(s) que antecedem o número (ex.: `'A'`).
  /// - [idsExistentes]: IDs já usados (ex.: `['A001', 'A003']`).
  /// - [largura]: quantidade mínima de dígitos (padding com zeros). Padrão 3.
  ///
  /// IDs que não começam com [prefixo] ou cujo sufixo não é numérico são
  /// ignorados no cálculo do maior valor.
  static String proximo(
    String prefixo,
    Iterable<String> idsExistentes, {
    int largura = 3,
  }) {
    var maior = 0;
    for (final id in idsExistentes) {
      if (id.length <= prefixo.length || !id.startsWith(prefixo)) continue;
      final numero = int.tryParse(id.substring(prefixo.length));
      if (numero != null && numero > maior) maior = numero;
    }
    return '$prefixo${(maior + 1).toString().padLeft(largura, '0')}';
  }
}
