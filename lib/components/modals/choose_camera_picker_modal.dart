import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class ChooseCameraPickerModal extends StatelessWidget {
  const ChooseCameraPickerModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      canCancel: true,
      content: Column(
        children: [
          ListTile(
            minLeadingWidth: 24,
            leading: Icon(Icons.photo_camera, color: Theme.of(context).primaryColor),
            title: Text(appStrings.categoryUpload_takePhoto),
            onTap: () => Navigator.of(context).pop(0),
          ),
          ListTile(
            minLeadingWidth: 24,
            leading: Icon(Icons.video_camera_back, color: Theme.of(context).primaryColor),
            title: Text(appStrings.categoryUpload_takeVideo),
            onTap: () => Navigator.of(context).pop(1),
          ),
        ],
      ),
    );
  }
}
