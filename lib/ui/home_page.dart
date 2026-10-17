import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import 'lib_page.dart';
import 'topic_page.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _query = TextEditingController();
  String _cat = ''; // '' = همه
  Eco? _eco;

  static const _examples = ['دیتابیس', 'ماشین', 'رمزنگاری', 'نقشه', 'تاریخ شمسی', 'دوربین', 'دشمن', 'فاکتور pdf'];

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _libFilter(Lib l) => (_cat.isEmpty || l.cat == _cat) && (_eco == null || l.eco == _eco);

  bool _topicFilter(Topic t) {
    if (_cat.isNotEmpty && t.cat != _cat) return false;
    if (_eco == null) return true;
    return t.libs.any((id) => app.catalog.byId[id]?.eco == _eco);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final q = _query.text;
        final topics = app.index.topics(q, _topicFilter);
        final libs = app.index.libs(q, _libFilter);
        final theme = Theme.of(context);
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('کتابخانه‌ی برنامه‌نویسی آسپار',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${app.catalog.libs.length} کتابخانه و ابزار، ${app.catalog.topics.length} راهنمای فارسی'
                  '${app.catalog.stats['pub_packages'] != null ? '، ${app.catalog.stats['pub_packages']} پکیج آفلاین Dart' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _query,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'جستجو به فارسی یا انگلیسی… مثلاً «ذخیره‌ی پسورد» یا «فیزیک ماشین»',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: q.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(_query.clear),
                          ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in const ['', 'game', 'dev', 'security'])
                    ChoiceChip(
                      label: Text(c.isEmpty ? 'همه‌ی بخش‌ها' : catLabel(c)),
                      selected: _cat == c,
                      onSelected: (_) => setState(() => _cat = c),
                    ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('همه‌ی زبان‌ها'),
                    selected: _eco == null,
                    onSelected: (_) => setState(() => _eco = null),
                  ),
                  for (final e in Eco.values)
                    ChoiceChip(
                      label: Text(ecoLabel(e)),
                      selected: _eco == e,
                      onSelected: (_) => setState(() => _eco = e),
                    ),
                ]),
                if (q.isEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, children: [
                    Text('نمونه: ', style: theme.textTheme.bodySmall),
                    for (final ex in _examples)
                      ActionChip(
                        label: Text(ex, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _query.text = ex),
                      ),
                  ]),
                ],
              ]),
            ),
          ),
          if (topics.isNotEmpty) ...[
            _header(context, 'راهنماهای فارسی', topics.length, Icons.menu_book),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 76,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _TopicCard(topics[i]),
                  childCount: q.isEmpty || topics.length < 8 ? topics.length : 8,
                ),
              ),
            ),
          ],
          _header(context, 'کتابخانه‌ها', libs.length, Icons.inventory_2),
          if (libs.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('چیزی پیدا نشد. کلمه‌ی ساده‌تر یا هم‌معنی را امتحان کن.')),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            sliver: SliverList.builder(
              itemCount: libs.length,
              itemBuilder: (ctx, i) => LibTile(libs[i]),
            ),
          ),
        ]);
      },
    );
  }

  Widget _header(BuildContext context, String title, int count, IconData icon) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$title ($count)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard(this.t);
  final Topic t;

  @override
  Widget build(BuildContext context) {
    final color = catColor(t.cat);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TopicPage(t))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(topicIcon(t.icon), color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5)),
                Text('${catLabel(t.cat)} · ${t.libs.length} کتابخانه',
                    style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class LibTile extends StatelessWidget {
  const LibTile(this.l, {super.key});
  final Lib l;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LibPage(l))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(l.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              const SizedBox(width: 8),
              Tag(ecoLabel(l.eco), color: ecoColor(l.eco)),
              const SizedBox(width: 6),
              Tag(catLabel(l.cat), color: catColor(l.cat)),
              const SizedBox(width: 6),
              l.offline
                  ? const Tag('آفلاین', color: Color(0xFF2E7D32), icon: Icons.offline_pin)
                  : const Tag('نیاز به کش', color: Color(0xFF8D6E63), icon: Icons.cloud_download),
            ]),
            const SizedBox(height: 6),
            Text(l.desc, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                l.isTemplate ? l.id.replaceFirst('tpl_', '') : '${l.id}${l.version.isNotEmpty ? '  ${l.version}' : ''}',
                style: TextStyle(fontFamily: codeFont, fontFamilyFallback: codeFallback, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
