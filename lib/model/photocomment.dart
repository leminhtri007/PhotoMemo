class PhotoComment {
  String docId;
  String photoId;
  String email;
  DateTime timestamp;
  String content;

  static const PHOTO_ID = 'photoId';
  static const EMAIL = 'email';
  static const TIMESTAMP = 'timestamp';
  static const CONTENT = 'content';

  PhotoComment({
    this.docId,
    this.photoId,
    this.email,
    this.timestamp,
    this.content,
  });

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      PHOTO_ID: this.photoId,
      EMAIL: this.email,
      TIMESTAMP: this.timestamp,
      CONTENT: this.content,
    };
  }

  static PhotoComment deserialize(Map<String, dynamic> doc, String docId) {
    return PhotoComment(
      docId: docId,
      photoId: doc[PHOTO_ID],
      email: doc[EMAIL],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
      content: doc[CONTENT],
    );
  }
}
