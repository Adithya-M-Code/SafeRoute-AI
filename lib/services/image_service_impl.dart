import 'package:image_picker/image_picker.dart';
import 'image_service.dart';

class ImageServiceImpl implements ImageService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      return image?.path;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  @override
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image?.path;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }
}
