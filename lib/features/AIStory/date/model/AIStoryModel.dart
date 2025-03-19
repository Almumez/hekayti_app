class AIStoryModel {
  dynamic id, name, cover_photo, hero_name, painting_style;
  dynamic story_topic, story_data, status, created_at, updated_at;
  List<AIStorySlide>? slides;

  AIStoryModel({
    this.id,
    required this.name,
    required this.cover_photo,
    required this.hero_name,
    required this.painting_style,
    required this.story_topic,
    required this.story_data,
    required this.status,
    required this.created_at,
    required this.updated_at,
    this.slides,
  });

  factory AIStoryModel.fromJson(Map<String, dynamic> story) {
    List<AIStorySlide> slidesList = [];
    
    if (story['slides'] != null) {
      story['slides'].forEach((slide) {
        slidesList.add(AIStorySlide.fromJson(slide));
      });
    }
    
    return AIStoryModel(
      id: story['id'],
      name: story['name'],
      cover_photo: story['cover_photo'],
      hero_name: story['hero_name'],
      painting_style: story['painting_style'],
      story_topic: story['story_topic'],
      story_data: story['story_data'],
      status: story['status'],
      created_at: story['created_at'],
      updated_at: story['updated_at'],
      slides: slidesList,
    );
  }

  AIStoryModel fromJson(Map<String, dynamic> json) {
    return AIStoryModel.fromJson(json);
  }

  factory AIStoryModel.init() {
    return AIStoryModel(
      id: '',
      name: '',
      cover_photo: '',
      hero_name: '',
      painting_style: '',
      story_topic: '',
      story_data: [],
      status: '',
      created_at: '',
      updated_at: '',
      slides: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cover_photo': cover_photo,
        'hero_name': hero_name,
        'painting_style': painting_style,
        'story_topic': story_topic,
        'story_data': story_data,
        'status': status,
        'created_at': created_at,
        'updated_at': updated_at,
        'slides': slides?.map((slide) => slide.toJson()).toList(),
      };
}

class AIStorySlide {
  dynamic id, ai_story_id, page_no, image, text, created_at, updated_at;

  AIStorySlide({
    this.id,
    this.ai_story_id,
    this.page_no,
    this.image,
    this.text,
    this.created_at,
    this.updated_at,
  });

  factory AIStorySlide.fromJson(Map<String, dynamic> json) {
    return AIStorySlide(
      id: json['id'],
      ai_story_id: json['ai_story_id'],
      page_no: json['page_no'],
      image: json['image'],
      text: json['text'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ai_story_id': ai_story_id,
        'page_no': page_no,
        'image': image,
        'text': text,
        'created_at': created_at,
        'updated_at': updated_at,
      };
} 