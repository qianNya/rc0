import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/shared/widgets/wiki_mode_tag_app_bar.dart';

void main() {
  const statusBarTop = 59.0;

  Widget wrap(Widget child) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(top: statusBarTop)),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('WikiModeTagToolbarInset clears full floating chrome', (
    tester,
  ) async {
    late double chromeHeight;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            chromeHeight = wikiModeTagChromeHeight(context);
            return const WikiModeTagToolbarInset();
          },
        ),
      ),
    );

    expect(chromeHeight, statusBarTop + kToolbarHeight);
    expect(
      tester.getSize(find.byType(WikiModeTagToolbarInset)).height,
      chromeHeight,
    );
  });

  testWidgets('WikiModeTagFloatingToolbarInset clears toolbar row only', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const WikiModeTagFloatingToolbarInset()),
    );

    expect(
      tester.getSize(find.byType(WikiModeTagFloatingToolbarInset)).height,
      kToolbarHeight,
    );
  });
}
