import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;
import 'package:palette_generator/palette_generator.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

void main() {
  runApp(const ColorSchemeApp());
}

class ColorSchemeApp extends StatelessWidget {
  const ColorSchemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Element Embedding',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const ColorSchemePage(title: 'Flutter Element Embedding'),
    );
  }
}

class ColorSchemePage extends StatefulWidget {
  const ColorSchemePage({super.key, required this.title});

  final String? title;

  @override
  State<ColorSchemePage> createState() => _ColorSchemePageState();
}

class _ColorSchemePageState extends State<ColorSchemePage> {
  Uint8List _imageData = Uint8List(0);
  Scheme _scheme = Scheme.light(Colors.transparent.value);
  final _streamController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();

    final appState = js_util.createDartExport(this);
    js_util.setProperty(js_util.globalThis, 'appState', appState);
    js_util.callMethod(js_util.globalThis, 'onAppInit', []);
  }

  @JSExport()
  StreamController get streamController => _streamController;

  @JSExport()
  void generateColorScheme(Uint8List imageData) async {
    final paletterGenerator = await PaletteGenerator.fromImageProvider(
      Image.memory(imageData).image,
    );

    final fallbackPaletteColor = PaletteColor(const Color.fromRGBO(255, 98, 0, 1.0), 0);
    final scheme = Scheme.light(
      (paletterGenerator.vibrantColor ?? fallbackPaletteColor).color.value,
    );

    setState(() {
      _imageData = imageData;
      _scheme = scheme;
    });

    _streamController.add(scheme);
  }

  String colorToArgbString(Color color) {
    return color.value.toRadixString(16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageData.isEmpty
                ? const Text('Loading image preview...')
                : Image(image: Image.memory(_imageData).image, height: 200),
            const SizedBox(height: 32),
            const Text(
              'The color scheme extracted from the image above is:',
              textScaleFactor: 2,
            ),
            const SizedBox(height: 32),
            _imageData.isEmpty
                ? const Text('Loading color scheme...')
                : Column(children: [
                    Wrap(
                      spacing: 16,
                      children: [
                        _scheme.primary,
                        _scheme.secondary,
                        _scheme.tertiary,
                      ].map(coloredContainer).toList(),
                    ),
                    Wrap(
                      spacing: 16,
                      children: [
                        _scheme.primaryContainer,
                        _scheme.secondaryContainer,
                        _scheme.tertiaryContainer,
                      ].map(coloredContainer).toList(),
                    ),
                  ]),
          ],
        ),
      ),
    );
  }

  Widget coloredContainer(int color) {
    return Container(
      color: Color(color),
      width: 100,
      height: 100,
    );
  }
}
