
String ISOLATE_MAIN_CODE = """

// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file handles the execution of a function that is being changed

import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'entry_point.dart';

Future main(List<String> args, SendPort sendPort) async {

  ReceivePort receivePort = new ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((msg) async {

    var encodedResult;

    try {
      int start = new DateTime.now().millisecondsSinceEpoch;
      var result = await _protectedHandle(msg);
      int end = new DateTime.now().millisecondsSinceEpoch;
      encodedResult = JSON.encode(
        {
          'result' : result,
          'error' : null,
          'stacktrace' : null,
          'start' : start,
          'end' : end,
          'time_to_run' : end - start,
        }
      );
    } catch (e, st) {
      encodedResult = JSON.encode(
        {
          'result' : null,
          'error' : e.toString(),
          'stacktrace' : st.toString(),
        }
      );
    }
    sendPort.send(encodedResult);
    receivePort.close();
    return;
  });
}

Future<String> _protectedHandle(String msg) async {
  return sintrEntryPoint(msg);
}

""";
