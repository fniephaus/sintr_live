// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of sintr_ui;

class Neighbours {
  DivElement top;
  DivElement bottom;
  // DivElement left;
  // DivElement right;

  // If [e] is part of this collection of neighbors, then it's removed.
  void removeDiv(DivElement e) {
    top = (top == e) ? null : e;
    bottom = (bottom == e) ? null : e;
  }
}

void captureSaveCommand() {
  document.onKeyDown.listen((KeyboardEvent event) {
    if (event.ctrlKey || event.metaKey) {
      switch (new String.fromCharCode(event.which).toLowerCase()) {
        case 's':
          event.preventDefault();
          break;
        case 'r': // Run all local
          event.preventDefault();
          _localAll();
          break;
        case 'm': // Run mapper
          event.preventDefault();
          _localExec();
          break;
        case 'd': // Run reducer
          event.preventDefault();
          _localReducer();
          break;
        case 'l': // Run Remote
          event.preventDefault();
          _serverExec();
          break;
      }
    }
  });
}

var sanitizer = const HtmlEscape();
String indent = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';

String outputMapStringify(outputMap) {
  StringBuffer result = new StringBuffer();
  outputMap.forEach((String key, bool value) {
    result.writeln('$key: $value<br>');
  });
  return result.toString();
}

String errorMapStringify(Map<String, int> errorMap) {
  List<String> sortedErrors = errorMap.keys.toList();
  // Sort the errors so that the one with most occurences is first.
  sortedErrors.sort((String e1, String e2) => -errorMap[e1].compareTo(errorMap[e2]));

  StringBuffer result = new StringBuffer();
  sortedErrors.forEach((String error) {
    // Number of occurences appears bold.
    result.writeln('<b>${errorMap[error]} occurences. Error:</b><br>');
    // The first line of the error appears bold and indented.
    result.writeln(indent + '<b>' + sanitizer.convert(error.split('\n').first) + '</b><br>');
    // The next lines of the error appear indented.
    error.split('\n')..sublist(1).forEach((String line) {
      result.writeln(indent + sanitizer.convert(line) + '<br>');
    });
    result.writeln('<br>');
  });
  return result.toString();
}

String inputMapStringify(Map<String, String> inputMap) {
  StringBuffer result = new StringBuffer();
  inputMap.forEach((String file, String contents) {
    // File name appears bold.
    result.writeln('<b>$file:</b><br>');
    // The lines from the file appear indented.
    contents.split('\n').forEach((String line) {
      result.writeln(indent + sanitizer.convert(line) + '<br>');
    });
    result.writeln('<br>');
  });
  return result.toString();
}

bool containsClassOnParentPath(Element target, String className) {
  Element pathIterator = target;
  while (pathIterator != querySelector('body')) {
    if (pathIterator == null) {
      return false;
    }
    if (pathIterator.classes.contains(className)) {
      return true;
    }
    pathIterator = pathIterator.parent;
  }
  return false;
}


int pxValueToInt(String pxValue) {
  return int.parse(pxValue.replaceFirst('px', ''));
}

removeParentConnections(DivElement panel) {
  Neighbours panelNeighbours = connections[panel];
  if (panelNeighbours == null || panelNeighbours.top == null) {
    return;
  }
  Neighbours topNeighbours = connections[panelNeighbours.top];
  topNeighbours.bottom = null;
  panelNeighbours.top.classes.remove('connected-border--bottom');
  panelNeighbours.top = null;
  panel.classes.remove('connected-border--top');
}

removeChildrenConnections(DivElement panel) {
  Neighbours panelNeighbours = connections[panel];
  if (panelNeighbours == null || panelNeighbours.bottom == null) {
    return;
  }
  Neighbours bottomNeighbours = connections[panelNeighbours.bottom];
  bottomNeighbours.top = null;
  panelNeighbours.bottom.classes.remove('connected-border--top');
  panelNeighbours.bottom = null;
  panel.classes.remove('connected-border--bottom');
}

moveChildrenConnections(DivElement panel, int movementX, int movementY) {
  Neighbours panelNeighbours = connections[panel];
  if (panelNeighbours == null || panelNeighbours.bottom == null) {
    return;
  }
  DivElement bottomPanel = panelNeighbours.bottom;
  bottomPanel.style.left = '${bottomPanel.offset.left + movementX}px';
  bottomPanel.style.top = '${bottomPanel.offset.top + movementY}px';
  moveChildrenConnections(bottomPanel, movementX, movementY);
}

