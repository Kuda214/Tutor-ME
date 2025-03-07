import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tutor_me/services/models/globals.dart';
import 'package:tutor_me/src/colorpallete.dart';
import 'package:tutor_me/src/pages/tutee_calendar_page.dart';
// import 'package:tutor_me/src/pages/badges.dart';
import 'package:tutor_me/src/pages/upcoming.dart';

import '../theme/themes.dart';
import 'calendar_screen.dart';

class Calendar extends StatefulWidget {
  final Globals globals;
  const Calendar({Key? key, required this.globals}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  int currentIndex = 0;

  getScreens() {
    if (widget.globals.getUser.getUserTypeID[0] == '7') {
      return [
        Upcoming(
          globals: widget.globals,
        ),
        CalendarScreen(globals: widget.globals)
      ];
    } else {
      return [
        Upcoming(
          globals: widget.globals,
        ),
        TuteeCalendarScreen(globals: widget.globals)
      ];
    }
  }
  // late CalendarController _controller;

  late Map<DateTime, List<dynamic>> scheduledSessions = {};

  List getScheduledSessions(DateTime date) {
    return scheduledSessions[date] ?? [];
  }

  void iniState() {
    scheduledSessions = {};
    super.initState();
    // _controller = CalendarController();
  }

  CalendarFormat format = CalendarFormat.month;
  DateTime mySelectedDay = DateTime.now();
  DateTime myFocusedDay = DateTime.now();

  TextEditingController meetingController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    meetingController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);

    Color primaryColor;
    Color secondaryColor;
    Color textColor;
    Color highLightColor;

    if (provider.themeMode == ThemeMode.dark) {
      primaryColor = const Color.fromARGB(255, 37, 36, 36);
      textColor = colorWhite;
      highLightColor = colorOrange;
      secondaryColor = const Color.fromARGB(255, 88, 88, 88);
    } else {
      primaryColor = colorBlueTeal;
      textColor = colorDarkGrey;
      highLightColor = colorOrange;
      secondaryColor = colorWhite;
    }

    final screens = getScreens();

    double widthOfScreen = MediaQuery.of(context).size.width;
    double toggleWidth = MediaQuery.of(context).size.width * 0.4;
    double textBoxWidth = MediaQuery.of(context).size.width * 0.4 * 2;
    double buttonWidth = MediaQuery.of(context).size.width * 0.8;
    if (widthOfScreen >= 400.0) {
      toggleWidth = toggleWidth / 2;
      buttonWidth = buttonWidth / 2;
      textBoxWidth = textBoxWidth / 2;
    }
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Calendar', style: TextStyle(color: colorWhite)),
            backgroundColor: primaryColor,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  color: secondaryColor,
                ),
                child: TabBar(
                  onTap: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  indicatorColor: highLightColor,
                  unselectedLabelColor: colorDarkGrey,
                  labelColor: highLightColor,
                  unselectedLabelStyle: TextStyle(
                    color: textColor,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.upcoming,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      text: 'Upcoming',
                      // child: Text("gjgjgj"),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.calendar_month_outlined,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      text: 'Calendar',
                      // child: Text("gjgjgjlkjh"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: screens[currentIndex],
        ));
  }
}
