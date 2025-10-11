import 'package:flutter_test/flutter_test.dart';
import 'package:novaspec/core/config/router/app_router.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';
import 'package:novaspec/main.dart';

void main() {
  testWidgets('NovaSpec app smoke test', (WidgetTester tester) async {
    // Create a mock router for testing
    final dataSource = HiveDataSource();
    final appRouter = AppRouter(dataSource);

    // Build our app and trigger a frame.
    await tester.pumpWidget(NovaSpecApp(router: appRouter));

    // Verify that the app starts
    expect(find.byType(NovaSpecApp), findsOneWidget);
  });
}
