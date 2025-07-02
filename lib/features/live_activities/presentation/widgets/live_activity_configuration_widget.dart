import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../controllers/live_activity_bloc.dart';
import '../controllers/live_activity_event.dart';
import '../controllers/live_activity_state.dart';
import 'live_activity_preview.dart';

class LiveActivityConfigurationWidget extends StatefulWidget {
  const LiveActivityConfigurationWidget({
    super.key,
    this.onSave,
    this.onCancel,
  });

  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  @override
  State<LiveActivityConfigurationWidget> createState() => _LiveActivityConfigurationWidgetState();
}

class _LiveActivityConfigurationWidgetState extends State<LiveActivityConfigurationWidget> {
  late final TextEditingController _titleController;
  File? _selectedImage;
  String? _selectedImagePath;
  String? _base64ImageData;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    
    // Load saved configuration first
    context.read<LiveActivityBloc>().add(const LoadSavedConfiguration());
    
    // Initialize with current state
    final currentState = context.read<LiveActivityBloc>().state;
    _updateFromState(currentState);
  }

  void _updateFromState(LiveActivityState state) {
    setState(() {
      _titleController.text = state.title;
      if (state.imagePath != null) {
        // Check if it's a base64 string or file path
        final imagePath = state.imagePath!;
        if (_isBase64String(imagePath)) {
          // It's base64 data
          _base64ImageData = imagePath;
          _selectedImagePath = null;
          _selectedImage = null;
        } else {
          // It's a file path
          _selectedImagePath = imagePath;
          if (File(imagePath).existsSync()) {
            _selectedImage = File(imagePath);
          } else {
            _selectedImage = null;
          }
          _base64ImageData = null;
        }
      } else {
        // Clear all image data
        _base64ImageData = null;
        _selectedImagePath = null;
        _selectedImage = null;
      }
    });
  }

  bool _isBase64String(String str) {
    // Check common base64 indicators
    if (str.startsWith('data:')) return true;
    if (str.startsWith('/9j/') || str.startsWith('iVBORw0KGgo')) return true; // Common image base64 starts
    
    // Check if it's likely a file path
    if (str.contains('/') || str.contains('\\') || str.startsWith('/') || str.contains('.')) {
      return false;
    }
    
    // For base64, check length and valid characters
    if (str.length > 100) {
      // Base64 only contains these characters
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      if (base64Regex.hasMatch(str)) {
        // Try to decode a small portion to verify it's valid base64
        try {
          if (str.length > 50) {
            base64Decode(str.substring(0, 48)); // Use multiple of 4 for base64
            return true;
          }
        } catch (e) {
          // Not valid base64
        }
      }
    }
    
    return false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _saveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveActivityBloc, LiveActivityState>(
      listener: (context, state) {
        _updateFromState(state);
      },
      child: BlocBuilder<LiveActivityBloc, LiveActivityState>(
        builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Configure Live Activity',
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close),
            ),
            actions: [
              TextButton(
                onPressed: () => _onSave(context),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                Text(
                  'Notification Title',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., You\'ve arrived!',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _debouncedSave();
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Image Section
                Text(
                  'Notification Image',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  color: AppColors.surface,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _base64ImageData != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildBase64Image(_base64ImageData!),
                                )
                              : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add image',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Preview Section
                LiveActivityPreview(
                  title: _titleController.text,
                  imageFile: _selectedImage,
                  imageData: _base64ImageData,
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedImagePath = pickedFile.path;
        _base64ImageData = null; // Clear base64 data when new file is selected
      });
      _debouncedSave();
    }
  }

  Widget _buildBase64Image(String base64Data) {
    try {
      // Clean the base64 string - remove data URL prefix if present
      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
      }
      
      // Validate base64 format
      if (cleanBase64.isEmpty) {
        return _buildImagePlaceholder();
      }
      
      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading base64 image: $error');
          return _buildImagePlaceholder();
        },
      );
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.broken_image,
          size: 48,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 8),
        Text(
          'Image unavailable',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _debouncedSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      if (_titleController.text.isNotEmpty) {
        context.read<LiveActivityBloc>().add(
          SaveConfigurationImmediately(
            title: _titleController.text,
            imagePath: _selectedImagePath,
          ),
        );
      }
    });
  }

  void _onSave(BuildContext context) {
    // Configure the Live Activity with new settings
    context.read<LiveActivityBloc>().add(
      ConfigureLiveActivity(
        title: _titleController.text,
        imagePath: _selectedImagePath,
      ),
    );
    
    widget.onSave?.call();
  }
}