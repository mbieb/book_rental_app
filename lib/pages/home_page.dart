import 'dart:io';

import 'package:book_rental/controllers/book_controller.dart';
import 'package:book_rental/data/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatelessWidget {
  final BookController _bookController = Get.find<BookController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _rentalPriceController = TextEditingController();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Rental'),
      ),
      body: Obx(
        () => _bookController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _bookController.books.length,
                itemBuilder: (context, index) {
                  final book = _bookController.books[index];
                  return ListTile(
                    title: Text(book.title),
                    subtitle: Text(book.author),
                    trailing: Text('Rp.${book.rentalPrice.toStringAsFixed(2)}'),
                    onTap: () => _showEditDialog(context, book),
                    onLongPress: () => _showDeleteDialog(context, book),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext context) async {
    final XFile? imageFile = await _bookController.pickImageFromGallery();

    if (imageFile == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() => AlertDialog(
              title: const Text('Add Book'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(hintText: 'Author'),
                  ),
                  TextField(
                    controller: _rentalPriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'Rental Price'),
                  ),
                  Image.file(
                    File(imageFile.path),
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Get.back();
                  },
                ),
                TextButton(
                  onPressed: _bookController.isLoading.value
                      ? null
                      : () async {
                          final imageUrl =
                              await _bookController.uploadImage(imageFile);
                          final book = Book(
                            title: _titleController.text,
                            author: _authorController.text,
                            rentalPrice:
                                double.parse(_rentalPriceController.text),
                            imageUrl: imageUrl,
                          );
                          _bookController.addBook(book);
                          _resetForm();
                          Get.back();
                        },
                  child: _bookController.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Add'),
                ),
              ],
            ));
      },
    );
  }

  void _showEditDialog(BuildContext context, Book book) {
    _titleController.text = book.title;
    _authorController.text = book.author;
    _rentalPriceController.text = book.rentalPrice.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Book'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(hintText: 'Author'),
              ),
              TextField(
                controller: _rentalPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'Rental Price'),
              ),
              Image.network(
                book.imageUrl,
                width: 50,
                height: 50,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final updatedBook = Book(
                  id: book.id,
                  title: _titleController.text,
                  author: _authorController.text,
                  rentalPrice: double.parse(_rentalPriceController.text),
                  imageUrl: book.imageUrl,
                );
                _bookController.updateBook(updatedBook);
                _resetForm();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  _showDeleteDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: const Text('Are you sure you want to delete this data?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _bookController.deleteBook(book);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  _resetForm() {
    _titleController.text = '';
    _authorController.text = '';
    _rentalPriceController.text = '';
  }
}
