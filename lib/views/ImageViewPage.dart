import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';
import 'package:piwigo_ng/views/components/Dialogs.dart';
import 'package:piwigo_ng/views/components/SnackBars.dart';
import 'package:path/path.dart' as Path;


class ImageViewPage extends StatefulWidget {
  ImageViewPage({Key key, this.images, this.index = 0, this.isAdmin = false, this.category = "0", this.title = "Album", this.page = 0}) : super(key: key);

  final int index;
  final List<dynamic> images;
  final bool isAdmin;
  final String category;
  final String title;
  final int page;

  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  String _derivative;
  PageController _pageController;
  int _page;
  int _imagePage;
  List<dynamic> images = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _pageController = PageController(initialPage: widget.index);
    _derivative = API.prefs.getString('full_screen_image_size');
    _page = widget.index;
    _imagePage = (widget.images.length/100).ceil()-1;
    images.addAll(widget.images);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.index == images.length-1) {
        await nextPage();
        setState(() {
          print(images.length);
        });
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> nextPage() async {
    _imagePage++;
    var response = await fetchImages(widget.category, _imagePage);
    if(response['stat'] == 'fail') {
      ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar(context, response['result'])
      );
    } else {
      images.addAll(response['result']['images']);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      primary: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: _theme.iconTheme.color, //change your color here
        ),
        centerTitle: true,
        title: Text('${images[_page]['name']}',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        backgroundColor: Color(0x80000000),
        actions: [/*
          widget.isAdmin? IconButton(
            onPressed: () {
              _settingModalBottomSheet(context, images[_pageController.page.toInt()]);
            },
            icon: Icon(Icons.edit),
          ) : IconButton(
            onPressed: () {
              //TODO: Implement share image
              print("share");
            },
            icon: Icon(Icons.share),
          ),
           Center(),
           */
        ],
      ),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      // extendBody: true,
      body: Container(
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: images.length,
          controller: _pageController,
          onPageChanged: (newPage) async {
            if(newPage == images.length-1) {
              await nextPage();
            }
            setState(() {
              _page = newPage;
            });
          },
          itemBuilder: (context, index) {
            if(Path.extension(images[index]['element_url']) == '.mp4') {
              return BetterPlayer.network(
                images[index]['element_url'],
                betterPlayerConfiguration: BetterPlayerConfiguration(
                  aspectRatio: images[index]['width']/images[index]['height'],
                  fullScreenAspectRatio: images[index]['width']/images[index]['height'],
                  controlsConfiguration: BetterPlayerControlsConfiguration(
                    enableSkips: false,
                    enableFullscreen: false,
                    unMuteIcon: Icons.volume_off,
                  )
                ),
              );
            }
            return PhotoView(
              imageProvider: CachedNetworkImageProvider(images[index]["derivatives"][_derivative]["url"]),
              minScale: PhotoViewComputedScale.contained,
            );
          }
        ),
        /*
        PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: images.length,
          pageController: _pageController,
          onPageChanged: (newPage) async {
            if(newPage == images.length-1) {
              await nextPage();
            }
            setState(() {
              _page = newPage;
            });
          },
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(images[index]["derivatives"][_derivative]["url"]),
              minScale: PhotoViewComputedScale.contained,
            );
          },
          loadingBuilder: (context, event) => Center(
            child: Container(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
        ),
        */
      ),
      bottomNavigationBar: widget.isAdmin? BottomNavigationBar(
        onTap: (index) async {
          switch (index) {
            case 0:
              if(await confirmDownloadDialog(context,
                content: appStrings(context).downloadImage_confirmation(1),
              )) {
                print('Download $_page');

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appStrings(context).downloadingImages(1)),
                      CircularProgressIndicator(),
                    ],
                  ),
                ));

                await downloadSingleImage(images[_page]);
              }
              break;
            case 1:
              print('Move $_page');
              await moveCategoryModalBottomSheet(context,
                widget.category,
                widget.title,
                true,
                (item) async {
                  int result = await confirmMoveAssignImage(
                    context,
                    content: appStrings(context).moveImage_message(1, images[_page],item.name),
                  );

                  if (result == 0) {
                    print('Move $_page to ${item.id}');
                    var response = await moveImage(images[_page]['id'], [int.parse(item.id)]);
                    if(response['stat'] == 'fail') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          errorSnackBar(context, response['result']));
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          imagesMovedSnackBar(context, 1));
                      Navigator.of(context).pop();
                    }
                  } else if (result == 1) {
                    print('Assign $_page to ${item.id}');
                    var response = await assignImage(images[_page]['id'], [int.parse(item.id)]);
                    if(response['stat'] == 'fail') {
                      ScaffoldMessenger.of(context).showSnackBar(
                          errorSnackBar(context, response['result']));
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          imagesAssignedSnackBar(context, 1));
                      Navigator.of(context).pop();
                    }
                  }
                },
              );
              break;
              /*
            case 2:
              print('Attach $_page');
              await moveCategoryModalBottomSheet(context,
                widget.category,
                widget.title,
                true,
                (item) async {
                  // TODO: implement Attach function
                },
              );
              break;
               */
            case 2: // TODO: change to 3 if implemented Attach function
              if(await confirmDeleteDialog(context,
                content: appStrings(context).deleteImage_message(1),
              )) {
                print('Delete $_page');

                var response = await deleteImage(images[_page]['id']);
                if(response['stat'] == 'fail') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    errorSnackBar(context, '${response['result']}')
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(appStrings(context).deleteImageHUD_deleting(1)),
                  ));
                }
                int page = _page;
                if(page == images.length-1) {
                  if (page == 0) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      _page--;
                      _pageController.previousPage(
                          duration: Duration(milliseconds: 100),
                          curve: Curves.easeIn);
                    });
                  }
                }
                images.removeAt(page);
                setState(() {});
              }
              break;
            default:
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded, color: _theme.iconTheme.color),
            label: appStrings(context).imageOptions_download,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reply_outlined, color: _theme.iconTheme.color),
            label: appStrings(context).moveImage_title,
          ),
          /*
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file, color: _theme.iconTheme.color),
            label: "Attach",
            // TODO: implement attach thumbnail
          ),
          */
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline, color: _theme.errorColor),
            label: appStrings(context).deleteImage_delete,
          ),
        ],
        backgroundColor: Color(0x80000000),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: _theme.primaryColorLight,
        unselectedItemColor: _theme.primaryColorLight,
      ) : Center(),
    );
  }
}