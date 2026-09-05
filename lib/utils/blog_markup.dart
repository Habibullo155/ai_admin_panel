import 'package:flutter/material.dart';

/// Простая разметка для постов блога — не полноценный HTML/Markdown,
/// специально сделано минимально: жирность через **текст**, цвет через
/// {{#RRGGBB}}текст{{/}}. Не поддерживает вложенность (жирный ВНУТРИ
/// цветного и наоборот) — сознательный компромисс ради простого,
/// предсказуемого парсера без риска багов на сложных случаях.
class BlogMarkupToken {
  final String text;
  final bool bold;
  final Color? color;
  const BlogMarkupToken(this.text, {this.bold = false, this.color});
}

final _markupPattern = RegExp(r'\*\*(.+?)\*\*|\{\{#([0-9A-Fa-f]{6})\}\}(.+?)\{\{/\}\}', dotAll: true);

List<BlogMarkupToken> parseBlogMarkup(String source) {
  final tokens = <BlogMarkupToken>[];
  var lastEnd = 0;
  for (final match in _markupPattern.allMatches(source)) {
    if (match.start > lastEnd) {
      tokens.add(BlogMarkupToken(source.substring(lastEnd, match.start)));
    }
    final boldText = match.group(1);
    final colorHex = match.group(2);
    final coloredText = match.group(3);
    if (boldText != null) {
      tokens.add(BlogMarkupToken(boldText, bold: true));
    } else if (colorHex != null && coloredText != null) {
      tokens.add(BlogMarkupToken(coloredText, color: Color(int.parse('FF$colorHex', radix: 16))));
    }
    lastEnd = match.end;
  }
  if (lastEnd < source.length) {
    tokens.add(BlogMarkupToken(source.substring(lastEnd)));
  }
  return tokens;
}

/// Собирает токены в SelectableText.rich (не Text.rich) — используется
/// на экране просмотра поста, где текст и раньше можно было выделить и
/// скопировать; переключение на разметку не должно тихо отобрать эту
/// возможность. В самом поле редактирования разметка НЕ рендерится,
/// видна как есть, чтобы автор понимал, что реально сохранится.
Widget buildBlogMarkupText(
  String source, {
  required Color baseColor,
  double fontSize = 15.5,
  double height = 1.6,
}) {
  final tokens = parseBlogMarkup(source);
  return SelectableText.rich(
    TextSpan(
      children: tokens
          .map((t) => TextSpan(
                text: t.text,
                style: TextStyle(
                  color: t.color ?? baseColor,
                  fontWeight: t.bold ? FontWeight.w700 : FontWeight.normal,
                  fontSize: fontSize,
                  height: height,
                ),
              ))
          .toList(),
    ),
  );
}
