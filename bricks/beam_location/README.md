# Beam Location

Generates a `BeamLocation` for the [Beamer package](https://pub.dev/packages/beamer).

## Usage

```sh
mason make beam_location --name my
```

## Variables

| Variable | Description                           | Default | Type     |
| -------- |---------------------------------------| ------- | -------- |
| `name`   | The name for the `BeamLocation` class | `my`    | `string` |

## Output

```sh
└── my_beam_location.dart
```

```dart
import 'package:flutter/widgets.dart';
import 'package:beamer/beamer.dart';

class MyBeamLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/my'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      const BeamPage(
        key: ValueKey('home'),
        child: HomeScreen(), // TODO
      ),
      if (state.uri.pathSegments.contains('my'))
        const BeamPage(
          key: ValueKey('my'),
          child: MyScreen(), // TODO
        ),
    ];
    return pages;
  }
}
```
