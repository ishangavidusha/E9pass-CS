import 'package:e9pass_cs/views/fileView.dart';
import 'package:e9pass_cs/views/pdfCreaterView.dart';
import 'package:e9pass_cs/views/settingsView.dart';
import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController;
  bool showTitleBar = false;
  double topBarOpacity = 0.0;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(scroollListener);
    super.initState();
  }

  scroollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (_scrollController.offset <= 24 &&
          _scrollController.offset >= 0) {
        if (topBarOpacity != _scrollController.offset / 24) {
          setState(() {
            topBarOpacity = _scrollController.offset / 24;
          });
        }
      } else if (_scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double devWidth = MediaQuery.of(context).size.width;
    double devHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              height: devHeight,
              width: devWidth,
              color: AppColors.backgroundColor,
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(
                  height: devHeight * 0.2,
                ),
                CardButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PDFCreaterView())
                    );
                  },
                  image: 'assets/images/add.png',
                  mainText: 'Create',
                  subText: 'E9pass PDF File',
                ),
                CardButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Downloads(title: 'All PDFs',))
                    );
                  },
                  image: 'assets/images/pdf.png',
                  mainText: 'View',
                  subText: 'List All PDF Files',
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                boxShadow: <BoxShadow>[
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'E9pass',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: devWidth * 0.08,
                                  color: AppColors.mainTextColor,
                                ),
                              ),
                              Text(
                                'Customer Service Application',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: devWidth * 0.03,
                                  color: AppColors.mainTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingsView()),
                              );
                            },
                            child: Image.asset(
                              'assets/images/settings.png',
                              height: devWidth * 0.12,
                              width: devWidth * 0.12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardButton extends StatelessWidget {
  final Function onTap;
  final String image;
  final String mainText;
  final String subText;

  const CardButton({Key key, this.onTap, this.image, this.mainText, this.subText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 6,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  image,
                  height: 40,
                  width: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainText,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainTextColor,
                        ),
                      ),
                    ),
                    Text(
                      subText,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.arrow_forward_ios, color: AppColors.mainTextColor,)
              ),
            ],
          ),
        ),
      ),
    );
  }
}