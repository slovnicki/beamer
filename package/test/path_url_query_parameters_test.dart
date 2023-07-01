import 'package:beamer/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Only URI was passed',
    () {
      expect(constructUri('/test', null), '/test');
    },
  );

  test(
    'URI without queryParameters and queryParameters Map were passed',
    () {
      expect(constructUri('/test', {'test': 'true'}), '/test?test=true');
    },
  );

  test(
    'URI wit queryParameters and queryParameters Map were passed',
    () {
      expect(() {
        constructUri('/test?test=true', {'test': 'true'});
      }, throwsAssertionError);
    },
  );
}
