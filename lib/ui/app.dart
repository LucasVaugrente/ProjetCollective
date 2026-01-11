import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:factoscope/ui/LaunchScreen/launch_screen_view.dart';
import 'package:factoscope/ui/list_cours_view.dart';
import 'package:factoscope/ui/list_module_view.dart';
import 'package:factoscope/ui/Cours/cours_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => App(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const ListModulesView()),
        GoRoute(path: '/cours', builder: (context, state) => ListCoursView()),
        GoRoute(path: '/cours/:coursId', builder: (context, state) {
          final coursId = int.parse(state.pathParameters['coursId']!);
          return CoursView(coursId: coursId);
        }),
      ],
    ),
  ],
);

class App extends StatefulWidget {
  const App({super.key, this.child});

  final Widget? child;

  @override
  State<App> createState() =>
      _AppState();
}
class _AppState extends State<App> {
  int currentIndex = 0;
  bool showLaunchScreen = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 4000), () {
      setState(() {
        showLaunchScreen = false;
      });
    });
  }

  void changeTab(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/cours');
        break;
      case 2:
      default:
        context.go('/');
        break;
    }
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(252, 179, 48, 1),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/logo-factoscope_seul.png',
                  height: 40,
                  width: 190,
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
              onTap: changeTab,
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