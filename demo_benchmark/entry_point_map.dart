// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

Future<String> sintrEntryPoint(String msg) async {
  String text = msg;

  List<String> words = text.split(new RegExp(r"(\s+)"));
  List<Map<String, int>> kvs = [];

  int i = 0;

  for (String word in words) {
    if (++i % 100 == 0) break;
    kvs.add({word: 1});
  }

  return JSON.encode(kvs);
}
