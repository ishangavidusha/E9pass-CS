import 'dart:io';

import 'package:e9pass_cs/state/fileProvider.dart';
import 'package:e9pass_cs/util/filrUtil.dart';
import 'package:e9pass_cs/views/pdfView.dart';
import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
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

  @override
  void didChangeDependencies() {
    Provider.of<FileProvider>(this.context, listen: false).getDownloads(shouldUpdate: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                : TabBarView(
                    children: Constants.map<Widget>(
                      provider.downloadTabs,
                      (index, label) {
                        return ListView.separated(
                          padding: EdgeInsets.only(left: 20),
                          itemCount: provider.downloads.length,
                          itemBuilder: (BuildContext context, int index) {
                            return FileItem(
                              file: provider.downloads[index],
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
          ),
        );
      },
    );
  }
}

class FileItem extends StatelessWidget {
  final FileSystemEntity file;
  final Function popTap;

  FileItem({
    Key key,
    @required this.file,
    this.popTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PdfView(path: file.path,))
        );
      },
      contentPadding: EdgeInsets.all(0),
      leading: Icon(Icons.picture_as_pdf),
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