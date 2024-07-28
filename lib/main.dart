import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cillian Myles",
      theme: _themeData(Brightness.light),
      darkTheme: _themeData(Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: const _Page(),
    );
  }
}

ThemeData _themeData(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.grey,
      brightness: brightness,
    ),
    useMaterial3: true,
  );
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  final _tiles = [
    _Tiles.youTube,
    _Tiles.blog,
    _Tiles.twitter,
    _Tiles.gitHub,
    _Tiles.linkedIn,
  ];

  @override
  void dispose() {
    for (final tile in _tiles) {
      tile.focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: <ShortcutActivator, Intent>{
        // Web uses arrows for scrolling by default
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const DirectionalFocusIntent(TraversalDirection.up),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const DirectionalFocusIntent(TraversalDirection.down),
        // Tile shortcuts
        for (final tile in _tiles)
          SingleActivator(tile.keyboardKey): RequestFocusIntent(tile.focusNode),
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Material(
                      type: MaterialType.card,
                      borderRadius: BorderRadius.circular(9999),
                      clipBehavior: Clip.antiAlias,
                      elevation: 16,
                      child: Image.asset('assets/images/cillian.jpg'),
                    ),
                  ),
                  Text(
                    'Dad. Thinker. Engineer.\n'
                    'Building the future of productivity at Superlist ⚡️\n'
                    'Writing about building amazing software experiences with Flutter and Dart! ✨',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  for (final tile in _tiles) ...[
                    const SizedBox(height: 32),
                    _Tile(data: tile),
                  ],
                  const SizedBox(height: 128),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tiles {
  const _Tiles._();

  static final youTube = _TileData(
    icon: const FaIcon(FontAwesomeIcons.youtube),
    title: 'YouTube',
    keyLabel: 'Y',
    keyboardKey: LogicalKeyboardKey.keyY,
    url: Uri.parse('https://www.youtube.com/@IdiomaticBytes'),
  );

  static final blog = _TileData(
    icon: const FaIcon(FontAwesomeIcons.lightbulb),
    title: 'Blog',
    keyLabel: 'B',
    keyboardKey: LogicalKeyboardKey.keyB,
    url: Uri.parse('https://idiomaticbytes.com'),
  );

  static final twitter = _TileData(
    icon: const FaIcon(FontAwesomeIcons.xTwitter),
    title: 'Twitter',
    keyLabel: 'X',
    keyboardKey: LogicalKeyboardKey.keyX,
    url: Uri.parse('https://x.com/IdiomaticBytes'),
  );

  static final gitHub = _TileData(
    icon: const FaIcon(FontAwesomeIcons.github),
    title: 'GitHub',
    keyLabel: 'G',
    keyboardKey: LogicalKeyboardKey.keyG,
    url: Uri.parse('https://github.com/CillianMyles'),
  );

  static final linkedIn = _TileData(
    icon: const FaIcon(FontAwesomeIcons.linkedin),
    title: 'LinkedIn',
    keyLabel: 'L',
    keyboardKey: LogicalKeyboardKey.keyL,
    url: Uri.parse('https://www.linkedin.com/in/cillianmyles'),
  );
}

class _TileData {
  _TileData({
    required this.icon,
    required this.title,
    required this.keyLabel,
    required this.keyboardKey,
    required this.url,
  }) : focusNode = FocusNode(debugLabel: keyLabel);

  final FaIcon icon;
  final String title;
  final String keyLabel;
  final LogicalKeyboardKey keyboardKey;
  final FocusNode focusNode;
  final Uri url;
}

class _Tile extends StatefulWidget {
  const _Tile({
    required this.data,
  });

  final _TileData data;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  static const _tapRegionGroupId = '_Tile';

  @override
  void initState() {
    super.initState();
    widget.data.focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  Future<void> _launchUrl() async {
    final succeeded = await launchUrl(
      widget.data.url,
      webOnlyWindowName: '_blank',
    );
    if (!succeeded) {
      throw Exception('Could not launch ${widget.data.url}');
    }
  }

  void maybeUnfocus() {
    if (widget.data.focusNode.hasFocus) {
      widget.data.focusNode.unfocus();
    }
  }

  void unfocus() {
    widget.data.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 600;
    final Widget icon;

    if (desktop) {
      icon = _KeyButton(
        child: widget.data.focusNode.hasFocus
            ? const Icon(Icons.keyboard_return)
            : Text(widget.data.keyLabel),
      );
    } else {
      icon = widget.data.icon;
    }

    final tile = Actions(
      actions: {
        DismissIntent: CallbackAction(onInvoke: (_) => unfocus()),
      },
      child: TapRegion(
        groupId: _tapRegionGroupId,
        onTapOutside: (_) => maybeUnfocus(),
        child: ListTile(
          focusNode: widget.data.focusNode,
          onTap: _launchUrl,
          leading: icon,
          title: Text(
            widget.data.title,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    return Material(
      type: MaterialType.card,
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: tile,
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primarySize = 22.0;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        border: Border.all(
          width: 1.0,
          color: theme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            offset: const Offset(2, 2),
            blurRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle(
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primaryColor,
          fontSize: primarySize,
          fontWeight: FontWeight.w500,
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: primaryColor,
            size: primarySize,
          ),
          child: child,
        ),
      ),
    );
  }
}
