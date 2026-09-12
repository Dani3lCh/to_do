import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:to_do/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('add a todo and mark it as done', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('No tienes tareas todavía.\nToca "Nueva tarea" para empezar.'), findsOneWidget);

    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Comprar leche');
    await tester.tap(find.text('Agregar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar leche'), findsOneWidget);
    expect(find.text('0 de 1 completadas'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(find.text('1 de 1 completadas'), findsOneWidget);
  });
}
