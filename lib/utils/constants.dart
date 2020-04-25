/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

/// class that holds application global constants
class AppConstants {

  static const String API_ROOT_URL = 'obfuscated';
  static const String SERVER_ROOT_PATH = 'obfuscated';
  static const String SERVER_AVATAR_FOLDER = 'upload/avatars/';

  static const String API_GET_ALL_NEWS_ENDPOINT = '/news/read.php';
  static const String API_GET_SINGLE_NEWS_ENDPOINT = '/news/read_one.php';
  static const String API_CREATE_NEWS_ENDPOINT = '/news/create.php';
  static const String API_UPDATE_NEWS_ENDPOINT = '/news/update.php';
  static const String API_DELETE_NEWS_ENDPOINT = '/news/delete.php';
  static const String API_LIKE_NEWS_ENDPOINT = '/news/like.php';

  static const String API_GET_ALL_MEMBERS_ENDPOINT = '/members/read.php';
  static const String API_GET_SINGLE_MEMBER_ENDPOINT = '/members/read_one.php';
  static const String API_CREATE_MEMBER_ENDPOINT = '/members/create.php';
  static const String API_UPDATE_MEMBER_ENDPOINT = '/members/update.php';
  static const String API_DELETE_MEMBER_ENDPOINT = '/members/delete.php';
  static const String API_LOGIN_MEMBER_ENDPOINT = '/members/login.php';
  static const String API_ASK_PASSWORD_MEMBER_ENDPOINT = '/members/ask_password.php';
  static const String API_UPLOAD_MEMBER_AVATAR_ENDPOINT = '/members/upload_avatar.php';
  static const String API_DELETE_MEMBER_AVATAR_ENDPOINT = '/members/delete_avatar.php';

  static const String API_GET_ALL_EVENTS_ENDPOINT = '/events/read.php';
  static const String API_CREATE_EVENT_ENDPOINT = '/events/create.php';
  static const String API_UPDATE_EVENT_ENDPOINT = '/events/update.php';
  static const String API_DELETE_EVENT_ENDPOINT = '/events/delete.php';

  static const String API_GET_ALL_TRACKS_ENDPOINT = '/tracks/read.php';
  static const String API_CREATE_TRACK_ENDPOINT = '/tracks/create.php';
  static const String API_UPDATE_TRACK_ENDPOINT = '/tracks/update.php';
  static const String API_DELETE_TRACK_ENDPOINT = '/tracks/delete.php';

  static const String API_GET_ALL_PHOTOS_ENDPOINT = '/photos/read.php';
  static const String API_CREATE_PHOTO_ENDPOINT = '/photos/create.php';
  static const String API_UPDATE_PHOTO_ENDPOINT = '/photos/update.php';
  static const String API_DELETE_PHOTO_ENDPOINT = '/photos/delete.php';

  static const String API_GET_ALL_RECORDS_ENDPOINT = '/records/read.php';
  static const String API_GET_TRACK_RECORDS_ENDPOINT = '/records/read_by_track.php';
  static const String API_GET_MEMBER_RECORDS_ENDPOINT = '/records/read_by_member.php';
  static const String API_CREATE_RECORD_ENDPOINT = '/records/create.php';
  static const String API_UPDATE_RECORD_ENDPOINT = '/records/update.php';
  static const String API_DELETE_RECORD_ENDPOINT = '/records/delete.php';

  static const String DATE_FORMAT = 'dd/MM/yyyy HH:mm';
  static const String DATE_FORMAT_TXT = 'dd MMM yyyy HH:mm';
  static const String PRICE_FORMAT = '####.##';

}
