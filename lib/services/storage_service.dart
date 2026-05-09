abstract class StorageService {
  Future<String?> uploadHazardImage({
    required String localPath,
    required String fileName,
  });

  Future<void> deleteFile(String remotePath);
}
