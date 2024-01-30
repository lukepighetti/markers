import 'dart:io';

import 'package:xml/xml.dart';

Future<void> main(List<String> args) async {
  final path = args.firstOrNull;

  if (path == null) {
    print("You must specify a path");
    exit(1);
  }

  final str = File(path + '/Info.fcpxml').readAsStringSync();
  final xml = XmlDocument.parse(str);
  final markers = xml.findAllElements('marker');

  for (final x in markers) {
    var start = x.getAttribute('start')!.asDuration;
    final value = x.getAttribute('value') as String;

    final pOffset = x.parent!.getAttribute('offset')!.asDuration;
    final pStart = x.parent!.getAttribute('start')!.asDuration;

    final pos = pOffset + start - pStart;
    final h = pos.inHours;
    final m = pos.inMinutes - h * 60;
    final s = pos.inSeconds - h * 60 - m * 60;

    final buf = StringBuffer();
    if (h != 0) buf.write('$h:');
    buf.write('$m:');
    buf.write('$s'.padLeft(2, '0'));
    buf.write(' $value');

    print(buf.toString());
  }
}

extension on String {
  Duration get asDuration {
    final parts = replaceAll('s', '').split('/');
    final numerator = int.tryParse(parts.elementAtOrNull(0) ?? '') ?? 0;
    final denominator = int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 1;
    return Duration(milliseconds: (numerator / denominator * 1000).round());
  }
}