propagateFoldToChildren(DivElement panel, int heightDiff) {
  Neighbours panelNeighbours = connections[panel];
  if (panelNeighbours == null || panelNeighbours.bottom == null) {
    return;
  }
  DivElement bottomPanel = panelNeighbours.bottom;
  // bottomPanel.style.transition = 'top 5s';
  // bottomPanel.onTransitionEnd.listen((_) => bottomPanel.style.transition = '');
  bottomPanel.style.top = '${bottomPanel.offset.top + heightDiff}px';
  propagateFoldToChildren(bottomPanel, heightDiff);
}

Map<String, String> collectCodeSources() {
  Map<String, String> sources = {};
  editors.forEach((DivElement codePanel, Editor editor) {
    String filename = codePanel.querySelector('.panel-title').text;
    String code = editor.document.value;
    sources[filename] = code;
  });
  return sources;
}

int charsToDisplay = 10000;

logResponseInOutputPanel(HttpRequest request, String panelId) {
  String responseText = request.responseText;
  if (request.status == 200) {
    logResponseInOutputPanelText(request.responseText, panelId);
  } else {
    querySelector('#$panelId').querySelector('.card-contents').querySelector('pre').text = 'Request failed, status=${request.status}\n\n$responseText';
  }
}

logResponseInOutputPanelText(String responseText, String panelId) {
    var response;
    // Try to encode with it a JSON pretty printer
    try {
      response = JSON.decode(JSON.decode(responseText)['result']);
      // print(JSON.encode(response));
      JsonEncoder encoder = new JsonEncoder.withIndent("  ");
      responseText = encoder.convert(response);
    } catch (e, st) {
      print ("Decoding failed");
      print (e);
      print (st);
      return;
    }
    if (response is List) {
      response = {'dataSeries': response};
    }
    String responseTextToDisplay = responseText.length > charsToDisplay ? responseText.substring(0, charsToDisplay) + '[...]' : responseText;
    querySelector('#$panelId').querySelector('.card-contents').querySelector('pre').text = responseTextToDisplay;
    if (panelId == 'map-output-reducer-input') {
      mapperOutputReducerInputData = responseText;
    }
    if (panelId == 'reducer-output') { // TODO(mariana): This is a bit fragile like this, consider refactoring.
      reducerOutputData = responseText;
      updateChartWithData(response);
    }
    printForBenchmark('logResponseInOutputPanelText end (#' + panelId + ')');
}

logResponseInOutputPanelList(List response, String panelId) {
    JsonEncoder encoder = new JsonEncoder.withIndent("  ");
    var responseText = encoder.convert(response);
    Map responseMap = {'dataSeries': response};

    String responseTextToDisplay = responseText.length > charsToDisplay ? responseText.substring(0, charsToDisplay) + '[...]' : responseText;
    querySelector('#$panelId').querySelector('.card-contents').querySelector('pre').text = responseTextToDisplay;
    if (panelId == 'map-output-reducer-input') {
      mapperOutputReducerInputData = responseText;
    }
    if (panelId == 'reducer-output') { // TODO(mariana): This is a bit fragile like this, consider refactoring.
      reducerOutputData = responseText;
      updateChartWithData(responseMap);
    }
    printForBenchmark('logResponseInOutputPanelList end (#' + panelId + ')');
}

/// [LifecycleState] tracks a task through its lifetime
/// Should be kept in sync with https://github.com/lukechurch/sintr_live_common/blob/master/lib/tasks.dart
enum LifecycleState {
  READY, // Ready for allocation
  ALLOCATED, // Allocated to a node
  STARTED, // Execution has begun, this may go back to READY if it fails
  DONE, // Successfully compute
  DEAD // Terminally dead, won't be retried
}

displayTaskStatsInPanel(HttpRequest request, String panelId) {
  PreElement htmlElementDestination = querySelector('#$panelId').querySelector('.card-contents').querySelector('pre');
  var responseText = request.responseText;
  if (request.status == 200) {
    Map<String, Map<int, int>> status;
    try {
      status = JSON.decode(responseText);
    } catch (e, st) {
      print ("Decoding failed");
      print (e);
      print (st);
      return;
    }

    String jobName = (querySelector('#server-job-name-textfield') as InputElement).value;
    Map<int, int> jobStatus = status[jobName];

    var results = jobStatus.keys.map((k) => "${LifecycleState.values[k]}: ${jobStatus[k]}");
    htmlElementDestination.text = results.join("\n");
  } else {
    htmlElementDestination.text = 'Request failed, status=${request.status}\n\n$responseText';
  }
}

