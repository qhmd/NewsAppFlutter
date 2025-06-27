import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String formatTimestamp(
  BuildContext context,
  Timestamp? timestamp, {
  bool isEdited = false,
}) {
  if (timestamp == null) return '';
  final dt = timestamp.toDate();
  final formatted =
      "${TimeOfDay.fromDateTime(dt).format(context)} - ${dt.day} ${_monthName(dt.month)} ${dt.year % 100}";
  return isEdited ? "Edited: $formatted" : formatted;
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return months[month - 1];
}