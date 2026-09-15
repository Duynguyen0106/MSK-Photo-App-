import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/body_part.dart';
import '../models/check_in.dart';
import '../models/pose_result.dart';
import 'disclaimer_service.dart';

/// Builds patient and clinician PDF summaries — observations only.
class PdfService {
  /// Simple one-page patient summary.
  Future<Uint8List> buildPatientPdf(CheckIn checkIn) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Check-In Summary',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 16),
            pw.Text('Date: ${_formatDate(checkIn.date)}'),
            pw.SizedBox(height: 12),
            pw.Text('Pain score: ${checkIn.painScore} out of 10',
                style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Text('Areas you selected:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(_areaLabels(checkIn.selectedParts)),
            pw.SizedBox(height: 12),
            pw.Text('Posture note:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(_postureOneLiner(checkIn)),
            pw.SizedBox(height: 12),
            pw.Text('Self-care guidance:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ..._selfCareGuidance(checkIn).map(pw.Text.new),
            pw.Spacer(),
            pw.Divider(),
            pw.Text(
              DisclaimerService.fullDisclaimer,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  /// Multi-page clinician documentation PDF.
  ///
  /// Pass [previousCheckIn] to include a session comparison section.
  Future<Uint8List> buildClinicianPdf(
    CheckIn checkIn, {
    List<String> photoPaths = const [],
    String? patientName,
    CheckIn? previousCheckIn,
  }) async {
    final paths = photoPaths.isNotEmpty ? photoPaths : checkIn.photoPaths;
    final overlayImages = await _loadOverlayImages(checkIn, paths);
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        footer: (context) => _disclaimerFooter(),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('MSK Session Record')),
          pw.SizedBox(height: 8),
          _patientInfoBlock(checkIn, patientName),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('Symptom detail')),
          _symptomTable(checkIn),
          if (overlayImages.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(level: 1, child: pw.Text('Landmark overlay images')),
            ...overlayImages.map(
              (entry) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(entry.label,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Image(entry.image, height: 220),
                  pw.SizedBox(height: 12),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('Measurements')),
          _measurementTable(checkIn),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('L/R deltas')),
          _lrDeltaTable(checkIn),
          if (previousCheckIn != null) ...[
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('Session comparison')),
            _sessionComparison(checkIn, previousCheckIn),
          ],
          if (checkIn.notes != null && checkIn.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('Clinical notes')),
            pw.Text(checkIn.notes!),
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ---------------------------------------------------------------------------
  // Patient PDF helpers
  // ---------------------------------------------------------------------------

  String _areaLabels(List<BodyPart> parts) {
    if (parts.isEmpty) return 'None recorded';
    return parts.map(labelFor).join(', ');
  }

  String _postureOneLiner(CheckIn checkIn) {
    if (checkIn.observations.isNotEmpty) {
      return checkIn.observations.first.text;
    }
    if (checkIn.poseResults.any((r) => r.success)) {
      return 'We recorded posture data from your on-device photos.';
    }
    return 'No posture data was recorded for this session.';
  }

  List<String> _selfCareGuidance(CheckIn checkIn) {
    final tips = <String>[
      'Take breaks from activities that you reported make discomfort worse.',
      'Use gentle movement during the day if it feels comfortable to you.',
      'Contact a healthcare provider if what you feel gets worse.',
    ];
    if (checkIn.aggravators.isNotEmpty) {
      tips.insert(
        0,
        'You reported these make it worse: ${checkIn.aggravators.join(', ')}.',
      );
    }
    return tips;
  }

  // ---------------------------------------------------------------------------
  // Clinician PDF blocks
  // ---------------------------------------------------------------------------

  pw.Widget _disclaimerFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        DisclaimerService.clinicianDisclaimer,
        style: const pw.TextStyle(fontSize: 8),
      ),
    );
  }

  pw.Widget _patientInfoBlock(CheckIn checkIn, String? patientName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Patient: ${patientName ?? checkIn.patientId ?? 'Not linked'}'),
        if (checkIn.patientId != null)
          pw.Text('Patient ID: ${checkIn.patientId}'),
        pw.Text('Session date: ${_formatDate(checkIn.date)}'),
        pw.Text('Check-in ID: ${checkIn.id}'),
      ],
    );
  }

  pw.Widget _symptomTable(CheckIn checkIn) {
    return pw.TableHelper.fromTextArray(
      headers: ['Field', 'Recorded value'],
      data: [
        ['Pain score', '${checkIn.painScore}/10'],
        ['Duration', _durationLabel(checkIn.durationKey)],
        ['Selected regions', _areaLabels(checkIn.selectedParts)],
        ['Aggravators', checkIn.aggravators.join(', ')],
        ['Red flags reported', checkIn.redFlags.join(', ')],
        ['Photo captured', checkIn.hasPhoto ? 'Yes' : 'No'],
      ],
    );
  }

  pw.Widget _measurementTable(CheckIn checkIn) {
    final rows = <List<String>>[];
    for (final result in checkIn.poseResults.where((r) => r.success)) {
      for (final entry in result.measurements.entries) {
        if (entry.value == null) continue;
        final band = _referenceBands[entry.key];
        final valueStr = _formatMeasurement(entry.value!);
        final refStr = band != null
            ? '${band.low}-${band.high} ${band.unit}'
            : '-';
        final inBand = band != null && _inBand(entry.value!, band);
        rows.add([
          band?.label ?? entry.key,
          valueStr,
          refStr,
          inBand ? 'Within reference band' : 'Outside reference band',
        ]);
      }
    }
    if (rows.isEmpty) {
      return pw.Text('No measurements recorded for this session.');
    }
    return pw.TableHelper.fromTextArray(
      headers: ['Measurement', 'Value', 'Reference band', 'Band check'],
      data: rows,
    );
  }

  pw.Widget _lrDeltaTable(CheckIn checkIn) {
    final rows = <List<String>>[];
    for (final result in checkIn.poseResults.where((r) => r.success)) {
      final leftSh = result.landmarkPixels[BodyPart.leftShoulder];
      final rightSh = result.landmarkPixels[BodyPart.rightShoulder];
      if (leftSh != null && rightSh != null) {
        rows.add([
          'Shoulder height (px)',
          leftSh.dy.toStringAsFixed(1),
          rightSh.dy.toStringAsFixed(1),
          (leftSh.dy - rightSh.dy).abs().toStringAsFixed(1),
        ]);
      }
      final leftHip = result.landmarkPixels[BodyPart.leftHip];
      final rightHip = result.landmarkPixels[BodyPart.rightHip];
      if (leftHip != null && rightHip != null) {
        rows.add([
          'Hip height (px)',
          leftHip.dy.toStringAsFixed(1),
          rightHip.dy.toStringAsFixed(1),
          (leftHip.dy - rightHip.dy).abs().toStringAsFixed(1),
        ]);
      }
      final shoulderDiff = result.measurements['shoulderHeightDiffCm'];
      if (shoulderDiff != null) {
        rows.add([
          'Shoulder height diff (cm)',
          '-',
          '-',
          shoulderDiff.toStringAsFixed(1),
        ]);
      }
    }
    if (rows.isEmpty) {
      return pw.Text('No L/R delta data recorded.');
    }
    return pw.TableHelper.fromTextArray(
      headers: ['Metric', 'Left', 'Right', 'Delta'],
      data: rows,
    );
  }

  pw.Widget _sessionComparison(CheckIn current, CheckIn previous) {
    return pw.TableHelper.fromTextArray(
      headers: ['Metric', 'Previous', 'Current', 'Change'],
      data: [
        [
          'Pain score',
          '${previous.painScore}/10',
          '${current.painScore}/10',
          _deltaLabel(previous.painScore, current.painScore),
        ],
        [
          'Session date',
          _formatDate(previous.date),
          _formatDate(current.date),
          '-',
        ],
        ..._compareMeasurements(previous, current),
      ],
    );
  }

  List<List<String>> _compareMeasurements(CheckIn previous, CheckIn current) {
    final prev = _flattenMeasurements(previous);
    final curr = _flattenMeasurements(current);
    final keys = {...prev.keys, ...curr.keys};
    final rows = <List<String>>[];
    for (final key in keys) {
      final p = prev[key];
      final c = curr[key];
      if (p == null && c == null) continue;
      rows.add([
        _referenceBands[key]?.label ?? key,
        p?.toStringAsFixed(1) ?? '-',
        c?.toStringAsFixed(1) ?? '-',
        p != null && c != null ? (c - p).toStringAsFixed(1) : '-',
      ]);
    }
    return rows;
  }

  Map<String, double> _flattenMeasurements(CheckIn checkIn) {
    final map = <String, double>{};
    for (final result in checkIn.poseResults) {
      for (final e in result.measurements.entries) {
        if (e.value != null) map[e.key] = e.value!;
      }
    }
    return map;
  }

  // ---------------------------------------------------------------------------
  // Image overlay
  // ---------------------------------------------------------------------------

  Future<List<_OverlayImage>> _loadOverlayImages(
    CheckIn checkIn,
    List<String> paths,
  ) async {
    final images = <_OverlayImage>[];
    for (final path in paths) {
      final result = checkIn.poseResults
          .cast<PoseResult?>()
          .firstWhere(
            (r) => r?.imagePath == path,
            orElse: () => checkIn.poseResults.isNotEmpty
                ? checkIn.poseResults.first
                : null,
          );
      final landmarks = result?.landmarkPixels ?? {};
      final bytes = await _renderOverlay(path, landmarks);
      if (bytes != null) {
        images.add(_OverlayImage(
          label: path.split('/').last,
          image: pw.MemoryImage(bytes),
        ));
      }
    }
    return images;
  }

  Future<Uint8List?> _renderOverlay(
    String path,
    Map<BodyPart, Offset> landmarks,
  ) async {
    final file = File(path);
    if (!await file.exists()) return null;

    final raw = await file.readAsBytes();
    final decoded = img.decodeImage(raw);
    if (decoded == null) return null;

    for (final point in landmarks.values) {
      img.drawCircle(
        decoded,
        x: point.dx.round(),
        y: point.dy.round(),
        radius: 6,
        color: img.ColorRgb8(220, 40, 40),
      );
    }

    return Uint8List.fromList(img.encodeJpg(decoded, quality: 85));
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _durationLabel(String key) {
    switch (key) {
      case 'less_than_week':
        return 'Less than 1 week';
      case '1_2_weeks':
        return '1-2 weeks';
      case '3_7_days':
        return '3-7 days';
      case 'more_than_month':
        return 'More than 1 month';
      default:
        return key.replaceAll('_', ' ');
    }
  }

  String _formatMeasurement(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded.toStringAsFixed(1);
  }

  String _deltaLabel(num previous, num current) {
    final diff = current - previous;
    if (diff == 0) return 'No change';
    return diff > 0 ? '+$diff' : '$diff';
  }

  bool _inBand(double value, _ReferenceBand band) =>
      value >= band.low && value <= band.high;

  static const _referenceBands = <String, _ReferenceBand>{
    'shoulderHeightDiffCm': _ReferenceBand(
      label: 'Shoulder height difference',
      low: 0,
      high: 2,
      unit: 'cm',
    ),
    'pelvicTiltDeg': _ReferenceBand(
      label: 'Pelvic tilt',
      low: -5,
      high: 5,
      unit: '°',
    ),
    'kneeAlignmentLeftDeg': _ReferenceBand(
      label: 'Left knee angle',
      low: 170,
      high: 180,
      unit: '°',
    ),
    'kneeAlignmentRightDeg': _ReferenceBand(
      label: 'Right knee angle',
      low: 170,
      high: 180,
      unit: '°',
    ),
    'headLateralOffsetCm': _ReferenceBand(
      label: 'Head lateral offset',
      low: 0,
      high: 3,
      unit: 'cm',
    ),
    'forwardHeadAngleDeg': _ReferenceBand(
      label: 'Forward head angle',
      low: 40,
      high: 55,
      unit: '°',
    ),
    'thoracicKyphosisProxyDeg': _ReferenceBand(
      label: 'Thoracic angle proxy',
      low: 0,
      high: 15,
      unit: '°',
    ),
  };
}

class _ReferenceBand {
  const _ReferenceBand({
    required this.label,
    required this.low,
    required this.high,
    required this.unit,
  });

  final String label;
  final double low;
  final double high;
  final String unit;
}

class _OverlayImage {
  const _OverlayImage({required this.label, required this.image});

  final String label;
  final pw.MemoryImage image;
}
