import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/main.dart';
import 'package:test/start/screens/start_screen.dart';
import 'package:test/user/domain/user_preferences_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Генерация мок-класса для UserPreferencesWrapper
@GenerateMocks([UserPreferencesWrapper])
import 'widget_test.mocks.dart';

void main() {
  final mockUserPreferencesWrapper = MockUserPreferencesWrapper();

  setUp(() {
    reset(mockUserPreferencesWrapper);
  });

  testWidgets('Auto authentication test with token',
      (WidgetTester tester) async {
    when(mockUserPreferencesWrapper.getToken())
        .thenAnswer((_) async => 'mocked_token');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPreferencesProvider.overrideWithValue(mockUserPreferencesWrapper),
        ],
        child: const MyApp(isAuthenticated: true),
      ),
    );

    await tester.pump();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('Auto authentication test without token',
      (WidgetTester tester) async {
    when(mockUserPreferencesWrapper.getToken()).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPreferencesProvider.overrideWithValue(mockUserPreferencesWrapper),
        ],
        child: const MyApp(isAuthenticated: false),
      ),
    );

    await tester.pump();
    expect(find.byType(StartScreen), findsOneWidget);
  });
}
