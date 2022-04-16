import 'package:beamer_website/presentation/core/code_snippet.dart';
import 'package:beamer_website/presentation/core/paragraph.dart';
import 'package:flutter/material.dart';

class BeamingScreen extends StatelessWidget {
  const BeamingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ParagraphTitle('Beaming > Navigating'),
              ParagraphText(
                "Navigation is done by \"beaming\". One can think of it as teleporting (beaming) to another place in your app. Similar to Navigator.of(context).pushReplacementNamed('/my-route'), but Beamer is not limited to a single page, nor to a push per se. BeamLocations produce a stack of pages that get built when you beam there. Beaming can feel like using many of Navigator's push/pop methods at once.",
              ),
              CodeSnippet(
                code: '''
// Basic beaming
Beamer.of(context).beamToNamed('/books/2');

// Beaming with an extension method on BuildContext
context.beamToNamed('/books/2');

// Beaming with additional data that persist 
// throughout navigation within the same BeamLocation
context.beamToNamed('/book/2', data: MyObject());
''',
              ),
              SizedBox(height: 16.0),
              ParagraphTitle('Navigating Back'),
              ParagraphText(
                'There are 2 types of going back, i.e. reverse navigation; upward and reverse chronological.',
              ),
              ParagraphSubtitle('Upward (popping a page from stack)'),
              ParagraphText(
                "Upward navigation is navigating to a previous page in the current page stack. This is better known as \"pop\" and is done through Navigator's pop/maybePop methods. The default AppBar's BackButton will call this if nothing else is specified.",
              ),
              CodeSnippet(code: 'Navigator.of(context).maybePop();'),
              SizedBox(height: 16.0),
              ParagraphSubtitle(
                'Reverse Chronological (beaming to previous state)',
              ),
              ParagraphText(
                "Reverse chronological navigation is navigating to wherever we were before. In case of deep-linking (e.g. coming to /books/2 from /authors/3 instead of from /books), this will not be the same as pop. Beamer keeps navigation history in beamingHistory so there is an ability to navigate chronologically to a previous entry in beamingHistory. This is called \"beaming back\". Reverse chronological navigation is also what the browser's back button does, although not via beamBack, but through its internal mechanics.",
              ),
              CodeSnippet(code: 'Beamer.of(context).beamBack();'),
              SizedBox(height: 16.0),
              ParagraphSubtitle('Android back button'),
              ParagraphText(
                "Integration of Android's back button with beaming is achieved by setting a backButtonDispatcher in MaterialApp.router. This dispatcher needs a reference to the same BeamerDelegate that is set for routerDelegate",
              ),
              CodeSnippet(
                code: '''
MaterialApp.router(
  ...
  routerDelegate: beamerDelegate,
  backButtonDispatcher: BeamerBackButtonDispatcher(delegate: beamerDelegate),
)
''',
              ),
              SizedBox(height: 16.0),
              ParagraphText(
                "BeamerBackButtonDispatcher will try to pop first and fallback to beamBack if pop is not possible. If beamBack returns false (there is nowhere to beam back to), Android's back button will close the app, possibly opening a previously used app that was responsible for opening this app via deep-link. BeamerBackButtonDispatcher can be configured to alwaysBeamBack (meaning it won't attempt pop) or to not fallbackToBeamBack (meaning it won't attempt beamBack).",
              )
            ],
          ),
        ),
      ),
    );
  }
}
