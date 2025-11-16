// To parse this JSON data, do
//
//     final noteModel = noteModelFromJson(jsonString);

import 'dart:convert';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
  dynamic noteId;
  String title;
  String content;
  String createdAt;
  String updatedAt;
  bool pinned;

  NoteModel({
    required this.noteId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.pinned,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final pinnedFromJson = json["pinned"];
    var pinnedValue = pinnedFromJson;

    if (pinnedFromJson is int) {
      pinnedValue = pinnedFromJson == 1;
    } else {
      pinnedValue = false;
    }

    return NoteModel(
      noteId: json["note_id"],
      title: json["title"],
      content: json["content"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      pinned: pinnedValue,
    );
  }

  Map<String, dynamic> toJson() {
    final pinnedConverted = this.pinned ? 1 : 0;

    return {
      "note_id": noteId,
      "title": title,
      "content": content,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "pinned": pinnedConverted,
    };
  }
}
