import 'dart:io';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:e9pass_cs/models/drivrResponse.dart';
import 'package:e9pass_cs/repository/authService.dart';
import 'package:e9pass_cs/repository/driveService.dart';
import 'package:e9pass_cs/state/fileProvider.dart';
import 'package:e9pass_cs/util/filrUtil.dart';
import 'package:e9pass_cs/views/pdfView.dart';
import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class Downloads extends StatefulWidget {
  final String title;

  Downloads({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  FileProvider fileProvider;
  AuthService authService;
  DriveService drivService = DriveService();
  List<String> driveFiles;
  bool syncing = false;
  bool uploading = false;

  @override
  void didChangeDependencies() {
    Provider.of<FileProvider>(this.context, listen: false).getDownloads(shouldUpdate: false);
    super.didChangeDependencies();
  }

  void getAllData({bool init = false}) async {
    setState(() {
      syncing = true;
    });
    if (init) {
      await Future.delayed(Duration(seconds: 2));
    }
    if (authService?.currentUser != null) {
      await drivService.init(authService);
      List<String> result = await drivService.getAllPdfs();
      setState(() {
        driveFiles = result;
        syncing = false;
        uploading = false;
      });
    } else {
      setState(() {
        driveFiles = null;
        syncing = false;
        uploading = false;
      });
    }
  }

  @override
  void initState() {
    getAllData(init: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double devWidth = MediaQuery.of(context).size.width;
    authService = Provider.of<AuthService>(context);
    return Consumer(
      builder: (BuildContext context, FileProvider provider, Widget child) {
        return DefaultTabController(
          length: provider.downloadTabs.length,
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              automaticallyImplyLeading: false,
              title: Text(
                "${widget.title}",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.mainTextColor,
                ),
              ),
              bottom: TabBar(
                indicatorColor: Theme.of(context).accentColor,
                labelColor: Theme.of(context).accentColor,
                unselectedLabelColor: Theme.of(context).textTheme.caption.color,
                isScrollable: false,
                tabs: Constants.map<Widget>(
                  provider.downloadTabs,
                  (index, label) {
                    return Tab(
                      text: "$label",
                    );
                  },
                ),
              ),
            ),
            body: provider.downloads.isEmpty
                ? Center(child: Text("No Files Found"))
                : Stack(
                  children: [
                    TabBarView(
                        children: Constants.map<Widget>(
                          provider.downloadTabs,
                          (index, label) {
                            return ListView.separated(
                              padding: EdgeInsets.only(left: 20),
                              itemCount: provider.downloads.length,
                              itemBuilder: (BuildContext context, int index) {
                                return FileItem(
                                  file: provider.downloads[index],
                                  upload: () async {
                                    if (authService.currentUser != null) {
                                      setState(() {
                                        uploading = true;
                                      });
                                      try {
                                        GoogleDriveUploadResponse myResponse = await drivService.uploadFileToGoogleDrive(provider.downloads[index]);
                                        setState(() {
                                          uploading = false;
                                        });
                                        if (myResponse.result) {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.SUCCES,
                                            animType: AnimType.BOTTOMSLIDE,
                                            title: 'Done',
                                            desc: 'File Successfully Uploaded',
                                            btnOkText: 'OK',
                                            btnOkOnPress: () {
                                              getAllData();
                                            },
                                            onDissmissCallback: () {
                                              getAllData();
                                            }
                                          )..show();
                                        } else {
                                          AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.ERROR,
                                            animType: AnimType.BOTTOMSLIDE,
                                            title: 'Error',
                                            desc: myResponse.message,
                                            btnOkText: 'OK',
                                            btnOkOnPress: () {
                                              getAllData();
                                            },
                                            onDissmissCallback: () {
                                              getAllData();
                                            }
                                          )..show();
                                        }
                                      } catch (error) {
                                        print(error.toString());
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.ERROR,
                                          animType: AnimType.BOTTOMSLIDE,
                                          title: 'Error',
                                          desc: error.toString(),
                                          btnOkText: 'OK',
                                          btnOkOnPress: () {
                                            getAllData();
                                          },
                                          onDissmissCallback: () {
                                            getAllData();
                                          }
                                        )..show();
                                      }
                                    }
                                  },
                                  contain: driveFiles != null ? driveFiles.contains(basename(provider.downloads[index].path)) : null,
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        height: 1,
                                        color: Theme.of(context).dividerColor,
                                        width:
                                            MediaQuery.of(context).size.width - 70,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Positioned(
                        child: uploading ? Container(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 6.0,
                              sigmaY: 6.0,
                            ),
                            child: Center(
                              child: Container(
                                width: devWidth * 0.4,
                                height: devWidth * 0.3,
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Uploading...',
                                      style: GoogleFonts.roboto(
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ) : Container(),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: authService.currentUser != null ? Container(
                          width: devWidth,
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 6),
                                blurRadius: 10
                              ),
                            ]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10.0,
                                sigmaY: 10.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'You are currently logged in as ${authService.currentUser.displayName}',
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.mainTextColor,
                                            ),
                                          ),
                                        ),
                                        syncing ? Text(
                                          'Syncing...',
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ) : driveFiles != null ? Text(
                                          'Last Update ${FileUtils.formatTime(DateTime.now().toIso8601String())}',
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ) : Text(
                                          'Error fetching data',
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.buttonShadowColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.buttonShadowColor.withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: Offset(0, 6)
                                              )
                                            ]
                                          ),
                                        ),
                                        syncing ? Container(
                                          margin: EdgeInsets.all(4),
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircularProgressIndicator(
                                            backgroundColor: AppColors.backgroundColor,
                                          ),
                                        ) : Container(
                                          margin: EdgeInsets.all(2),
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.yellow,
                                            image: DecorationImage(
                                              image: NetworkImage(authService.currentUser.photoUrl),
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ) : Container(),
                      ),
                  ],
                ),
          ),
        );
      },
    );
  }
}

class FileItem extends StatelessWidget {
  final FileSystemEntity file;
  final Function upload;
  final bool contain;

  FileItem({
    Key key,
    @required this.file,
    @required this.upload, this.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PdfView(file: file,))
        );
      },
      contentPadding: EdgeInsets.all(0),
      leading: Icon(Icons.picture_as_pdf, color: Colors.amber,),
      title: Text(
        "${basename(file.path)}",
        style: TextStyle(
          fontSize: 14,
        ),
        maxLines: 2,
      ),
      subtitle: Text(
        "${FileUtils.formatBytes(file == null ? 678476 : File(file.path).lengthSync(), 2)},"
        " ${file == null ? "Test" : FileUtils.formatTime(File(file.path).lastModifiedSync().toIso8601String())}",
      ),
      trailing: contain == null ? Container(
        margin: EdgeInsets.all(10),
        child: Icon(Icons.error_outline, color: Colors.orange,),
      ) : contain ? IconButton(
        icon: Icon(Icons.done, color: Colors.green,),
        onPressed: null,
      ) : IconButton(
        icon: Icon(Icons.file_upload, color: Colors.blue,),
        onPressed: upload,
      ),
    );
  }
}

class Constants {
  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }
}