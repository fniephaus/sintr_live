// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is the code that will be replaced by the infrastructure when
// the job is actually executed

import 'dart:async';
import 'dart:convert';

Future<String> sintrEntryPoint(String msg) async {
  Map<String, Map<String, int>> input = JSON.decode(msg);
  List<Map<String, int>> result = [];
  input.forEach((String direction, Map<String, int> data) {
    int avgSpeed = 0;
    int avgLength = 0;
    result.add({'direction': direction, 'avgSpeed': avgSpeed, 'avgLength': avgLength})
  });

  return JSON.encode(result);
}
