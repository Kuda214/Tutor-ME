import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_me/services/models/globals.dart';
import 'package:tutor_me/services/models/users.dart';
import 'package:tutor_me/src/theme/themes.dart';
// import 'package:tutor_me/src/colorPalette.dart';

import '../../services/models/intitutions.dart';
import '../../services/models/modules.dart';
import '../../services/services/institution_services.dart';
import '../../services/services/module_services.dart';
import '../../services/services/user_services.dart';
import '../colorpallete.dart';
import '../components.dart';
import 'user_stats.dart';

class TutorProfilePageView extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TutorProfilePageView(
      {Key? key,
      required this.tutor,
      required this.globals,
      required this.image,
      required this.hasImage})
      : super(key: key);
  final Users tutor;
  final Globals globals;
  final Uint8List image;
  final bool hasImage;

  static const String route = '/tutor_profile_view';

  @override
  _TutorProfilePageViewState createState() => _TutorProfilePageViewState();
}

class _TutorProfilePageViewState extends State<TutorProfilePageView> {
  List<Modules> currentModules = List<Modules>.empty();
  List<Modules> modulesToRequest = List<Modules>.empty(growable: true);
  List<bool> isChecked = List<bool>.empty();
  late Institutions institution;
  late int numConnections;
  int numTutees = 0;
  bool isRequestLoading = false;
  bool isRequestDone = false;
  List<Users> tutors = List<Users>.empty();
  bool isConnected = false;
  int rating = 1;
  Color colorOne = Colors.yellow;
  Color colorTwo = Colors.grey;
  bool firstSelected = true;
  bool secondSelected = false;
  bool thirdSelected = false;
  bool forthSelected = false;
  bool fifthSelected = false;
  bool? value = false;
  late Uint8List bytes;
  bool isImageDisplayed = false;
  late bool doesImageExist;
  bool isLoading = true;

