class Book {
  final int id;
  final String title;
  final String author;
  final double rentalPrice;
  final String imageUrl;

  Book({
    this.id = 0,
    required this.title,
    required this.author,
    required this.rentalPrice,
    required this.imageUrl,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      rentalPrice: map['rentalPrice'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'rentalPrice': rentalPrice,
      'imageUrl': imageUrl,
    };
  }
}
