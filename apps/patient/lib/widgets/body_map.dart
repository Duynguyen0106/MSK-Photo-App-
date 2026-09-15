import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msk_core/msk_core.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

/// Tappable front-view body map loaded from [assetPath].
class BodyMapView extends StatefulWidget {
  const BodyMapView({
    super.key,
    required this.selected,
    required this.onPartTapped,
    this.assetPath = 'assets/body_map.svg',
  });

  final Set<BodyPart> selected;
  final ValueChanged<BodyPart> onPartTapped;
  final String assetPath;

  static const _viewBoxWidth = 200.0;
  static const _viewBoxHeight = 400.0;

  @override
  State<BodyMapView> createState() => _BodyMapViewState();
}

class _BodyMapViewState extends State<BodyMapView> {
  Map<BodyPart, Path>? _paths;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    try {
      final raw = await rootBundle.loadString(widget.assetPath);
      final document = XmlDocument.parse(raw);
      final paths = <BodyPart, Path>{};

      for (final node in document.findAllElements('path')) {
        final id = node.getAttribute('id');
        final d = node.getAttribute('d');
        if (id == null || d == null) continue;

        late final BodyPart part;
        try {
          part = bodyPartFromName(id);
        } catch (_) {
          continue;
        }
        paths[part] = parseSvgPathData(d);
      }

      if (!mounted) return;
      setState(() => _paths = paths);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not load body map');
    }
  }

  void _handleTap(Offset local, Size size) {
    final paths = _paths;
    if (paths == null) return;

    final scaleX = size.width / BodyMapView._viewBoxWidth;
    final scaleY = size.height / BodyMapView._viewBoxHeight;
    final point = Offset(local.dx / scaleX, local.dy / scaleY);

    for (final entry in paths.entries) {
      if (entry.value.contains(point)) {
        widget.onPartTapped(entry.key);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_paths == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * (BodyMapView._viewBoxHeight / BodyMapView._viewBoxWidth);
        final size = Size(width, height);

        return GestureDetector(
          onTapUp: (details) => _handleTap(details.localPosition, size),
          child: CustomPaint(
            size: size,
            painter: _BodyMapPainter(
              paths: _paths!,
              selected: widget.selected,
              primaryColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class _BodyMapPainter extends CustomPainter {
  _BodyMapPainter({
    required this.paths,
    required this.selected,
    required this.primaryColor,
  });

  final Map<BodyPart, Path> paths;
  final Set<BodyPart> selected;
  final Color primaryColor;

  static const _baseFill = Color(0xFFE2E8F0);
  static const _baseStroke = Color(0xFF64748B);
  static const _limbStroke = Color(0xFF94A3B8);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / BodyMapView._viewBoxWidth;
    final scaleY = size.height / BodyMapView._viewBoxHeight;
    canvas.scale(scaleX, scaleY);

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _baseStroke;

    for (final entry in paths.entries) {
      final isSelected = selected.contains(entry.key);
      fillPaint.color = isSelected ? primaryColor.withValues(alpha: 0.55) : _baseFill;
      canvas.drawPath(entry.value, fillPaint);
      canvas.drawPath(entry.value, strokePaint);
    }

    // Limb guide lines (match SVG non-tappable strokes).
    final limbPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = _limbStroke
      ..strokeCap = StrokeCap.round;

    void line(double x1, double y1, double x2, double y2) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), limbPaint);
    }

    line(68, 98, 28, 108);
    line(28, 108, 14, 168);
    line(132, 98, 172, 108);
    line(172, 108, 186, 168);
    line(82, 184, 78, 228);
    line(78, 228, 70, 318);
    line(70, 318, 68, 368);
    line(118, 184, 122, 228);
    line(122, 228, 130, 318);
    line(130, 318, 132, 368);
  }

  @override
  bool shouldRepaint(covariant _BodyMapPainter oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.primaryColor != primaryColor;
  }
}
