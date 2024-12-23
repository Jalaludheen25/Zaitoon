class ApiUrls {
  // ignore: constant_identifier_names
  static const String baseUrl = "https://directus.jihkerala.org";
  static String wpBaseUrl =
      "https://wordpress-1197187-4979850.cloudwaysapps.com/wp-json/wp/v2";

  static const String assetBaseUrl = "https://directus.jihkerala.org/assets/";

  static const String oneSignalAppId = "276a85c4-2c81-4340-ac7e-3155826f2e69";

  // Kids Corner endpoints
  static const String kidsSubmission = "$baseUrl/items/zaitoon_kids_submission";
  static const String kidsFiles = "$baseUrl/files";
  static String getPublishedKidsContent() {
    return "$kidsSubmission?filter[status][_eq]=published";
  }

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

  static String highlightedEpisodes =
      "$baseUrl/items/zaitoon_episode?filter[isHighlighted][_eq]=true";

  static String highlightedStories =
      "$baseUrl/items/zaitoon_single_story?filter[isHighlighted][_eq]=true";
}
