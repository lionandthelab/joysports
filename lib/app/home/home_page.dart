import 'package:flutter/material.dart';
import 'package:joysports/app/home/account/account_page.dart';
import 'package:joysports/app/home/cupertino_home_scaffold.dart';
import 'package:joysports/app/home/entries/entries_page.dart';
import 'package:joysports/app/home/plays/plays_page.dart';
import 'package:joysports/app/home/jobs/jobs_page.dart';
import 'package:joysports/app/home/tab_item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.plays;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.plays: GlobalKey<NavigatorState>(),
    TabItem.jobs: GlobalKey<NavigatorState>(),
    TabItem.entries: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.plays: (_) => PlaysPage(),
      TabItem.jobs: (_) => JobsPage(),
      TabItem.entries: (_) => EntriesPage(),
      TabItem.account: (_) => AccountPage(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      navigatorKeys[tabItem]!.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !(await navigatorKeys[_currentTab]!.currentState?.maybePop() ??
              false),
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
      ),
    );
  }
}
