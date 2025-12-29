import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';
import 'providers/power_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/events_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PowerProvider(MQTTService()),
        ),
      ],
      child: MaterialApp(
        title: 'Advanced Changeover Switch',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const EventsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-connect to MQTT on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PowerProvider>(context, listen: false);
      provider.connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}
