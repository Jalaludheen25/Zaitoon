class ApiUrls {
  // ignore: constant_identifier_names
  static const String baseUrl = "http://139.59.20.49:8055";
  static String wpBaseUrl =
      "https://wordpress-1197187-4979850.cloudwaysapps.com/wp-json/wp/v2";

  static const String assetBaseUrl = "http://139.59.20.49:8055/assets/";

  // wordpress
  static String getSpecificPost({required int postId}) {
    return '$wpBaseUrl/posts/$postId';
  }

  static String getFeaturedImage({required int imageId}) {
    return 'media/$imageId';
  }
  static String getEpisode(String id) {
    return '$baseUrl/items/zaitoon_episode?filter[story][_eq]=$id';
  }

  static String stories = "$baseUrl/items/zaitoon_stories";
  
}
