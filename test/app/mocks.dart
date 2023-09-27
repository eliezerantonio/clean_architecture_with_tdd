import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks(
  [MockSpec<Client>(), MockSpec<FlutterSecureStorage>()],
)
export 'mocks.mocks.dart';
