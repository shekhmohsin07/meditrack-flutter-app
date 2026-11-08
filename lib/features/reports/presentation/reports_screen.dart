import 'package:flutter/material.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'calendar_tab.dart';
import 'pdf_report_screen.dart';
import 'history_tab.dart';
import 'statistics_tab.dart';

/// Reports tab: History | Statistics | Calendar.  (PDF export via the app bar icon.)
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.navReports, style: Theme.of(context).textTheme.headlineMedium),
          actions: [
            IconButton(
              tooltip: t.pdfReports,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfReportScreen())),
            ),
          ],
          bottom: TabBar(tabs: [Tab(text: t.tabHistory), Tab(text: t.tabStatistics), Tab(text: t.tabCalendar)]),
        ),
        body: const TabBarView(children: [HistoryTab(), StatisticsTab(), CalendarTab()]),
      ),
    );
  }
}
