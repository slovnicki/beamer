import 'dart:html' as html;

/// {@template browser_tab_title_util.tab_title}
/// Sets the title of the browser tab on web.
///
/// This is a no-op on non-web platforms.
/// {@endtemplate}
setTabTitle(String title) {
  html.document.title = title;
}
