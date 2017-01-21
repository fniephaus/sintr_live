// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is the code that will be replaced by the infrastructure when
// the job is actually executed

import 'dart:async';
import 'dart:convert';

Future<String> sintrEntryPoint(String msg) async {
  Map<String, List> input = JSON.decode(msg);
  List<Map<String, int>> result = [];
  input.forEach((String length, List<int> speeds) {
    int sumSpeed = speeds.reduce((a, b) => a + b);
    double avgSpeed = sumSpeed / speeds.length;
    result.add({
      'length': length,
      'sumSpeed': sumSpeed,
      'avgSpeed': avgSpeed,
    });
  });

  return JSON.encode(result);
}
