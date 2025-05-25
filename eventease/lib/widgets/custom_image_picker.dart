import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/widgets/custom_button.dart';
import 'package:eventease/widgets/custom_bottom_sheet.dart';

class CustomImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final ValueChanged<File>? onImageSelected;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool showEditButton;
  final bool enableCropping;
  final List<CropAspectRatioPreset>? aspectRatioPresets;
  final CropStyle cropStyle;
  final String? placeholder;

  const CustomImagePicker({
    super.key,
    this.initialImageUrl,
    this.onImageSelected,
    this.width = 200,
    this.height = 200,
    this.borderRadius = 12,
    this.showEditButton = true,
    this.enableCropping = true,
    this.aspectRatioPresets,
    this.cropStyle = CropStyle.rectangle,
    this.placeholder,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  File? _imageFile;
  final _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        File? croppedFile;
        
        if (widget.enableCropping) {
          croppedFile = await _cropImage(File(pickedFile.path));
        }

        final imageFile = croppedFile ?? File(pickedFile.path);
        setState(() => _imageFile = imageFile);
        widget.onImageSelected?.call(imageFile);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: widget.aspectRatioPresets ??
            [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppTheme.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
        ],
        cropStyle: widget.cropStyle,
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
    }
    return null;
  }

  void _showImageSourceSheet() {
    CustomBottomSheet.show(
      context: context,
      title: 'Select Image Source',
      content: Column(
        children: [
          _ImageSourceOption(
            icon: Icons.photo_camera_rounded,
            title: 'Take Photo',
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          const SizedBox(height: 16),
          _ImageSourceOption(
            icon: Icons.photo_library_rounded,
            title: 'Choose from Gallery',
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          if (_imageFile != null || widget.initialImageUrl != null) ...[
            const SizedBox(height: 16),
            _ImageSourceOption(
              icon: Icons.delete_rounded,
              title: 'Remove Photo',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                setState(() => _imageFile = null);
                widget.onImageSelected?.call(File(''));
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(widget.borderRadius),
          image: _buildBackgroundImage(),
        ),
        child: Stack(
          children: [
            if (_imageFile == null && widget.initialImageUrl == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    if (widget.placeholder != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.placeholder!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            if (widget.showEditButton)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DecorationImage? _buildBackgroundImage() {
    if (_imageFile != null) {
      return DecorationImage(
        image: FileImage(_imageFile!),
        fit: BoxFit.cover,
      );
    }

    if (widget.initialImageUrl != null) {
      return DecorationImage(
        image: NetworkImage(widget.initialImageUrl!),
        fit: BoxFit.cover,
      );
    }

    return null;
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTheme.errorColor : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Avatar Image Picker
class AvatarImagePicker extends StatelessWidget {
  final String? initialImageUrl;
  final ValueChanged<File>? onImageSelected;
  final double size;
  final bool showEditButton;

  const AvatarImagePicker({
    super.key,
    this.initialImageUrl,
    this.onImageSelected,
    this.size = 120,
    this.showEditButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomImagePicker(
      initialImageUrl: initialImageUrl,
      onImageSelected: onImageSelected,
      width: size,
      height: size,
      borderRadius: size / 2,
      showEditButton: showEditButton,
      enableCropping: true,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: const [CropAspectRatioPreset.square],
      placeholder: 'Add Photo',
    );
  }
}
