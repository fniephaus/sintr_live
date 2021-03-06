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
  input.forEach((String direction, List<Map<String, int>> data) {
    Map<String, List<int>> counts = {};
    data.forEach((Map<String, int> kv) {
      kv.forEach((String key, int value) {
        counts.putIfAbsent(key, () => []);
        counts[key].add(value);
      });
    });
    int sumSpeed = counts['speed'].reduce((a, b) => a + b);
    double avgSpeed = sumSpeed / counts['speed'].length;
    int sumLength = counts['length'].reduce((a, b) => a + b);
    double avgLength = sumLength / counts['length'].length;
    result.add({
      'direction': direction,
      'sumSpeed': sumSpeed,
      'sumLength': sumLength,
      'avgSpeed': avgSpeed,
      'avgLength': avgLength
    });
  });

  return JSON.encode(result);
}
