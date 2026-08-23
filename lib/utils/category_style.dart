import 'package:flutter/material.dart';

Color categoryColor(String category) {
  switch (category) {
    case '업무':
      return Colors.blue;
    case '개인':
      return Colors.green;
    case '공부':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
