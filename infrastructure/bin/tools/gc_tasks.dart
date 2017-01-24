// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This tool cleans task objects from the project's datastore

import 'dart:io';

import 'package:sintr_live_common/configuration.dart' as config;
import 'package:sintr_live_common/logging_utils.dart' as log;
import 'package:sintr_live_common/auth.dart' as auth;
import 'package:sintr_live_common/tasks.dart' as tasks;
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;
import 'package:gcloud/db.dart' as db;
import 'package:gcloud/service_scope.dart' as ss;

main(List<String> args) async {
  if (args.length < 1) {
    print("Usage: dart gc_tasks cloud_project_id");
    exit(1);
  }

  log.setupLogging();

  String projectId = args[0];

  config.configuration = new config.Configuration(projectId,
      cryptoTokensLocation:
          "${config.userHomePath}/Communications/CryptoTokens");

  var client = await auth.getAuthedClient();

  tasks.TaskController taskController =
      new tasks.TaskController("example_task");

  var datastore = new datastore_impl.DatastoreImpl(client, '$projectId');
  var datastoreDB = new db.DatastoreDB(datastore);

  log.info("Setup done");

  await ss.fork(() async {
    db.registerDbService(datastoreDB);

    await taskController.deleteAllTasks();
  });
  log.info("Tasks deleted");
}
