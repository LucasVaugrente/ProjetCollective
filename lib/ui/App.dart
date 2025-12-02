import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seriouse_game/ui/LaunchScreen/LaunchScreenView.dart';
import 'package:seriouse_game/ui/ListCoursView.dart';
import 'package:seriouse_game/ui/ListModuleView.dart';
import 'package:seriouse_game/ui/Cours/CoursView.dart';

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
        GoRoute(path: '/module', builder: (context, state) => ListCoursView()),
        GoRoute(path: '/cours', builder: (context, state) => CoursView()),
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
        context.go('/module');
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
                  'lib/data/AppData/CharteFactoscope/logo-factoscope_seul_2.png',
                  height: 80,
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
        if (showLaunchScreen) LaunchScreenView(),
      ],
    );
  }
}

/*
class App extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('Page Home')),
    Center(child: Text('Page Modules')),
    Center(child: Text('Page Certification')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/data/AppData/facto-logo.png',
                height: 40, // Ajuste la hauteur
                fit: BoxFit.contain, // Garde les proportions
              ),
              const SizedBox(width: 10), // Espace entre l'image et le texte
              const Text('Factoscope'),
            ],
          ),
          centerTitle: true,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Modules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified),
              label: 'Certification',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromRGBO(252, 179, 48, 1),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}


*/