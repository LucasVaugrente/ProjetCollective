import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:seriouse_game/ui/LaunchScreen/LaunchScreenView.dart';
import 'package:seriouse_game/ui/ListCoursView.dart';
import 'package:seriouse_game/ui/ListModuleView.dart';
import 'package:seriouse_game/ui/Cours/CoursView.dart';
import 'package:seriouse_game/ui/QCM/QCMGamePage.dart';

import 'package:seriouse_game/models/cours.dart';

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
          path: '/module',
          builder: (context, state) => ListCoursView(),
        ),
        GoRoute(
          path: '/cours',
          builder: (context, state) => CoursView(),
        ),

        // 🔥 Correction ici : plus de selectedPageIndex
        GoRoute(
          path: '/qcm',
          builder: (context, state) {
            // Exemple de cours pour test
            final cours = Cours(
              id: 1,
              idModule: 1,
              titre: "Exemple de cours",
              contenu: "Contenu du cours pour test",
            );

            // On appelle maintenant la nouvelle page QCM
            return QCMGamePage(cours: cours);
          },
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
        context.go('/module');
        break;
      case 2:
        context.go('/qcm');
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
                  'lib/data/AppData/CharteFactoscope/logo-factoscope_seul.png',
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
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Modules',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.verified),
                  label: 'Validation',
                ),
              ],
            ),
          ),
        ),

        if (showLaunchScreen) LaunchScreenView(),
      ],
    );
  }
}
