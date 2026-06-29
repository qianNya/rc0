import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/user/data/user-api.dart';

void main() {
  test('Profile.fromJson merges /users/me profile and user envelope', () {
    final profile = Profile.fromJson({
      'profile': {
        'bio': '有意义',
        'background_url':
            'http://flight.zjhlife.com:8002/bg-23c704c865bd99805dd690397b613efd.jpg',
        'follower_count': 1,
        'following_count': 0,
        'id': 1,
        'level': 1,
        'screenplay_count': 0,
        'total_likes': 0,
        'user_id': 1,
      },
      'user': {
        'avatar':
            'http://flight.zjhlife.com:8002/23c704c865bd99805dd690397b613efd.jpg',
        'email': '2502203399@qq.com',
        'id': 1,
        'nickname': '有意义',
        'username': 'qianl',
      },
    });

    expect(profile.id, 1);
    expect(profile.username, 'qianl');
    expect(profile.nickname, '有意义');
    expect(profile.bio, '有意义');
    expect(profile.email, '2502203399@qq.com');
    expect(
      profile.avatar,
      'http://flight.zjhlife.com:8002/23c704c865bd99805dd690397b613efd.jpg',
    );
    expect(
      profile.backgroundUrl,
      'http://flight.zjhlife.com:8002/bg-23c704c865bd99805dd690397b613efd.jpg',
    );
    expect(profile.followerCount, 1);
    expect(profile.followingCount, 0);
    expect(profile.level, 1);
  });

  test('Profile.fromJson still supports flat payload', () {
    final profile = Profile.fromFlatJson({
      'id': 2,
      'username': 'alice',
      'nickname': 'Alice',
      'email': 'a@b.com',
      'phone': '',
      'avatar': 'https://cdn.example/1.jpg',
      'background_url': 'https://cdn.example/bg.jpg',
      'bio': 'hello',
      'level': 3,
      'follower_count': 4,
      'following_count': 5,
      'total_likes': 6,
      'screenplay_count': 7,
    });

    expect(profile.username, 'alice');
    expect(profile.avatar, 'https://cdn.example/1.jpg');
    expect(profile.backgroundUrl, 'https://cdn.example/bg.jpg');
  });

  test('PublicUserProfile.fromJson merges public profile envelope', () {
    final profile = PublicUserProfile.fromJson({
      'user': {
        'id': 3,
        'username': 'bob',
        'nickname': 'Bob',
        'avatar': 'https://cdn.example/a.jpg',
      },
      'profile': {
        'bio': 'creator',
        'background_url': 'https://cdn.example/bg.jpg',
        'follower_count': 9,
        'following_count': 2,
        'level': 4,
        'screenplay_count': 1,
        'total_likes': 8,
        'user_id': 3,
      },
      'is_following': true,
    });

    expect(profile.id, 3);
    expect(profile.nickname, 'Bob');
    expect(profile.backgroundUrl, 'https://cdn.example/bg.jpg');
    expect(profile.isFollowing, isTrue);
  });

  test('UpdateProfileReq serializes background_url', () {
    final payload = UpdateProfileReq(
      nickname: 'Alice',
      email: '',
      phone: '',
      avatar: 'https://cdn.example/a.jpg',
      backgroundUrl: 'https://cdn.example/bg.jpg',
      bio: 'hello',
    ).toJson();

    expect(payload['background_url'], 'https://cdn.example/bg.jpg');
  });
}
