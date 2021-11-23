import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:joysports/app/top_level_providers.dart';
import 'package:joysports/constants/strings.dart';
import 'package:pedantic/pedantic.dart';
import 'package:joysports/services/firestore_database.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:joysports/app/home/plays/nfc_reader_page.dart';
import 'package:joysports/app/home/plays/nfc_writer_page.dart';

// watch database
class PlaysPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(Strings.plays),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.chrome_reader_mode_outlined,
                  color: Colors.white),
              onPressed: () => NfcReaderPage.show(context),
            ),
            IconButton(
              icon: const Icon(Icons.pin_outlined, color: Colors.white),
              onPressed: () => NfcWriterPage.show(context),
            ),
          ],
        ),
        body: NfcPlay());
  }
}

class NfcPlay extends StatefulWidget {
  @override
  _NfcPlayState createState() => _NfcPlayState();
}

class _NfcPlayState extends State<NfcPlay> {
  // _stream is a subscription to the stream returned by `NFC.read()`.
  // The subscription is stored in state so the stream can be canceled later
  StreamSubscription<NDEFMessage>? _stream;

  // _tags is a list of scanned tags
  List<NDEFMessage> _tags = [];

  bool _supportsNFC = false;

  int _mode = 0;

// _readNFC() calls `NFC.readNDEF()` and stores the subscription and scanned
  // tags in state
  void _readNFC(BuildContext context) {
    try {
      // ignore: cancel_subscriptions
      StreamSubscription<NDEFMessage> subscription = NFC.readNDEF().listen(
          (tag) {
        // On new tag, add it to state
        setState(() {
          // showDialog(
          //   context: context,
          //   builder: (context) => AlertDialog(
          //     title: const Text("TAG"),
          //     content: Text(tag.records[0].data),
          //   ),
          // );
          if (tag.records[0].data == "test") {
            _mode = 1;
          } else {
            _mode = 0;
          }
          _tags.insert(0, tag);
        });
      },
          // When the stream is done, remove the subscription from state
          onDone: () {
        setState(() {
          _stream = null;
        });
      },
          // Errors are unlikely to happen on Android unless the NFC tags are
          // poorly formatted or removed too soon, however on iOS at least one
          // error is likely to happen. NFCUserCanceledSessionException will
          // always happen unless you call readNDEF() with the `throwOnUserCancel`
          // argument set to false.
          // NFCSessionTimeoutException will be thrown if the session timer exceeds
          // 60 seconds (iOS only).
          // And then there are of course errors for unexpected stuff. Good fun!
          onError: (e) {
        setState(() {
          _stream = null;
        });

        if (!(e is NFCUserCanceledSessionException)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error!"),
              content: Text(e.toString()),
            ),
          );
        }
      });

      setState(() {
        _stream = subscription;
      });
    } catch (err) {
      print("error: $err");
    }
  }

  // _stopReading() cancels the current reading stream
  void _stopReading() {
    _stream?.cancel();
    setState(() {
      _stream = null;
    });
  }

  @override
  void initState() {
    super.initState();
    NFC.isNDEFSupported.then((supported) {
      setState(() {
        _supportsNFC = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('NFC 태그'),
            actions: <Widget>[
              Builder(
                builder: (context) {
                  if (!_supportsNFC) {
                    return TextButton(
                      child: Text("NFC unsupported"),
                      onPressed: null,
                    );
                  }
                  return TextButton(
                    child: Text(_stream == null ? "스캔" : "중지"),
                    onPressed: () {
                      if (_stream == null) {
                        _readNFC(context);
                      } else {
                        _stopReading();
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.clear_all),
                onPressed: () {
                  setState(() {
                    _tags.clear();
                  });
                },
                tooltip: "Clear",
              ),
            ],
          ),
          // Render list of scanned tags
          body: ListView.builder(
            itemCount: _tags.length,
            itemBuilder: (context, index) {
              const TextStyle payloadTextStyle = const TextStyle(
                fontSize: 15,
                color: const Color(0xFF454545),
              );

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("태그",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Builder(
                      builder: (context) {
                        // Build list of records
                        List<Widget> records = [];
                        for (int i = 0; i < _tags[index].records.length; i++) {
                          records.add(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Record ${i + 1} - ${_tags[index].records[i].type}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                              Text(
                                _tags[index].records[i].payload,
                                style: payloadTextStyle,
                              ),
                              Text(
                                _tags[index].records[i].data,
                                style: payloadTextStyle,
                              ),
                            ],
                          ));
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: records,
                        );
                      },
                    )
                  ],
                ),
              );
            },
          ),
          backgroundColor: _mode == 1 ? Colors.blue[200] : Colors.red[200]),
    );
  }
}
