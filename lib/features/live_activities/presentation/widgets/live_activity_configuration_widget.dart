import 'dart:io';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    
    // Initialize with current state
    final currentState = context.read<LiveActivityBloc>().state;
    _titleController.text = currentState.title;
    if (currentState.imagePath != null) {
      _selectedImagePath = currentState.imagePath;
      _selectedImage = File(currentState.imagePath!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveActivityBloc, LiveActivityState>(
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
                  onChanged: (_) => setState(() {}),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedImagePath = pickedFile.path;
      });
    }
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