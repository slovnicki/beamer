import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'package:advanced_books/locations.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.beamTo(
                    BooksLocation()
                      ..state = BeamState(
                        pathBlueprintSegments: ['books'],
                      ),
                  ),
                  child: Text('Beam to books location'),
                ),
                ElevatedButton(
                  onPressed: () => context.currentBeamLocation.update(
                    (state) => state.copyWith(
                      pathBlueprintSegments: ['books', ':bookId'],
                      pathParameters: {'bookId': '2'},
                    ),
                  ),
                  child: Text('Beam to favorite book location'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => context.beamToNamed('/articles'),
              child: Text('Beam to articles location'),
            ),
          ],
        ),
      ),
    );
  }
}
