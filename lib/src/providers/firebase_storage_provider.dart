import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class FirBaseStorageProvider{

Future<String> captureImage() async {
  final imagePicker = ImagePicker();
  final XFile? file = await imagePicker.pickImage(source: ImageSource.camera);

  if (file == null) return '';  // Return an empty string or handle the error case.

  String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
  // Upload to Firebase
  Reference referenceRoot = FirebaseStorage.instance.ref();
  Reference referenceDirImages = referenceRoot.child("images");
  Reference referenceImageToUpload = referenceDirImages.child(uniqueFilename);

  Completer<String> completer = Completer<String>();

  try {
    UploadTask uploadTask = referenceImageToUpload.putFile(File(file.path));
    await uploadTask.whenComplete(() async {
      String newUrlImage = await referenceImageToUpload.getDownloadURL();
      print("URL: $newUrlImage");
      completer.complete(newUrlImage); // Set the result in the completer.
    });
  } catch (error) {
    print("Lỗi: $error");
    completer.completeError(error); // Handle errors by completing with an error.
  }

  return completer.future; // Return a Future that will complete when the upload is done.
}

Future<String?> uploadImageToFirebaseStorage(String file) async {
  try {
    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
    // Upload to Firebase
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child("images");
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFilename);

    UploadTask uploadTask = referenceImageToUpload.putFile(File(file));
    
    // Đợi cho đến khi uploadTask hoàn thành
    await uploadTask;
    
    // Lấy URL ngay sau khi uploadTask hoàn thành
    String newUrlImage = await referenceImageToUpload.getDownloadURL();
    print("URL: $newUrlImage");
    
    return newUrlImage; // Trả về URL
  } catch (error) {
    print("Lỗi: $error");
    return null; // Trả về null trong trường hợp lỗi
  }
}


}