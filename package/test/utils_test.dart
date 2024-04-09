import 'package:beamer/beamer.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_stacks.dart';

void main() {
  final beamStacks = <BeamStack>[
    Stack1(),
    Stack2(RouteInformation(uri: Uri())),
    CustomStateStack(),
    RegExpStack(),
    AsteriskStack(),
  ];

  group('createBeamState', () {
    test('uri and uriBlueprint are correct without BeamStack', () {
      final uri = Uri.parse('/l2/123');
      final state = Utils.createBeamState(uri);
      expect(state.uri.path, '/l2/123');
      expect(state.uriBlueprint.path, '/l2/123');
    });

    test('uri and uriBlueprint are correct with BeamStack', () {
      final uri = Uri.parse('/l2/123');
      final state = Utils.createBeamState(uri, beamStack: beamStacks[1]);
      expect(state.uri.path, '/l2/123');
      expect(state.uriBlueprint.path, '/l2/:id');
    });
  });

  group('chooseBeamStack', () {
    test('Uri is parsed to BeamStack', () async {
      var uri = Uri.parse('/l1');
      var stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<Stack1>());

      uri = Uri.parse('/l1/');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<Stack1>());

      uri = Uri.parse('/l1?q=xxx');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<Stack1>());

      uri = Uri.parse('/l1/one');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<Stack1>());

      uri = Uri.parse('/l1/two');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<Stack1>());

      uri = Uri.parse('/l2');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<Stack2>());

      uri = Uri.parse('/l2/123?q=xxx');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<Stack2>());
      expect((stack.state as BeamState).uri.path, '/l2/123');
      expect((stack.state as BeamState).uriBlueprint.path, '/l2/:id');

      uri = Uri.parse('/reg');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<RegExpStack>());

      uri = Uri.parse('/reg/');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<RegExpStack>());

      uri = Uri.parse('/anything');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<AsteriskStack>());

      uri = Uri.parse('/anything/');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<AsteriskStack>());

      uri = Uri.parse('/anything/can/be/here');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<AsteriskStack>());
    });

    test('Parsed BeamStack carries URL parameters', () async {
      var uri = Uri.parse('/l2');
      var stack = Utils.chooseBeamStack(uri, beamStacks);
      expect((stack.state as BeamState).pathParameters, {});

      uri = Uri.parse('/l2/123');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect((stack.state as BeamState).pathParameters, {'id': '123'});

      uri = Uri.parse('/l2/123?q=xxx');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect((stack.state as BeamState).pathParameters, {'id': '123'});
      expect((stack.state as BeamState).queryParameters, {'q': 'xxx'});
    });

    test('Unknown URI yields NotFound stack', () async {
      final uri = Uri.parse('/x');
      final stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<NotFound>());
    });

    test('Custom state is created', () {
      var uri = Uri.parse('/custom');
      var stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<CustomStateStack>());
      expect((stack as CustomStateStack).state.customVar, '');

      uri = Uri.parse('/custom/test');
      stack = Utils.chooseBeamStack(uri, beamStacks);
      expect(stack, isA<CustomStateStack>());
      expect((stack as CustomStateStack).state.customVar, 'test');
    });
  });

  test('tryCastToRegExp throws', () {
    expect(
      () => Utils.tryCastToRegExp('not-regexp'),
      throwsA(isA<FlutterError>()),
    );
  });

  group('Creating new configuration for BeamerDelegate', () {
    test('Remove trailing slashes', () {
      expect(Utils.removeTrailingSlash(Uri.parse('')), Uri.parse(''));
      expect(Utils.removeTrailingSlash(Uri.parse('/')), Uri.parse('/'));
      expect(Utils.removeTrailingSlash(Uri.parse('/xxx/')), Uri.parse('/xxx'));
      expect(
        Utils.removeTrailingSlash(Uri.parse('https://example.com/')),
        Uri.parse('https://example.com/'),
      );
      expect(
        Utils.removeTrailingSlash(Uri.parse('https://example.com/test/')),
        Uri.parse('https://example.com/test'),
      );
    });

    test('Appending URIs to relative URI', () {
      final current = Uri.parse('/current');
      expect(
        Utils.maybeAppend(current, Uri.parse('incoming')).toString(),
        '/current/incoming',
      );
      expect(
        Utils.maybeAppend(current, Uri.parse('/incoming')).toString(),
        '/incoming',
      );
      expect(
        Utils.maybeAppend(current, Uri.parse('')).toString(),
        '',
      );
      expect(
        Utils.maybeAppend(current, Uri.parse('/')).toString(),
        '/',
      );
      expect(
        Utils.maybeAppend(
          current,
          Uri.parse('example://app/incoming'),
        ).toString(),
        'example://app/incoming',
      );
      expect(
        Utils.maybeAppend(current, Uri.parse('//app/incoming')).toString(),
        '//app/incoming',
      );
    });

    test('Appending URIs to absolute URI', () {
      final current = Uri.parse('example://app/current');
      expect(
        Utils.maybeAppend(current, Uri.parse('incoming')).toString(),
        'example://app/current/incoming',
      );
      expect(
        Utils.maybeAppend(current, Uri.parse('/incoming')).toString(),
        '/incoming',
      );
      expect(
        Utils.maybeAppend(current, Uri.parse('')).toString(),
        '',
      );
      expect(
        Utils.maybeAppend(current, Uri.parse('/')).toString(),
        '/',
      );
      expect(
        Utils.maybeAppend(
          current,
          Uri.parse('example://app/incoming'),
        ).toString(),
        'example://app/incoming',
      );
      expect(
        Utils.maybeAppend(current, Uri.parse('//app/incoming')).toString(),
        '//app/incoming',
      );
    });

    test('Merging with new routeState', () {
      final current = RouteInformation(uri: Uri.parse('/current'));
      expect(
        Utils.mergeConfiguration(
                current, RouteInformation(uri: Uri(), state: 42))
            .state,
        42,
      );
      expect(
        Utils.mergeConfiguration(current,
                RouteInformation(uri: Uri.parse('incoming'), state: 42))
            .state,
        42,
      );
      expect(
        Utils.mergeConfiguration(current,
                RouteInformation(uri: Uri.parse('/incoming'), state: 42))
            .state,
        42,
      );
      expect(
        Utils.mergeConfiguration(
            current,
            RouteInformation(
              uri: Uri.parse('example://app/incoming'),
              state: 42,
            )).state,
        42,
      );
      expect(
        Utils.mergeConfiguration(
            current,
            RouteInformation(
              uri: Uri.parse('//app/incoming'),
              state: 42,
            )).state,
        42,
      );
    });
  });

  group('RouteInformation equality', () {
    test('identical are equal', () {
      final ri = RouteInformation(uri: Uri());

      expect(ri.isEqualTo(ri), isTrue);
    });

    test('empty are equal', () {
      final ri1 = RouteInformation(uri: Uri());
      final ri2 = RouteInformation(uri: Uri());

      expect(ri1.isEqualTo(ri2), isTrue);
    });

    test('full are equal', () {
      final ri1 = RouteInformation(uri: Uri.parse('/x'), state: 1);
      final ri2 = RouteInformation(uri: Uri.parse('/x'), state: 1);

      expect(ri1.isEqualTo(ri2), isTrue);
    });

    test('not equal with type mismatch', () {
      final ri1 = RouteInformation(uri: Uri.parse('/x'), state: 1);
      final ri2 = null;

      expect(ri1.isEqualTo(ri2), isFalse);
    });

    test('not equal with stack diff', () {
      final ri1 = RouteInformation(uri: Uri.parse('/x'), state: 1);
      final ri2 = RouteInformation(uri: Uri.parse('/y'), state: 1);

      expect(ri1.isEqualTo(ri2), isFalse);
    });

    test('not equal with state diff', () {
      final ri1 = RouteInformation(uri: Uri.parse('/x'), state: 1);
      final ri2 = RouteInformation(uri: Uri.parse('/x'), state: 2);

      expect(ri1.isEqualTo(ri2), isFalse);
    });
  });
}
