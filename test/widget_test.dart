import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rc0/app/app.dart';
import 'package:rc0/features/screenplay/data/screenplay_local_repository.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ScreenplayLocalRepository.instance.initialize();
  });

  testWidgets('App launches explore page', (WidgetTester tester) async {
    await tester.pumpWidget(const Rc0App());
    await tester.pumpAndSettle();

    expect(find.text('rc0'), findsOneWidget);
    expect(find.text('还没有剧本'), findsOneWidget);
  });
}
