import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piwigo_ng/components/cards/image_card.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/utils/settings.dart';

class ImageGridView extends StatefulWidget {
  const ImageGridView({
    Key? key,
    this.imageList = const [],
    this.selectedList = const [],
    this.onSelectImage,
    this.onDeselectImage,
    this.onTapImage,
  }) : super(key: key);

  final List<ImageModel> imageList;
  final List<ImageModel> selectedList;
  final Function(ImageModel)? onTapImage;
  final Function(ImageModel)? onSelectImage;
  final Function(ImageModel)? onDeselectImage;

  @override
  State<ImageGridView> createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  void _onTapImage(ImageModel image) {
    final bool selected = widget.selectedList.contains(image);
    if (widget.selectedList.isNotEmpty && !selected) {
      if (widget.onSelectImage != null) widget.onSelectImage!(image);
    } else if (selected) {
      if (widget.onDeselectImage != null) widget.onDeselectImage!(image);
    } else {
      if (widget.onTapImage != null) widget.onTapImage!(image);
    }
  }

  void _onLongPressImage(ImageModel image) {
    if (widget.selectedList.isEmpty) {
      HapticFeedback.mediumImpact();
    }
    setState(() {
      if (widget.onSelectImage != null) widget.onSelectImage!(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Settings.getImageCrossAxisCount(context),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.imageList.length,
      itemBuilder: (context, index) {
        final ImageModel image = widget.imageList[index];
        final bool selected = widget.selectedList.contains(image);
        return ImageCard(
          image: image,
          selected: widget.selectedList.isNotEmpty ? selected : null,
          onPressed: () => _onTapImage(image),
          onLongPress: () => _onLongPressImage(image),
        );
      },
    );
  }
}

class ExampleImageGridView extends StatelessWidget {
  const ExampleImageGridView({
    Key? key,
    this.nbImageRow,
    this.imageThumbnailSize,
  }) : super(key: key);

  final int? nbImageRow;
  final String? imageThumbnailSize;

  List<ImageModel> get _exampleImageList {
    return [
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
      ImageModel(
        id: 0,
        name: 'weird_cat',
        derivatives: Derivatives(
          square: Derivative(url: 'assets/example/weird_cat/square.jpg'),
          thumbnail: Derivative(url: 'assets/example/weird_cat/thumb.jpg'),
          xxsmall: Derivative(url: 'assets/example/weird_cat/2small.jpg'),
          xsmall: Derivative(url: 'assets/example/weird_cat/xsmall.jpg'),
          small: Derivative(url: 'assets/example/weird_cat/small.jpg'),
          medium: Derivative(url: 'assets/example/weird_cat/medium.jpg'),
          large: Derivative(url: 'assets/example/weird_cat/large.jpg'),
          xlarge: Derivative(url: 'assets/example/weird_cat/xlarge.jpg'),
          xxlarge: Derivative(url: 'assets/example/weird_cat/xxlarge.jpg'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final int crossAxisCount = Settings.getImageCrossAxisCount(context, nbImageRow);
      return GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: crossAxisCount,
        itemBuilder: (context, index) {
          final ImageModel image = _exampleImageList[index];
          return ImageCard(
            image: image,
            example: true,
            derivative: imageThumbnailSize,
          );
        },
      );
    });
  }
}