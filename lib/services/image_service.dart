abstract class ImageService {
  /// Picks an image from camera
  Future<String?> pickImageFromCamera();

  /// Picks an image from gallery
  Future<String?> pickImageFromGallery();
}
