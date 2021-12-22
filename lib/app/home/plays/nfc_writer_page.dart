import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:joysports/routing/app_router.dart';

class RecordEditor {
  final TextEditingController mediaTypeController = TextEditingController();
  final TextEditingController payloadController = TextEditingController();
}

class NfcWriterPage extends StatefulWidget {
  static Future<void> show(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.nfcWriterPage,
      // arguments: ,
    );
  }

  @override
  _NfcWriterPageState createState() => _NfcWriterPageState();
}

class _NfcWriterPageState extends State<NfcWriterPage> {
  StreamSubscription<NDEFMessage>? _stream;
  List<RecordEditor> _records = [];
  bool _hasClosedWriteDialog = false;

  void _addRecord() {
    setState(() {
      _records.add(RecordEditor());
    });
  }

  void _write(BuildContext context) async {
    List<NDEFRecord> records = _records.map((record) {
      return NDEFRecord.type(
        record.mediaTypeController.text,
        record.payloadController.text,
      );
    }).toList();
    NDEFMessage message = NDEFMessage.withRecords(records);

    // Show dialog on Android (iOS has it's own one)
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Scan the tag you want to write to"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                _hasClosedWriteDialog = true;
                _stream?.cancel();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    // Write to the first tag scanned
    await NFC.writeNDEF(message).first;
    if (!_hasClosedWriteDialog) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text("NFC 쓰기"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Center(
            child: OutlinedButton(
              child: const Text("레코드 추가"),
              onPressed: _addRecord,
            ),
          ),
          for (var record in _records)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("레코드", style: Theme.of(context).textTheme.bodyText1),
                  TextFormField(
                    controller: record.mediaTypeController,
                    decoration: InputDecoration(
                      hintText: "타입",
                    ),
                  ),
                  TextFormField(
                    controller: record.payloadController,
                    decoration: InputDecoration(
                      hintText: "내용",
                    ),
                  )
                ],
              ),
            ),
          Center(
            child: ElevatedButton(
              child: const Text("태그에 쓰기"),
              onPressed: _records.length > 0 ? () => _write(context) : null,
            ),
          ),
        ],
      ),
    );
  }
}
