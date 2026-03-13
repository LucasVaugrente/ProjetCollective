import 'package:factoscope/ui/validation_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:factoscope/ui/LaunchScreen/launch_screen_view.dart';
import 'package:factoscope/ui/list_module_view.dart';
import 'package:factoscope/ui/Cours/cours_view.dart';
import 'package:factoscope/ui/all_cours_view.dart';
import 'list_cours_view.dart';
import 'package:factoscope/ui/about_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => App(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ListModulesView(),
        ),
        GoRoute(
          path: '/cours',
          builder: (context, state) => const AllCoursView(),
        ),
        GoRoute(
          path: '/cours/:coursId',
          builder: (context, state) {
            final coursId = int.parse(state.pathParameters['coursId']!);
            return CoursView(coursId: coursId);
          },
        ),
        GoRoute(
          path: '/list_cours',
          builder: (context, state) => ListCoursView(),
        ),
        GoRoute(
          path: '/validation',
          builder: (context, state) => const ValidationView(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutView(),
        ),
      ],
    ),
  ],
);

class App extends StatefulWidget {
  const App({super.key, this.child});

  final Widget? child;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool showLaunchScreen = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        setState(() => showLaunchScreen = false);
      }
    });
  }

  /// Détermine l'index actif de la navbar en fonction de la route courante.
  int _indexFromLocation(String location) {
    if (location.startsWith('/cours')) return 1;
    if (location.startsWith('/validation')) return 2;
    return 0;
  }

  void _changeTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/cours');
        break;
      case 2:
        context.go('/validation');
        break;
      default:
        context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // On lit la route courante depuis GoRouter pour garder la navbar en sync
    // même lors des navigations internes (ex: /cours/42).
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFromLocation(location);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(252, 179, 48, 1),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/logo-factoscope_seul_2.png',
                  height: 75,
                  width: 350,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
              ],
            ),
            centerTitle: true,
          ),
          body: widget.child!,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(41, 36, 96, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: BottomNavigationBar(
              onTap: (index) => _changeTab(context, index),
              backgroundColor: Colors.transparent,
              currentIndex: currentIndex,
              unselectedItemColor: Colors.white,
              selectedItemColor: const Color.fromRGBO(252, 179, 48, 1),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.home),
                  ),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Formation',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.verified),
                  label: 'Validation',
                ),
              ],
            ),
          ),
        ),
        if (showLaunchScreen) const LaunchScreenView(),
      ],
    );
  }
}
