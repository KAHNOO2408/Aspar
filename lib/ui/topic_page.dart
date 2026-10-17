import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import 'home_page.dart';
import 'widgets.dart';

class TopicPage extends StatelessWidget {
  const TopicPage(this.t, {super.key});
  final Topic t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libs = [for (final id in t.libs) if (app.catalog.byId[id] != null) app.catalog.byId[id]!];
    final color = catColor(t.cat);
    return Scaffold(
      appBar: AppBar(title: Text(t.title)),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(topicIcon(t.icon), color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Tag(catLabel(t.cat), color: color),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        for (final s in t.sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.h, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              if (s.p.isNotEmpty) ...[
                const SizedBox(height: 6),
                SelectableText(s.p, style: theme.textTheme.bodyLarge?.copyWith(height: 1.9)),
              ],
              if (s.code.isNotEmpty) CodeBox(s.code),
            ]),
          ),
        if (libs.isNotEmpty) ...[
          const Divider(height: 32),
          Text('کتابخانه‌های این موضوع (${libs.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          for (final l in libs) LibTile(l),
        ],
      ]),
    );
  }
}
