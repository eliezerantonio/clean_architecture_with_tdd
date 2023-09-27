import 'package:flutter_test/flutter_test.dart';
import 'package:tv/app/presentation/service_locator/service_locator.dart';

void main() {
  setUp(() {
    ServiceLocator.instance.clear();
  });
  test('Service locator > put', () {
    expect(() {
      ServiceLocator.instance.find<String>();
    }, throwsAssertionError);

    final name = ServiceLocator.instance.put<String>('Eliezer');

    expect(name, ServiceLocator.instance.find<String>());
  });
  test('Service locator > put2', () {
    ServiceLocator.instance.put('Eliezer');
    ServiceLocator.instance.put('Santiago', tag: 'name2');
    final user = ServiceLocator.instance.put(User(name: 'Feranndo'));
    final name = ServiceLocator.instance.find<String>(tag: 'name2');
    final name2 = ServiceLocator.instance.find<String>();

    expect(ServiceLocator.instance.find<User>(), user);
    expect(name2, 'Eliezer');

    expect(name, 'Santiago');
  });
}

class User {
  final String name;

  User({required this.name});
}