  getCurrentModules() async {
    
    final current =
        await ModuleServices.getUserModules(widget.tutor.getId, widget.globals);
    setState(() {
      currentModules = current;
    });
    getInstitution();

    // getConnections();
  }
  void getConnections() async {
    try {
      tutors = await UserServices.getConnections(widget.globals.getUser.getId,
          widget.globals.getUser.getUserTypeID, widget.globals);
          numTutees = tutors.length;
      for (var tutor in tutors) {
        if (tutor.getId == widget.tutor.getId) {
          isConnected = true;
          break;
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      const snackBar = SnackBar(content: Text('Error loading'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  getInstitution() async {
    final tempInstitution = await InstitutionServices.getUserInstitution(
        widget.tutor.getInstitutionID, widget.globals);
    institution = tempInstitution;

    getConnections();
  }

  @override
  void initState() {
    super.initState();
    // getConnections();
    getCurrentModules();
    // numConnections = getNumConnections();
    // numTutees = getNumTutees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  topDesign(),
                  // readyToTutor(),
                  buildBody(),
                ],
              ));
  }

  Widget buildBody() {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    Color textColor;
    Color secondaryTextColor;

    if (provider.themeMode == ThemeMode.dark) {
      textColor = colorWhite;
      secondaryTextColor = colorGrey;
    } else {
      textColor = Colors.black;
      secondaryTextColor = colorOrange;
    }

    final screenWidthSize = MediaQuery.of(context).size.width;
    final screenHeightSize = MediaQuery.of(context).size.height;
    String tutorName = widget.tutor.getName + ' ' + widget.tutor.getLastName;
    String courseInfo = institution.getName;
    String personalDets = tutorName + '(' + widget.tutor.getAge + ')';
    String gender = "";
    if (widget.tutor.getGender == "F") {
      gender = "Female";
    } else {
      gender = "Male";
    }
    return Column(children: [
      Text(
        personalDets,
        style: TextStyle(
          fontSize: screenWidthSize * 0.08,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      SmallTagButton(
        btnName: "Tutor",
        onPressed: () {},
        backColor: secondaryTextColor,
      ),
      SizedBox(height: screenHeightSize * 0.01),
      Text(
        courseInfo,
        style: TextStyle(
          fontSize: screenWidthSize * 0.04,
          fontWeight: FontWeight.normal,
          color: colorBlueTeal,
        ),
      ),
      SizedBox(height: screenHeightSize * 0.02),
      TutorUserStats(
        rating: widget.tutor.getRating,
        numTutees: numTutees,
      ),
      SizedBox(height: screenHeightSize * 0.02),
      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidthSize * 0.06,
            top: screenHeightSize * 0.03,
          ),
          child: Text(
            "About Me",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: screenHeightSize * 0.03,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            right: screenWidthSize * 0.06,
            left: screenWidthSize * 0.06,
            top: screenHeightSize * 0.02,
            bottom: screenHeightSize * 0.04,
          ),
          child: Text(widget.tutor.getBio,
              style: TextStyle(
                fontSize: screenHeightSize * 0.025,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              )),
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidthSize * 0.06,
          ),
          child: Text("Gender",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: screenHeightSize * 0.03,
                fontWeight: FontWeight.bold,
                color: textColor,
              )),
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            right: screenWidthSize * 0.06,
            left: screenWidthSize * 0.06,
            top: screenHeightSize * 0.02,
            bottom: screenHeightSize * 0.04,
          ),
          child: Text(gender,
              style: TextStyle(
                fontSize: screenHeightSize * 0.025,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              )),
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidthSize * 0.06,
            // top: 16,
          ),
          child: Text("Modules I tutor",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: screenWidthSize * 0.06,
                fontWeight: FontWeight.bold,
                color: textColor,
              )),
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            left: screenWidthSize * 0.06,
            right: screenWidthSize * 0.06,
            top: screenHeightSize * 0,
          ),
          child: ListView.separated(
            separatorBuilder: (BuildContext context, index) {
              return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02);
            },
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: _moduleListBuilder,
            itemCount: currentModules.length,
          ),
        ),
      ),
      SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.4,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.03,
                top: MediaQuery.of(context).size.height * 0.03),
            child: ElevatedButton(
              onPressed: () {
                showModuleSelect(context);
              },
              child: const Text("Send Request"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.deepOrangeAccent),
              ),
            ),
          ))
    ]);
  }

  Widget topDesign() {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    Color textColor;

    if (provider.themeMode == ThemeMode.dark) {
      textColor = colorWhite;
    } else {
      textColor = colorWhite;
    }
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height * 0.25,
            margin: const EdgeInsets.only(bottom: 78),
            child: buildCoverImage()),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.18,
          child: buildProfileImage(),
        ),
        isConnected
            ? Positioned(
                top: MediaQuery.of(context).size.height * 0.27,
                left: MediaQuery.of(context).size.height * 0.01,
                child: ElevatedButton(
                    child: Row(
                      children: <Widget>[
                        Text('Rate', style: TextStyle(color: textColor)),
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                        )
                      ],
                    ),
                    onPressed: () {
                      popUpDialog(context);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(colorBlueTeal),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.1))))))
            : Container()
      ],
    );
  }

  void popUpDialog(BuildContext context) => showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        final provider = Provider.of<ThemeProvider>(context, listen: false);
        Color highlightColor;

        if (provider.themeMode == ThemeMode.dark) {
          highlightColor = colorBlueTeal;
        } else {
          highlightColor = colorOrange;
        }
        return StatefulBuilder(builder: (context, setState) {
          return SimpleDialog(
            title: Row(
              children: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back)),
                Text(
                  'Give ' + widget.tutor.getName + ' a rating',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  
                ),
              ],
            ),
            children: <Widget>[
              Text(
                rating.toString(),
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.07),
                textAlign: TextAlign.center,
              ),
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.star, color: colorOne),
                          onPressed: () {
                            setState(() {
                              rating = 1;
                              secondSelected = !firstSelected;
                              thirdSelected = !firstSelected;
                              forthSelected = !firstSelected;
                              fifthSelected = !firstSelected;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.star,
                            color: secondSelected ? colorOne : colorTwo,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = 2;
                              secondSelected = true;
                              thirdSelected = false;
                              forthSelected = false;
                              fifthSelected = false;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.star,
                            color: thirdSelected ? colorOne : colorTwo,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = 3;
                              secondSelected = true;
                              thirdSelected = true;
                              forthSelected = false;
                              fifthSelected = false;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.star,
                            color: forthSelected ? colorOne : colorTwo,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = 4;
                              secondSelected = true;
                              thirdSelected = true;
                              forthSelected = true;
                              fifthSelected = false;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.star,
                            color: fifthSelected ? colorOne : colorTwo,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = 5;
                              secondSelected = true;
                              thirdSelected = true;
                              forthSelected = true;
                              fifthSelected = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 2, color: colorOrange)),
                    onPressed: () async {
                      int tutorRating = widget.tutor.getRating;
                      int numRatings = widget.tutor.getNumberOfReviews;
                      numRatings++;
                      double updatedRating =
                          ((tutorRating + rating) / numRatings);
                      int asInt = updatedRating.round();
                      
                      try {
                        await UserServices.updateTutorRating(
                            asInt,numRatings,widget.tutor.getId, widget.globals);
                            const snackBar = SnackBar(
                              backgroundColor: colorGreen,
                          content: Text('Rated successfully'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } catch (e) {
                        const snackBar = SnackBar(
                          content: Text('Failed to upload rating'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: highlightColor),
                    )),
              )
            ],
          );
        });
      });

  Widget buildCoverImage() => const Image(
        image: AssetImage('assets/Pictures/tutorCover.jpg'),
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
      );

  Widget buildProfileImage() => CircleAvatar(
      radius: MediaQuery.of(context).size.width * 0.127,
      // backgroundColor: Colors.grey.shade800,
      // backgroundImage: !isImageDisplayed? const AssetImage("assets/Pictures/penguin.png"),

      child: widget.hasImage
          ? ClipOval(
              child: Image.memory(
                widget.image,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.253,
                height: MediaQuery.of(context).size.width * 0.253,
              ),
            )
          : ClipOval(
              child: Image.asset(
              "assets/Pictures/penguin.png",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.253,
              height: MediaQuery.of(context).size.width * 0.253,
            )));

  // ImageProvider buildImage() {
  //   if (image != null) {
  //     return DecorationImage(image: image);
  //   }
  //   return const AssetImage('assets/Pictures/penguin.png');
  // }

  // Image fileImage() {
  //   return Image.memory(image);
  // }

  Widget buildEditImageIcon() => const CircleAvatar(
        radius: 18,
        backgroundColor: colorBlueTeal,
        child: Icon(
          Icons.camera_enhance,
          color: Colors.white,
        ),
      );

  Widget _moduleListBuilder(BuildContext context, int i) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    Color textColor;
    Color highlightColor;

    if (provider.themeMode == ThemeMode.dark) {
      highlightColor = colorBlueTeal;
      textColor = colorWhite;
    } else {
      highlightColor = colorOrange;
      textColor = Colors.black;
    }
    String moduleDescription =
        currentModules[i].getModuleName + '(' + currentModules[i].getCode + ')';
    return Row(
      children: [
        Icon(
          Icons.book,
          size: MediaQuery.of(context).size.height * 0.02,
          color: highlightColor,
        ),
        Expanded(
          child: Text(
            moduleDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.025,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  showModuleSelect(BuildContext context) {
    String titleMessage =
        "Choose the modules you are requesting this tutor for...";
    isChecked = List<bool>.filled(currentModules.length, false);
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
              onWillPop: (() async => true),
              child: StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                    title: Text(titleMessage),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.height * 0.9,
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                  scrollbarTheme: ScrollbarThemeData(
                                      thumbColor: MaterialStateProperty.all(
                                          colorOrange))),
                              child: Scrollbar(
                                // thumbVisibility: true,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return CheckboxListTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: isChecked[i],
                                        title: Text(currentModules[i].getCode),
                                        activeColor: colorBlueTeal,
                                        onChanged: (newValue) {
                                          if (newValue!) {
                                            modulesToRequest
                                                .add(currentModules[i]);
                                          } else {
                                            modulesToRequest
                                                .remove(currentModules[i]);
                                          }
                                          setState(() {
                                            isChecked[i] = newValue;
                                          });
                                        });
                                  },
                                  itemCount: currentModules.length,
                                ),
                              ),
                            )),
                        SizedBox(
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 2, color: colorOrange)),
                              onPressed: () {
                                Navigator.pop(context);
                                showConfirmRequest(context);
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(color: colorOrange),
                              )),
                        ),
                      ],
                    ));
              }));
        });
  }

  showConfirmRequest(BuildContext context) {
    String testMessage = "You are about to send a request to " +
        widget.tutor.getName +
        " " +
        widget.tutor.getLastName;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: (() async => true),
            child: StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  title: const Text("Alert"),
                  content: Text(testMessage),
                  actions: [
                    isRequestLoading
                        ? const CircularProgressIndicator.adaptive()
                        : isRequestDone
                            ? Icon(
                                Icons.done,
                                color: colorOrange,
                                size: MediaQuery.of(context).size.width * 0.1,
                              )
                            : OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        width: 2, color: colorOrange)),
                                onPressed: () async {
                                  try {
                                    setState(() {
                                      isRequestLoading = true;
                                    });

                                    for (var module in modulesToRequest) {
                                      try {
                                        await UserServices().sendRequest(
                                            widget.tutor.getId,
                                            widget.globals.getUser.getId,
                                            module.getModuleId,
                                            widget.globals);
                                      } catch (e) {
                                        const snackBar = SnackBar(
                                          content:
                                              Text('Failed to send request.'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        break;
                                      }
                                    }

                                    setState(() {
                                      isRequestLoading = false;
                                      isRequestDone = true;
                                    });

                                    Future.delayed(
                                        const Duration(milliseconds: 1000), () {
                                      Navigator.of(context).pop();
                                    });
                                  } catch (e) {
                                    const snackBar = SnackBar(
                                      content: Text('Failed to send request.'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                },
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(color: colorOrange),
                                )),
                    !isRequestLoading && !isRequestDone
                        ? OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    width: 2, color: colorBlueTeal)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: colorBlueTeal),
                            ))
                        : Container(),
                  ]);
            }),
          );
        });
  }
}
