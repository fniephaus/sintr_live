// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is the code that will be replaced by the infrastructure when
// the job is actually executed

import 'dart:async';
import 'dart:convert';

// String -> List<Map<Key, Value>>

Future<String> sintrEntryPoint(String msg) async {
  List<Map<String, Map>> kvs = [];

  msg.split('\n').forEach((String line) {
    List<String> parts = line.split(';');
    if (parts.length == 5) {
      int speed = int.parse(parts[2]);
      String length = int.parse(parts[3]).toString();
      kvs.add({
        length: speed
      });
    }
  });

  return JSON.encode(kvs);
}
