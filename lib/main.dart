import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Model/list_item.dart';
import 'Model/login.dart';
import 'Model/register.dart';
import 'Widgets/calendar_page.dart';
import 'Widgets/new_element.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCNgs4fwNrMMPu6Y9ffN0E6qnYkVuj5v8E",
      projectId: "labs-9d2e2",
      storageBucket: "labs-9d2e2.appspot.com",
      messagingSenderId: "24569505345",
      appId: "1:24569505345:android:00593946491117f08808c0",
    ),
  );
  tz.initializeTimeZones(); // Initialize the time zone database
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '193050 Lab3',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/register',
      routes: {
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => MyHomePage(title: 'Home Page'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  List<ListItem> _courseItems = [
    ListItem(
        id: "C1",
        course: "Мобилни информациски системи",
        date: DateTime.now()),
    ListItem(
        id: "C2",
        course: "Менаџмент информациски системи",
        date: DateTime.now()),
    ListItem(
        id: "C3",
        course: "Методологија на истражувањето во ИКТ",
        date: DateTime.now()),
    ListItem(id: "C4", course: "Иновации во ИКТ", date: DateTime.now()),
    ListItem(id: "C5", course: "Анализа и дизајн на ИС", date: DateTime.now()),
    ListItem(id: "C6", course: "Тимски проект", date: DateTime.now())
  ];

  void initializeNotifications() async {
    // Initialize the local notifications plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Get the current device timezone
    final String timeZone = tz.local.name;
    final location = tz.getLocation(timeZone);

    // Create a TZDateTime object using the device timezone
    final DateTime now = DateTime.now();
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    // Schedule a notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Notification Title',
      'Notification Body',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          'Channel for displaying reminders',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _addItemFunction(BuildContext ct) {
    showModalBottomSheet(
      context: ct,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {},
          child: NewElement(_addNewItemToList),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _addNewItemToList(ListItem item) {
    setState(() {
      _courseItems.add(item);
    });

    // Get the date and time of the newly added item
    DateTime notificationDateTime = item.date;

    // Schedule the notification
    _scheduleNotification(notificationDateTime);
  }

  void _scheduleNotification(DateTime notificationDateTime) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      'Channel for displaying reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Convert DateTime to TZDateTime
    final tz.TZDateTime scheduledDate =
    tz.TZDateTime.from(notificationDateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Exam Reminder',
      'You have an exam coming up!',
      scheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  void _deleteItem(String id) {
    setState(() {
      _courseItems.removeWhere((elem) => elem.id == id);
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error occurred during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Колоквиуми и испити"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addItemFunction(context),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(courseItems: _courseItems),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: _courseItems.isEmpty
            ? Text("Внеси колоквиум/испит")
            : ListView.builder(
          itemBuilder: (ctx, index) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              child: ListTile(
                title: Text(
                  _courseItems[index].course,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
                subtitle: Text(
                  "Date and time: " +
                      _courseItems[index].date.toString().substring(0, 16),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => _deleteItem(_courseItems[index].id),
                ),
              ),
            );
          },
          itemCount: _courseItems.length,
        ),
      ),
    );
  }
}
