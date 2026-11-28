import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _ink = Color(0xFF211B54);
const Color _muted = Color(0xFF66666D);

Future<Uint8List> createTransactionRecordImage(
  Map<String, dynamic> data,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(3);

  canvas.drawColor(const Color(0xFFF1F1F1), BlendMode.src);
  final paper = Paint()..color = Colors.white;
  canvas.drawRect(const Rect.fromLTWH(8, 2, 454, 646), paper);
  canvas.drawRect(
    const Rect.fromLTWH(8, 2, 454, 88),
    Paint()..color = const Color(0xFFFAFAF4),
  );

  final logoBytes = await rootBundle.load('assets/images/common_logo.png');
  final logo = await decodeImageFromList(logoBytes.buffer.asUint8List());
  final logoRect = _containRect(
    Size(logo.width.toDouble(), logo.height.toDouble()),
    const Rect.fromLTWH(27, 16, 88, 51),
  );
  canvas.drawImageRect(
    logo,
    Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
    logoRect,
    Paint()..filterQuality = FilterQuality.high,
  );
  logo.dispose();

  _text(
    canvas,
    'PERSONAL FINANCE RECORD',
    250,
    24,
    183,
    size: 7,
    color: _muted,
    align: TextAlign.right,
    weight: FontWeight.w500,
  );
  _text(
    canvas,
    'Transaction record',
    235,
    39,
    198,
    size: 17,
    color: _ink,
    align: TextAlign.right,
    weight: FontWeight.w700,
  );
  final isIncome =
      (data['type']?.toString().toLowerCase() ?? 'expense') == 'income';
  _text(
    canvas,
    'Single transaction • ${isIncome ? 'Income' : 'Expense'}',
    235,
    63,
    198,
    size: 7,
    color: _muted,
    align: TextAlign.right,
  );

  final accent = isIncome ? const Color(0xFF6D63E8) : const Color(0xFFFFDD32);
  final amountColor = isIncome ? Colors.white : _ink;
  _roundedRect(canvas, const Rect.fromLTWH(36, 106, 402, 91), accent, 10);
  _text(
    canvas,
    'RECORDED ${isIncome ? 'INCOME' : 'EXPENSE'}',
    52,
    120,
    225,
    size: 7,
    color: amountColor.withValues(alpha: .9),
    weight: FontWeight.w600,
  );

  final amount = double.tryParse(data['amount']?.toString() ?? '') ?? 0;
  final amountText = '${isIncome ? '+' : ''}₹${_money(amount)}';
  _text(
    canvas,
    amountText,
    52,
    137,
    280,
    size: 25,
    color: amountColor,
    weight: FontWeight.w700,
  );
  _text(
    canvas,
    'Indian rupees ${_amountInWords(amount)} only',
    52,
    174,
    270,
    size: 7,
    color: amountColor.withValues(alpha: .88),
  );

  _roundedRect(
    canvas,
    const Rect.fromLTWH(359, 119, 63, 20),
    isIncome ? const Color(0xFFE7F7E9) : const Color(0xFFFFF5C5),
    12,
  );
  _text(
    canvas,
    isIncome ? 'Income' : 'Expense',
    359,
    124,
    63,
    size: 8,
    color: isIncome ? const Color(0xFF198A34) : const Color(0xFF725D00),
    align: TextAlign.center,
    weight: FontWeight.w600,
  );
  _text(
    canvas,
    'CATEGORY',
    352,
    155,
    70,
    size: 6,
    color: amountColor.withValues(alpha: .8),
    align: TextAlign.right,
  );
  _text(
    canvas,
    data['category']?.toString() ?? 'Other',
    340,
    168,
    82,
    size: 9,
    color: amountColor,
    align: TextAlign.right,
    weight: FontWeight.w700,
  );

  _text(
    canvas,
    'Payment information',
    36,
    219,
    390,
    size: 11,
    color: _ink,
    weight: FontWeight.w700,
  );
  _line(canvas, 36, 238, 402);

  var y = 246.0;
  y = _recordRow(
    canvas,
    'Transaction title',
    data['title']?.toString() ?? 'Transaction',
    y,
  );
  y = _recordRow(canvas, 'Hisaab ID', data['id']?.toString() ?? '', y);
  y = _recordRow(canvas, 'Date and time', _dateTime(data['createdAt']), y);
  _recordRow(
    canvas,
    'Payment mode',
    data['paymentMode']?.toString() ?? 'Not specified',
    y,
  );

  _roundedRect(
    canvas,
    const Rect.fromLTWH(36, 383, 402, 70),
    const Color(0xFFFAFAF4),
    7,
  );
  _text(
    canvas,
    'Description / Memo',
    48,
    394,
    376,
    size: 8,
    color: _ink,
    weight: FontWeight.w700,
  );
  final description = data['description']?.toString().trim() ?? '';
  _text(
    canvas,
    description.isEmpty ? 'No description added.' : description,
    48,
    410,
    376,
    size: 8,
    color: _muted,
    maxLines: 3,
    lineHeight: 12,
  );
  _text(
    canvas,
    'Note: Keep this record and quote the Hisaab ID for reconciliation.',
    48,
    439,
    376,
    size: 6,
    color: _muted,
  );

  _text(
    canvas,
    'Terms & conditions',
    36,
    477,
    390,
    size: 10,
    color: _ink,
    weight: FontWeight.w700,
  );
  final terms = [
    'This document reflects the transaction recorded in Hisaab Mitra at the time of export.',
    'This is not a tax invoice, bank statement or independent proof of bank settlement.',
    'Verify details against your bank records. Refunds, disputes and taxes are governed by the parties’ agreement and applicable law.',
    'Retain this document for your records and share only with authorised recipients.',
  ];
  var termY = 499.0;
  for (var i = 0; i < terms.length; i++) {
    _text(
      canvas,
      (i + 1).toString().padLeft(2, '0'),
      36,
      termY,
      18,
      size: 6,
      color: const Color(0xFF625BE0),
      weight: FontWeight.w600,
    );
    final height = _text(
      canvas,
      terms[i],
      58,
      termY,
      366,
      size: 6,
      color: _muted,
      maxLines: 2,
      lineHeight: 9,
    );
    termY += height + 4;
  }

  _line(canvas, 36, 599, 402);
  final year = DateTime.now().year;
  _text(
    canvas,
    '© $year Hisaab Mitra. All rights reserved.',
    36,
    609,
    280,
    size: 6,
    color: _ink,
  );
  _text(
    canvas,
    'Page 1 of 1',
    342,
    609,
    80,
    size: 6,
    color: _ink,
    align: TextAlign.right,
  );
  _text(
    canvas,
    'Electronically generated transaction record • No signature required.',
    36,
    624,
    380,
    size: 5.5,
    color: _muted,
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(1410, 1950);
  picture.dispose();
  try {
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) throw StateError('Could not encode transaction record.');
    return png.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

double _recordRow(Canvas canvas, String label, String value, double y) {
  _text(canvas, label, 36, y, 150, size: 7, color: _muted);
  _text(
    canvas,
    value,
    190,
    y,
    232,
    size: 7,
    color: _ink,
    align: TextAlign.right,
    weight: FontWeight.w600,
    maxLines: 1,
  );
  _line(canvas, 36, y + 20, 402);
  return y + 23;
}

double _text(
  Canvas canvas,
  String value,
  double x,
  double y,
  double width, {
  required double size,
  Color color = Colors.black,
  FontWeight weight = FontWeight.w400,
  TextAlign align = TextAlign.left,
  int maxLines = 1,
  double? lineHeight,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: value,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
        height: lineHeight == null ? null : lineHeight / size,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
    maxLines: maxLines,
    ellipsis: '…',
  )..layout(maxWidth: width);
  painter.paint(canvas, Offset(x, y));
  final height = painter.height;
  painter.dispose();
  return height;
}

void _line(Canvas canvas, double x, double y, double width) {
  canvas.drawLine(
    Offset(x, y),
    Offset(x + width, y),
    Paint()
      ..color = const Color(0xFFE7E5DF)
      ..strokeWidth = .5,
  );
}

void _roundedRect(Canvas canvas, Rect rect, Color color, double radius) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(radius)),
    Paint()..color = color,
  );
}

