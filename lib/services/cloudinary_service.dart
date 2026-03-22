import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String _cloudName = 'djlx88g7v';
  static const String _uploadPreset = 'gvejyeua';
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from the user's gallery
  /// Returns the picked image file or null if cancelled
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Upload an image file to Cloudinary
  /// Returns the secure_url of the uploaded image
  /// Throws an exception if the upload fails
  Future<String> uploadImageToCloudinary(XFile imageFile) async {
    try {
      print('DEBUG: Starting upload to Cloudinary');
      print('DEBUG: Image file path: ${imageFile.path}');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_uploadUrl),
      );

      print('DEBUG: Created multipart request to $_uploadUrl');

      // Read image bytes for web compatibility
      final imageBytes = await imageFile.readAsBytes();
      print('DEBUG: Read image bytes, size: ${imageBytes.length}');

      // Add the image file using fromBytes (works on web)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: imageFile.name,
        ),
      );

      // Add upload preset (unsigned upload)
      request.fields['upload_preset'] = _uploadPreset;

      print('DEBUG: Added image and upload preset: $_uploadPreset');

      // Send the request
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout: Request took too long');
        },
      );

      print('DEBUG: Received response with status code: ${response.statusCode}');

      // Check response status - ENHANCED ERROR LOGGING
      if (response.statusCode != 200) {
        final responseBody = await response.stream.bytesToString();
        print('🔴 CLOUDINARY ERROR [${response.statusCode}]: $responseBody');
        
        // Parse JSON error for details
        try {
          final jsonError = json.decode(responseBody) as Map<String, dynamic>;
          print('🔴 ERROR DETAILS: ${jsonError['error'] ?? jsonError}');
          if (jsonError['error'] != null) {
            final errorObj = jsonError['error'] as Map<String, dynamic>;
            print('  - message: ${errorObj['message'] ?? 'unknown'}');
            print('  - reason: ${errorObj['reason'] ?? 'unknown'}');
          }
        } catch (parseE) {
          print('🔴 Raw error body (non-JSON): $responseBody');
        }
        
        String errorMsg = responseBody;
        try {
          final jsonError = json.decode(responseBody) as Map<String, dynamic>;
          errorMsg = jsonError['error']?['message'] ?? responseBody;
          print('🔴 PARSED ERROR MSG: $errorMsg');
        } catch (_) {
          // Use raw body
        }
        throw Exception('Cloudinary failed [${response.statusCode}]: $errorMsg');
      }

      // Parse the response
      final responseBody = await response.stream.bytesToString();
      print('DEBUG: Response body: $responseBody');
      
      final jsonResponse = json.decode(responseBody) as Map<String, dynamic>;

      // Extract secure_url
      final secureUrl = jsonResponse['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('No secure_url in response');
      }

      print('DEBUG: Successfully uploaded image: $secureUrl');
      return secureUrl;
    } on TimeoutException catch (e) {
      print('DEBUG: Timeout exception: $e');
      throw Exception('Upload timeout: Request took too long');
    } catch (e) {
      print('DEBUG: Exception during upload: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// Convenience method: Pick an image and upload it to Cloudinary
  /// Returns the uploaded image URL or throws an exception
  Future<String> pickAndUploadImage() async {
    final imageFile = await pickImageFromGallery();
    if (imageFile == null) {
      throw Exception('No image selected');
    }
    return uploadImageToCloudinary(imageFile);
  }
}
