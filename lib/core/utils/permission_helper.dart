import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<void> requestAllPermissions(BuildContext context) async {
    // Request location permission
    final locationStatus = await Permission.location.request();
    if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Location Permission',
          'Location permission is required to show nearby events and groups. Please enable it in settings.',
        );
      }
    }

    // Request camera permission (for taking photos)
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Camera Permission',
          'Camera permission is required to take photos. Please enable it in settings.',
        );
      }
    }

    // Request photo library permission (for selecting images)
    // On Android, we use storage permission instead
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Try READ_MEDIA_IMAGES first (Android 13+)
      var storageStatus = await Permission.photos.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.photos.request();
      }

      // Fallback to storage permission for older Android versions
      if (!storageStatus.isGranted) {
        final legacyStorageStatus = await Permission.storage.request();
        if (legacyStorageStatus.isDenied || legacyStorageStatus.isPermanentlyDenied) {
          if (context.mounted) {
            _showPermissionDialog(
              context,
              'Storage Permission',
              'Storage permission is required to access photos. Please enable it in settings.',
            );
          }
        }
      }
    } else {
      // iOS
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isDenied || photosStatus.isPermanentlyDenied) {
        if (context.mounted) {
          _showPermissionDialog(
            context,
            'Photos Permission',
            'Photos permission is required to select images. Please enable it in settings.',
          );
        }
      }
    }
  }

  static Future<bool> requestImagePermission() async {
    // Check if already granted
    if (await Permission.photos.isGranted) {
      return true;
    }

    if (await Permission.storage.isGranted) {
      return true;
    }

    // Request photos permission (works on both iOS and Android 13+)
    var status = await Permission.photos.request();
    if (status.isGranted) {
      return true;
    }

    // Fallback to storage permission for older Android versions
    if (status.isDenied) {
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }

    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    if (await Permission.location.isGranted) {
      return true;
    }

    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    if (await Permission.camera.isGranted) {
      return true;
    }

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static void _showPermissionDialog(
      BuildContext context,
      String title,
      String message,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