addNewCodeEditorPanel({String filename: 'default.dart', String code: ''}) {
  DivElement codePanel = newCodePanel(filename);
  componentHandler().upgradeElement(codePanel); // for the mdl-library
  querySelector('main').append(codePanel);
  connections[codePanel] = new Neighbours();
  zOrderedElements.add(codePanel);
  setOnTop(codePanel, zOrderedElements);
  attachResizeAndMovementListenersToElement(codePanel, zOrderedElements);
  attachTitleBarButtonsListenersToElement(codePanel);
  editors[codePanel] = createNewEditor(codePanel.querySelector('.code'));
  editors[codePanel].document.applyEdit(new SourceEdit(0, 0, code));
}

Editor createNewEditor(DivElement editorContainer) {
  Editor editor = editorFactory.createFromElement(editorContainer);
  // editorContainer.querySelector('.CodeMirror').attributes['flex'] = '';
  editor.resize();
  editor.mode = 'dart';
  editorFactory.registerCompleter('dart', new DartCompleter(dartServices, editor.document));
  editorContainer.onKeyUp.listen((e) {
    printForBenchmark('_handleAutoCompletion start');
    _handleAutoCompletion(editor, e);
    printForBenchmark('_handleAutoCompletion end');
  });

  // Listener for static analysis & auto-run
  // Static analysis is run after 500ms from last edit in the document.
  // The code is run locally after 150ms from the last clean static analysis.
  Timer analysisTimer;
  Timer autoRunTimer;
  int analysisDelayMilliseconds = 500;
  int autoRunDelayMilliseconds = 150;
  editor.document.onChange.listen((_) {
    printForBenchmark('editor.document.onChange');
    if (analysisTimer != null) analysisTimer.cancel();
    if (autoRunTimer != null) autoRunTimer.cancel();
    analysisTimer = new Timer(new Duration(milliseconds: analysisDelayMilliseconds), () {
      printForBenchmark('_performAnalysis start');
      Future analysis = _performAnalysis(editor);
      analysis.then((bool codeIsClean) {
        printForBenchmark('_performAnalysis done');
        if (!autoRun) { // Only autorun when it's enabled by the user.
          return;
        }
        if (codeIsClean) {
          autoRunTimer = new Timer(new Duration(milliseconds: autoRunDelayMilliseconds), () {
            printForBenchmark('_localAll start');
            _localAll();
            printForBenchmark('_localAll done');
          });
        }
      });
    });
  });
  return editor;
}

void printForBenchmark(String text) {
  print(new DateTime.now().millisecondsSinceEpoch.toString() + ' -> ' + text);
}

// TODO(mariana): consider removing all other code files from the UI (if any present) when this is called.
void getDefaultSourceCodeFromServerAndAddToUI() {
  // Make the request to get the default source code.
  var url = '$sintrServerURL/sources';
  HttpRequest.getString(url).then((String sourcesJson) {
    Map<String, String> sources = JSON.decode(sourcesJson);
    sources.forEach((String filename, String code) => addNewCodeEditorPanel(filename: filename, code: code));
    dockAndFoldAllCodeEditors();
  });
}

// See [layoutPanels] for more details as to the layout of the panels.
void dockAndFoldAllCodeEditors() {
  int foldedPanelHeight = 48;
  List<DivElement> panels = editors.keys.toList();
  for (int i = 0; i < panels.length; i++) {
    DivElement panel = panels[i];
    panel.style
      ..top = '${distanceBetweenPanels + foldedPanelHeight * i}px'
      ..left = '${distanceBetweenPanels * 2 + widthUnit * 2}px'
      ..width = '${widthUnit * 3 - panelPadding * 2}px'
      ..height = '${heightUnit - panelPadding * 2}px';
    ButtonElement foldButton = panel.querySelector('.icon--fold-unfold');
    foldButton.click();
    handleSnapToOtherPanels(panel);
  }
}

Future<String> getCloudInput() async {
  var url = '$sintrServerURL/cloudFiles';
  return await HttpRequest.getString(url);
}


Future<String> getSampleInput() async {
  var url = '$sintrServerURL/sampleInput';
  return await HttpRequest.getString(url);
}

void getSampleInputFromServerAndAddToUI() {

  // Make the request to get the sample input.
  getSampleInput().then((String sampleInput) {

    String jsonDecoded = JSON.decode(sampleInput);
    String jsonDecodedToDisplay = jsonDecoded.length > charsToDisplay ? jsonDecoded.substring(0, charsToDisplay) + '[...]' : jsonDecoded;
    mapperInput.querySelector('.card-contents').querySelector('pre').text = jsonDecodedToDisplay;
    mapperInputData = jsonDecoded;
  });
}
