import 'package:factoscope/ui/validation_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:factoscope/ui/LaunchScreen/launch_screen_view.dart';
import 'package:factoscope/ui/list_module_view.dart';
import 'package:factoscope/ui/Cours/cours_view.dart';
import 'package:factoscope/ui/all_cours_view.dart';
import 'list_cours_view.dart';
import 'package:factoscope/ui/AboutView.dart';

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
            path: '/', builder: (context, state) => const ListModulesView()),
        GoRoute(
            path: '/cours', builder: (context, state) => const AllCoursView()),
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
        GoRoute(path: '/about', builder: (context, state) => const AboutView()),
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
        context.go('/cours');
        break;
      case 2:
        context.go('/validation');
        break;
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