Rect _containRect(Size source, Rect target) {
  final scale = (target.width / source.width)
      .clamp(0.0, target.height / source.height)
      .toDouble();
  final size = Size(source.width * scale, source.height * scale);
  return Rect.fromLTWH(
    target.left + (target.width - size.width) / 2,
    target.top + (target.height - size.height) / 2,
    size.width,
    size.height,
  );
}

String _dateTime(Object? timestamp) {
  final millis = int.tryParse(timestamp?.toString() ?? '') ?? 0;
  final date = millis > 0
      ? DateTime.fromMillisecondsSinceEpoch(millis)
      : DateTime.now();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year}, '
      '${hour.toString().padLeft(2, '0')}:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
}

String _money(double amount) {
  final fixed = amount.toStringAsFixed(2).split('.');
  final whole = fixed.first;
  if (whole.length <= 3) return '${whole}.${fixed.last}';
  final groups = <String>[whole.substring(whole.length - 3)];
  var rest = whole.substring(0, whole.length - 3);
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '${groups.join(',')}.${fixed.last}';
}

String _amountInWords(double amount) {
  final value = amount.floor();
  if (value == 0) return 'zero';
  const ones = [
    '',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
  ];
  const tens = [
    '',
    '',
    'twenty',
    'thirty',
    'forty',
    'fifty',
    'sixty',
    'seventy',
    'eighty',
    'ninety',
  ];

  String underThousand(int n) {
    if (n < 20) return ones[n];
    if (n < 100)
      return '${tens[n ~/ 10]}${n % 10 == 0 ? '' : ' ${ones[n % 10]}'}';
    return '${ones[n ~/ 100]} hundred${n % 100 == 0 ? '' : ' ${underThousand(n % 100)}'}';
  }

  var remaining = value;
  final parts = <String>[];
  for (final group in [
    (10000000, 'crore'),
    (100000, 'lakh'),
    (1000, 'thousand'),
  ]) {
    final count = remaining ~/ group.$1;
    if (count > 0) {
      parts.add('${underThousand(count)} ${group.$2}');
      remaining %= group.$1;
    }
  }
  if (remaining > 0) parts.add(underThousand(remaining));
  return parts.join(' ');
}
