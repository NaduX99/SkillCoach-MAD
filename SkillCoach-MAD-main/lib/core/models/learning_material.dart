class LearningMaterial {
  final String title;
  final String type;
  final bool isFree;
  final String url;

  LearningMaterial({
    required this.title, required this.type,
    required this.isFree, required this.url,
  });

  factory LearningMaterial.fromJson(Map<String, dynamic> j) =>
      LearningMaterial(
        title:  (j['title']   ?? 'Learning Resource').toString(),
        type:   (j['type']    ?? 'Web Course').toString(),
        isFree: (j['is_free'] is bool) ? j['is_free'] as bool : true,
        url:    (j['url']     ?? '').toString(),
      );

  Map<String, dynamic> toJson() =>
      {'title': title, 'type': type, 'is_free': isFree, 'url': url};
}
