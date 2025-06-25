String generateCommentId(String uid) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'comment_${timestamp}_$uid';
}
