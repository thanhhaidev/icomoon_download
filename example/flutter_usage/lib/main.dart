import 'package:flutter/material.dart';

import 'ui/icons_v1.dart';
import 'ui/icons_v2.dart';

void main() {
  runApp(const IcoMoonExampleApp());
}

class IcoMoonExampleApp extends StatelessWidget {
  const IcoMoonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IcoMoon v1 + v2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const IconGalleryPage(),
    );
  }
}

class IconGalleryPage extends StatelessWidget {
  const IconGalleryPage({super.key});

  static const _v1Icons = [
    (name: 'home', icon: V1Icons.home),
    (name: 'office', icon: V1Icons.office),
    (name: 'newspaper', icon: V1Icons.newspaper),
    (name: 'pencil', icon: V1Icons.pencil),
    (name: 'quill', icon: V1Icons.quill),
    (name: 'blog', icon: V1Icons.blog),
    (name: 'image', icon: V1Icons.image),
    (name: 'camera', icon: V1Icons.camera),
  ];

  static const _v2Icons = [
    (name: 'bookmark', icon: V2Icons.bookmark),
    (name: 'policeLight', icon: V2Icons.policeLight),
    (name: 'bell', icon: V2Icons.bell),
    (name: 'alarmClock', icon: V2Icons.alarmClock),
    (name: 'idCard', icon: V2Icons.idCard),
    (name: 'users', icon: V2Icons.users),
    (name: 'userAdd', icon: V2Icons.userAdd),
    (name: 'fire', icon: V2Icons.fire),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IcoMoon icon gallery'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'v1 · 491 icons'),
              Tab(text: 'v2 · 70 glyphs'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _IconSetView(
              version: 'IcoMoon v1',
              family: V1Icons.iconFontFamily,
              source: 'icons[].properties',
              icons: _v1Icons,
            ),
            _IconSetView(
              version: 'IcoMoon v2',
              family: V2Icons.iconFontFamily,
              source: 'glyphs[].extras',
              icons: _v2Icons,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconSetView extends StatelessWidget {
  const _IconSetView({
    required this.version,
    required this.family,
    required this.source,
    required this.icons,
  });

  final String version;
  final String family;
  final String source;
  final List<({String name, IconData icon})> icons;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Font family: $family'),
                Text('JSON source: $source'),
                const SizedBox(height: 16),
                const Text(
                  'These icons were downloaded and generated from the '
                  'matching IcoMoon JSON and TTF files.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: icons.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            mainAxisExtent: 132,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = icons[index];
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
