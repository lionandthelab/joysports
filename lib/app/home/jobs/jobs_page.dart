import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class JobsPage extends StatefulWidget {
  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  StreamSubscription<NDEFMessage>? _stream;

  void _startScanning() {
    setState(() {
      _stream = NFC
          .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
          .listen((NDEFMessage message) {
        if (message.isEmpty) {
          print("Read empty NDEF message");
          return;
        }
        print("Read NDEF message with ${message.records.length} records");
        for (NDEFRecord record in message.records) {
          print(
              "Record '${record.id ?? "[NO ID]"}' with TNF '${record.tnf}', type '${record.type}', payload '${record.payload}' and data '${record.data}' and language code '${record.languageCode}'");
        }
      }, onError: (error) {
        setState(() {
          _stream = null;
        });
        if (error is NFCUserCanceledSessionException) {
          print("user canceled");
        } else if (error is NFCSessionTimeoutException) {
          print("session timed out");
        } else {
          print("error: $error");
        }
      }, onDone: () {
        setState(() {
          _stream = null;
        });
      });
    });
  }

  void _stopScanning() {
    _stream?.cancel();
    setState(() {
      _stream = null;
    });
  }

  void _toggleScan() {
    if (_stream == null) {
      _startScanning();
    } else {
      _stopScanning();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Read NFC example"),
      ),
      body: Center(
          child: ElevatedButton(
        child: const Text("Toggle scan"),
        onPressed: _toggleScan,
      )),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/app/home/job_entries/job_entries_page.dart';
// import 'package:starter_architecture_flutter_firebase/app/home/jobs/edit_job_page.dart';
// import 'package:starter_architecture_flutter_firebase/app/home/jobs/job_list_tile.dart';
// import 'package:starter_architecture_flutter_firebase/app/home/jobs/list_items_builder.dart';
// import 'package:starter_architecture_flutter_firebase/app/home/models/job.dart';
// import 'package:alert_dialogs/alert_dialogs.dart';
// import 'package:starter_architecture_flutter_firebase/app/top_level_providers.dart';
// import 'package:starter_architecture_flutter_firebase/constants/strings.dart';
// import 'package:pedantic/pedantic.dart';
// import 'package:starter_architecture_flutter_firebase/services/firestore_database.dart';
// import 'package:nfc_in_flutter/nfc_in_flutter.dart';

// import './read_example_screen.dart';
// import './write_example_screen.dart';

// final jobsStreamProvider = StreamProvider.autoDispose<List<Job>>((ref) {
//   final database = ref.watch(databaseProvider)!;
//   return database.jobsStream();
// });

// // watch database
// class JobsPage extends ConsumerWidget {
//   Future<void> _delete(BuildContext context, WidgetRef ref, Job job) async {
//     try {
//       final database = ref.read<FirestoreDatabase?>(databaseProvider)!;
//       await database.deleteJob(job);
//     } catch (e) {
//       unawaited(showExceptionAlertDialog(
//         context: context,
//         title: 'Operation failed',
//         exception: e,
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(Strings.jobs),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white),
//             onPressed: () => EditJobPage.show(context),
//           ),
//         ],
//       ),
//       body: _buildContents(context, ref),
//     );
//   }

//   Widget _buildContents(BuildContext context, WidgetRef ref) {
//     final jobsAsyncValue = ref.watch(jobsStreamProvider);
//     return ListItemsBuilder<Job>(
//       data: jobsAsyncValue,
//       itemBuilder: (context, job) => Dismissible(
//         key: Key('job-${job.id}'),
//         background: Container(color: Colors.red),
//         direction: DismissDirection.endToStart,
//         onDismissed: (direction) => _delete(context, ref, job),
//         child: JobListTile(
//           job: job,
//           onTap: () => JobEntriesPage.show(context, job),
//         ),
//       ),
//     );
//   }
// }
