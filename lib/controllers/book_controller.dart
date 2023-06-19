import 'dart:io';

import 'package:book_rental/data/databases/database_helper.dart';
import 'package:book_rental/data/models/book_model.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class BookController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();
  var books = <Book>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }

  void fetchBooks() async {
    try {
      isLoading(true);
      books.value = await _databaseHelper.getBooks();
    } finally {
      isLoading(false);
    }
  }

  void addBook(Book book) async {
    try {
      isLoading(true);
      await _databaseHelper.insertBook(book);
      books.add(book);
      Get.snackbar('Success', 'Book added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add book');
    } finally {
      isLoading(false);
    }
  }

  void updateBook(Book book) async {
    try {
      isLoading(true);
      await _databaseHelper.updateBook(book);
      final index = books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        books[index] = book;
      }
      books.refresh();
      Get.snackbar('Success', 'Book updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update book');
    } finally {
      isLoading(false);
    }
  }

  void deleteBook(Book book) async {
    try {
      isLoading(true);
      await _databaseHelper.deleteBook(book.id);
      books.remove(book);
      Get.snackbar('Success', 'Book deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete book');
    } finally {
      isLoading(false);
    }
  }

  Future<String> uploadImage(XFile imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final filePath = '${directory.path}/$fileName';

    try {
      isLoading(true);
      final file = File(imageFile.path);
      final destinationFile = File(filePath);
      await file.copy(destinationFile.path);

      final ref = _storage.ref('book_covers/$fileName');
      await ref.putFile(File(imageFile.path));
      final downloadUrl = await ref.getDownloadURL();

      destinationFile.delete();

      return downloadUrl;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image');
      throw e;
    } finally {
      isLoading(false);
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image from gallery');
      throw e;
    }
  }
}
