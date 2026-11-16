import '../../city/data/city.dart';
import '../../explore/data/city_catalog.dart';

class PostPlace {
  const PostPlace({
    required this.placeId,
    required this.position,
    this.place,
    this.description,
  });

  final int placeId;
  final int position;
  final CityPlace? place;
  final String? description;

  factory PostPlace.fromMap(Map<String, dynamic> map) => PostPlace(
    placeId: map['place_id'] as int,
    position: map['position'] as int,
    description: map['description'] as String?,
    place: map['places'] == null
        ? null
        : CityPlace.fromMap(map['places'] as Map<String, dynamic>),
  );
}

class PostDetails {
  const PostDetails({
    required this.post,
    required this.categories,
    required this.places,
    this.city,
    this.authorUsername,
  });

  final CityPost post;
  final City? city;
  final String? authorUsername;
  final List<PostCategory> categories;
  final List<PostPlace> places;
}
