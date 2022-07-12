import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/services/upload/Uploader.dart';
import 'package:piwigo_ng/views/components/list_item.dart';
import 'package:piwigo_ng/views/SettingsViewPage.dart';

import 'package:piwigo_ng/views/components/appbars.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';

import '../api/SearchAPI.dart';
import 'ImageViewPage.dart';

class RootCategoryViewPage extends StatefulWidget {
  final bool isAdmin;

  const RootCategoryViewPage({Key key, this.isAdmin = false}) : super(key: key);
  @override
  _RootCategoryViewPageState createState() => _RootCategoryViewPageState();
}
class _RootCategoryViewPageState extends State<RootCategoryViewPage> with SingleTickerProviderStateMixin {
  String _rootCategory;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  final FocusNode _focus = FocusNode();

  Future<Map<String,dynamic>> _albumsFuture;
  Future<Map<String,dynamic>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _rootCategory = "0";
    _focus.addListener(() {
      if(!_focus.hasFocus) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      API.uploader = Uploader(context);
    });
    _getData();
  }
  @override
  void dispose() {
    super.dispose();
  }

  _getData() {
    _albumsFuture = fetchAlbums(_rootCategory);
    _imagesFuture = searchAlbums(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _focus.unfocus();
        },
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, bool) {
            return [
              AppBarExpandable(
                scrollController: _scrollController,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  icon: Icon(Icons.settings, color: _theme.iconTheme.color),
                ),
                title: appStrings(context).tabBar_albums,
              ),
              AppBarExpandableSearch(
                textController: _searchController,
                onTap: () {},
                focusNode: _focus,
                onSubmit: (string) {
                  setState(() {
                    _isSearching = _searchController.text.length > 0;
                    _getData();
                  });
                },
              ),
            ];
          },
          body: RefreshIndicator(
            displacement: 20,
            notificationPredicate: (notification) {
              return notification.metrics.atEdge;
            },
            onRefresh: () {
              _getData();
              return Future.delayed(Duration(milliseconds: 1000));
            },
            child: SingleChildScrollView(
              child: Builder(builder: (context) {
                if(_isSearching) {
                  return FutureBuilder<Map<String,dynamic>>(
                    key: UniqueKey(),
                    future: _imagesFuture,
                    builder: (BuildContext context, AsyncSnapshot imagesSnapshot) {
                      if(imagesSnapshot.hasData){
                        if(imagesSnapshot.data['stat'] == 'fail') {
                          return Center(
                            child: Text(appStrings(context).categoryImageList_noDataError),
                          );
                        }
                        var images = imagesSnapshot.data['result']['images'];
                        var nbImages = images.length;
                        return Column(
                          children: [
                            _imageGrid(images),
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Text(appStrings(context).imageCount(nbImages), style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300,),),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                }
                return FutureBuilder<Map<String,dynamic>>(
                  key: UniqueKey(),
                  future: _albumsFuture, // Albums of the list
                  builder: (BuildContext context, AsyncSnapshot albumSnapshot) {
                    if(albumSnapshot.hasData){
                      if(albumSnapshot.data['stat'] == 'fail') {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Text(albumSnapshot.data['result']),
                        ); //appStrings(context).categoryMainEmpty
                      }
                      var albums = albumSnapshot.data['result']['categories'];
                      int nbPhotos = 0;
                      albums.forEach((cat) => nbPhotos+=cat["total_nb_images"]);
                      albums.removeWhere((category) => (
                        category["id"].toString() == _rootCategory
                      ));
                      return Column(
                        children: [
                          _albumGrid(albums),
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text(appStrings(context).imageCount(nbPhotos), style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300,),),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              }),
            ),
          ),
        ),
      ),
      floatingActionButton: widget.isAdmin ? FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateCategoryDialog(catId: "0");
            }
          ).whenComplete(() {
            setState(() {
              _getData();
            });
          });
        },
        child: Icon(Icons.create_new_folder, color: _theme.primaryColorLight, size: 30),
      ) : null,
    );
  }

  Widget _albumGrid(dynamic albums) {
    int albumCrossAxisCount = MediaQuery.of(context).size.width <= Constants.albumMinWidth ? 1
        : (MediaQuery.of(context).size.width/Constants.albumMinWidth).floor();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: albumCrossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: albumGridAspectRatio(context),
      ),
      padding: EdgeInsets.all(10),
      itemCount: albums.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var album = albums[index];
        return AlbumListItem(album, isAdmin: widget.isAdmin, onClose: () {
          setState(() {});
        });
      },
    );
  }
  Widget _imageGrid(dynamic images) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getImageCrossAxisCount(context),
        mainAxisSpacing: 3.0,
        crossAxisSpacing: 3.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 5),
      itemCount: images.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var image = images[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ImageViewPage(
                images: images,
                index: index,
                isAdmin: widget.isAdmin,
              )),
            ).whenComplete(() => setState(() {}));
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(images[index]["derivatives"][API.prefs.getString('thumbnail_size')]["url"],
                  fit: BoxFit.cover,
                ),
              ),
              API.prefs.getBool('show_thumbnail_title')? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Color(0x80ffffff),
                  child: AutoSizeText('${image['name']}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 12),
                    maxFontSize: 14, minFontSize: 7,
                    textAlign: TextAlign.center,
                  ),
                ),
              ) : Center(),
            ],
          ),
        );
      },
    );
  }
}