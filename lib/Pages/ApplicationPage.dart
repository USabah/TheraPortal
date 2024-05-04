import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Pages/HomePage.dart';
import 'package:theraportal/Pages/MessagesPage.dart';
import 'package:theraportal/Pages/SchedulePage.dart';
import 'package:theraportal/Pages/SettingsPage.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      largeScreen: LargeScreen(),
    );
  }
}

class LargeScreen extends StatefulWidget {
  const LargeScreen({super.key});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  DatabaseRouter databaseRouter = DatabaseRouter();
  late TheraportalUser currentUser;
  bool _isLoading = true;
  List<String> headerPageTexts = ['Home', 'Schedule', 'Messages'];
  List<Widget Function()> pages = [];
  List<Map<String, dynamic>> userMapData = [];
  List<Session> userSessions = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _loadUserData(initPages: true);
  }

  Future<void> _loadUserData({bool initPages = false}) async {
    try {
      final user = await DatabaseRouter().getUser(AuthRouter.getUserUID());
      currentUser = user;
      await _loadUserSessionData();
      await _loadUserMapData();
      setState(() {
        _isLoading = false;
        if (initPages) {
          _initPages();
        }
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserSessionData() async {
    try {
      userSessions = await databaseRouter.getAllUserSessions(currentUser);
      Session.sortSessions(userSessions);
    } catch (e) {
      print('Error loading user sessions: $e');
    }
  }

  Future<void> _loadUserMapData() async {
    if (currentUser.userType == UserType.Patient) {
      try {
        userMapData = await databaseRouter.getTherapistCardInfo(
            currentUser, userSessions);
      } catch (e) {
        print('Error loading therapist data: $e');
      }
    } else if (currentUser.userType == UserType.Therapist) {
      try {
        userMapData =
            await databaseRouter.getPatientCardInfo(currentUser, userSessions);
      } catch (e) {
        print('Error loading patient data: $e');
      }
    }
    setState(() {
      _isLoading = false; // Set loading state to false on error
    });
  }

  void updateSessions(List<Session> updatedSessions) {
    // Update the sessions list in the state
    setState(() {
      userSessions = updatedSessions;
    });
  }

  _initPages() {
    pages = [
      () => HomePage(
            currentUser: currentUser,
            mapData: userMapData,
            refreshFunction: _loadUserData,
          ),
      () => SchedulePage(
            currentUser: currentUser,
            userSessions: userSessions,
            onUpdateSessions: updateSessions,
            mapData: userMapData,
            refreshFunction: _loadUserData,
          ),
      () => MessagesPage(
            currentUser: currentUser,
          ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      //display a circular progress indicator while loading user data
      return Scaffold(
        appBar: AppBar(
          title: Text(headerPageTexts[_currentIndex]),
          actions: [
            IconButton(
              onPressed: () {
                //can't go to settings page until data is finished loading
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(headerPageTexts[_currentIndex]),
        actions: [
          IconButton(
            onPressed: () async {
              // Navigator.of(context)
              //     .push(MaterialPageRoute(builder: (context) => TestingPage()));
              List<Map<String, dynamic>>? tempMapData =
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingsPage(
                            currentUser: currentUser,
                            mapData: userMapData,
                          ))) as List<Map<String, dynamic>>?;
              if (tempMapData != null) {
                setState(() {
                  userMapData = tempMapData;
                });
              }
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return pages[index]();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class ApplicationPage extends StatelessWidget {
  static const Key pageKey = Key("Application Page");

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: pageKey,
      body: Body(),
    );
  }
}
