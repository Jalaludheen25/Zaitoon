class ApiUrls {
  // ignore: constant_identifier_names
  static const String baseUrl = "https://directus.jihkerala.org";
  static String wpBaseUrl =
      "https://wordpress-1197187-4979850.cloudwaysapps.com/wp-json/wp/v2";

  static const String assetBaseUrl = "https://directus.jihkerala.org/assets/";

  // wordpress
  static String getSpecificPost({required int postId}) {
    return '$wpBaseUrl/posts/$postId';
  }

  static String getFeaturedImage({required int imageId}) {
    return 'media/$imageId';
  }

  static String stories = "$baseUrl/items/d4tales_story";
}
