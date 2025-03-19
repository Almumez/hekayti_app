class GenritiveAIMode {
  dynamic id, name, cover_photo, hero_name, painting_style;
  dynamic story_topic, story_data, status, created_at, updated_at, slides;

  GenritiveAIMode({
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
    required this.slides,
  });

  factory GenritiveAIMode.fromJson(Map<String, dynamic> story) {
    return GenritiveAIMode(
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
      slides: story['slides'],
    );
  }

  GenritiveAIMode fromJson(Map<String, dynamic> json) {
    return GenritiveAIMode.fromJson(json);
  }

  factory GenritiveAIMode.init() {
    return GenritiveAIMode(
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

  fromJsonList(List<dynamic> jsonList) {
    List<GenritiveAIMode> data = [];
    jsonList.forEach((post) {
      data.add(GenritiveAIMode.fromJson(post));
    });
    return data;
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
        'slides': slides,
      };
}
