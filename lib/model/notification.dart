class NotificationComment {
  String docId;
  String photoId;
  String ownerEmail;
  String email;
  DateTime timestamp;
  String photoURL;
  String content;

  static const PHOTO_ID = 'photoId';
  static const OWNER_EMAIL = 'ownerEmail';
  static const EMAIL = 'email';
  static const TIMESTAMP = 'timestamp';
  static const PHOTO_URL = 'photoURL';
  static const CONTENT = 'content';

  NotificationComment({
    this.docId,
    this.photoId,
    this.ownerEmail,
    this.email,
    this.timestamp,
    this.photoURL,
    this.content,
  });

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      PHOTO_ID: this.photoId,
      OWNER_EMAIL: this.ownerEmail,
      EMAIL: this.email,
      TIMESTAMP: this.timestamp,
      PHOTO_URL: this.photoURL,
      CONTENT: this.content,
    };
  }

  static NotificationComment deserialize(Map<String, dynamic> doc, String docId) {
    return NotificationComment(
      docId: docId,
      photoId: doc[PHOTO_ID],
      ownerEmail: doc[OWNER_EMAIL],
      email: doc[EMAIL],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
      photoURL: doc[PHOTO_URL],
      content: doc[CONTENT],
    );
  }
}
