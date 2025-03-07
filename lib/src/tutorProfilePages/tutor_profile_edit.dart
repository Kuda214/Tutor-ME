import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutor_me/services/services/user_services.dart';
import 'package:tutor_me/src/colorpallete.dart';
import 'package:tutor_me/src/components.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/models/globals.dart';
import '../../services/models/users.dart';
import '../theme/themes.dart';
import 'pdfViewer/pdf_viewer.dart';

class ToReturn {
  Uint8List image;
  Users user;

  ToReturn(this.image, this.user);
}

// ignore: must_be_immutable
class TutorProfileEdit extends StatefulWidget {
  final Globals globals;
  Uint8List image;
  final bool imageExists;

  TutorProfileEdit(
      {Key? key,
      required this.globals,
      required this.image,
      required this.imageExists})
      : super(key: key);

  @override
  _TutorProfileEditState createState() => _TutorProfileEditState();
}

class _TutorProfileEditState extends State<TutorProfileEdit> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  File? image;
  Uint8List? tutorImage;
  bool doesUserImageExist = false;
  bool isImagePicked = false;
  bool isSaveLoading = false;
  Uint8List? transcript;
  File? fileToUpload;

  getTuteeProfileImage() async {
    try {
      final image = await UserServices.getTuteeProfileImage(
          widget.globals.getUser.getId, widget.globals);

      setState(() {
        tutorImage = image;
        doesUserImageExist = true;
      });
    } catch (e) {
      setState(() {
        tutorImage = Uint8List(128);
      });
    }
  }

  Future pickImage(ImageSource source) async {
    final imageChosen = await ImagePicker().pickImage(source: source);
    if (imageChosen == null) {
      return;
    }

    final imageTempPath = File(imageChosen.path);
    setState(() {
      image = imageTempPath;
      isImagePicked = true;
      Navigator.pop(context);
    });
  }

  ImageProvider buildImage() {
    if (image != null) {
      return FileImage(image!);
    }
    return const AssetImage('assets/Pictures/penguin.png');
  }

  getTranscript() async {
    try {
      transcript = await UserServices.getTutorTranscript(
          widget.globals.getUser.getId, widget.globals);
    } catch (e) {
      const snackBar = SnackBar(content: Text('Failed to get transcript'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getTranscript();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        topDesign(),
        buildBody(),
      ],
    ));
  }

  Widget buildBody() {
    final provider = Provider.of<ThemeProvider>(context, listen: false);

    Color highLightColor;

    if (provider.themeMode == ThemeMode.dark) {
      highLightColor = colorLightBlueTeal;
    } else {
      highLightColor = colorOrange;
    }

    final screenWidthSize = MediaQuery.of(context).size.width;
    final screenHeightSize = MediaQuery.of(context).size.height;
    // FilePickerResult? filePickerResult;
    // String? fileName;
    // PlatformFile? file;
    // bool isUploading = false;
    // File? fileToUpload;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: screenWidthSize * 0.15, right: screenWidthSize * 0.15),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: bioController,
            decoration: InputDecoration(
              hintText: "Change To:",
              labelText: widget.globals.getUser.getBio,
              labelStyle: TextStyle(
                color: highLightColor,
                overflow: TextOverflow.visible,
                fontSize: screenWidthSize * 0.05,
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeightSize * 0.05),
        UploadButton(
          btnIcon: Icons.upload,
          btnName: "    Upload Latest Transcript",
          onPressed: () async {
            final filePick = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );

            setState(() {
              fileToUpload = File(filePick!.files.single.path!);
            });

            try {
              log('here man');
              await UserServices.updateTranscript(
                  fileToUpload, widget.globals.getUser.getId, widget.globals);
              const snackBar = SnackBar(content: Text('Transcript Updated'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } catch (e) {
              try {
                await UserServices.uploadTranscript(
                    fileToUpload, widget.globals.getUser.getId, widget.globals);

                const snackBar = SnackBar(content: Text('Transcript Uploaded'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } catch (e) {
                const snackBar =
                    SnackBar(content: Text('Failed to upload transcript'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
          },
        ),
        SizedBox(height: screenHeightSize * 0.03),
        transcript != null
            ? DowloadLinkButton(
                btnName: "View Transcript",
                onPressed: () {
                  const snackBar =
                      SnackBar(content: Text('Opening Transcript...'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewer(
                        pdf: transcript!,
                      ),
                    ),
                  );
                })
            : DowloadLinkButton(
                btnName: "View Transcript",
                onPressed: () {
                  OpenFile.open(fileToUpload!.path);
                }),
        Container(),
        SizedBox(height: screenHeightSize * 0.03),
        UploadButton(
          btnName: "    Upload Id",
          btnIcon: Icons.upload,
          onPressed: () {
            pickImage(ImageSource.gallery);
          },
        ),
        SizedBox(height: screenHeightSize * 0.03),
        OrangeButton(
            btnName: isSaveLoading ? "Saving" : 'Save',
            onPressed: () async {
              setState(() {
                isSaveLoading = true;
              });
              if (image != null) {
                try {
                  await UserServices.updateProfileImage(
                      image!, widget.globals.getUser.getId, widget.globals);

                 tutorImage = await UserServices.getTuteeProfileImage(
                      widget.globals.getUser.getId, widget.globals);
                } catch (e) {
                  try {
                    await UserServices.uploadProfileImage(
                        image!, widget.globals.getUser.getId, widget.globals);
                        tutorImage = await UserServices.getTuteeProfileImage(
                      widget.globals.getUser.getId, widget.globals);
                  } catch (e) {
                    const snackBar = SnackBar(
                        content: Text('Failed to upload profile picture'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              }
              if (bioController.text.isNotEmpty) {
                await UserServices.updateTutorBio(widget.globals.getUser.getId,
                    bioController.text, widget.globals);

                widget.globals.getUser.setBio = bioController.text;

                final globalJson = json.encode(widget.globals.toJson());
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();

                preferences.setString('globals', globalJson);
              }
              if (nameController.text.isNotEmpty ||
                  bioController.text.isNotEmpty) {}
              setState(() {
                isSaveLoading = false;
              });

              if (image != null) {
                Navigator.pop(
                    context, ToReturn(tutorImage!, widget.globals.getUser));
              }
              else{
                Navigator.pop(
                  context, ToReturn(widget.image, widget.globals.getUser));
              }
            })
      ],
    );
  }

  Widget topDesign() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.25,
            margin: const EdgeInsets.only(bottom: 78),
            child: buildCoverImage()),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.18,
          child: buildProfileImage(),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.26,
          left: MediaQuery.of(context).size.height * 0.23,
          child: buildEditImageIcon(),
        ),
      ],
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.grey,
        child: const Image(
          image: AssetImage('assets/Pictures/tutorCover.jpg'),
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
      );

  Widget buildProfileImage() => CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.127,
        backgroundImage: isImagePicked ? buildImage() : null,
        child: isImagePicked
            ? null
            : widget.imageExists
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
                  )),
      );

  Widget buildEditImageIcon() {
    final provider = Provider.of<ThemeProvider>(context, listen: false);

    Color primaryColor;

    if (provider.themeMode == ThemeMode.dark) {
      primaryColor = colorLightGrey;
    } else {
      primaryColor = colorBlueTeal;
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8)),
      child: const Icon(
        Icons.add_a_photo_outlined,
        color: Colors.white,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  actions: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back)),
                    TextButton(
                        onPressed: () => pickImage(ImageSource.gallery),
                        child: const Text('Open Gallery')),
                    TextButton(
                        onPressed: () => pickImage(ImageSource.camera),
                        child: const Text('Open Camera'))
                  ],
                ));
        // Navigator.pop(context);
      },
    );

    // uploadTranscript() {}
  }
}

class TextInputFieldEdit extends StatelessWidget {
  const TextInputFieldEdit({
    Key? key,
    required this.icon,
    required this.hint,
    required this.inputType,
    required this.inputAction,
    required this.height,
  }) : super(key: key);

  final IconData icon;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final double height;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    Color textColor;
    Color secondaryTextColor;
    Color primaryColor;
    Color highLightColor;

    if (provider.themeMode == ThemeMode.dark) {
      textColor = colorWhite;
      secondaryTextColor = colorGrey;
      primaryColor = colorLightGrey;
      highLightColor = colorLightBlueTeal;
    } else {
      textColor = Colors.black;
      secondaryTextColor = colorOrange;
      primaryColor = colorBlueTeal;
      highLightColor = colorOrange;
    }

    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: size.height * height,
        width: size.width * 0.8,
        decoration: BoxDecoration(
          color: secondaryTextColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor,
            width: 1,
          ),
        ),
        child: Center(
          child: TextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Icon(
                    icon,
                    size: 24,
                    color: highLightColor,
                  ),
                ),
                hintText: hint,
                hintStyle: TextStyle(color: textColor)),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: highLightColor),
            keyboardType: inputType,
            textInputAction: inputAction,
          ),
        ),
      ),
    );
  }
}
