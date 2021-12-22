import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:joysports/app/home/entries/entries_view_model.dart';
import 'package:joysports/app/home/entries/entries_list_tile.dart';
import 'package:joysports/app/home/jobs/list_items_builder.dart';
import 'package:joysports/app/top_level_providers.dart';
import 'package:joysports/constants/strings.dart';

final entriesTileModelStreamProvider =
    StreamProvider.autoDispose<List<EntriesListTileModel>>(
  (ref) {
    final database = ref.watch(databaseProvider)!;
    final vm = EntriesViewModel(database: database);
    return vm.entriesTileModelStream;
  },
);

class EntriesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesTileModelStream = ref.watch(entriesTileModelStreamProvider);
    return Scaffold(
      appBar: AppBar(
                backgroundColor: Colors.green[300],
title: const Text(Strings.entries),
        elevation: 2.0,
      ),
      body: ListItemsBuilder<EntriesListTileModel>(
        data: entriesTileModelStream,
        itemBuilder: (context, model) => EntriesListTile(model: model),
      ),
    );
  }
}
