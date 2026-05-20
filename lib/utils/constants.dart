/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

const String TEST_INVALID_EMAIL = 'test_example';
const String TEST_VALID_NO_ACCOUNT_EMAIL = 'test@example.com';
const String TEST_VALID_ACCOUNT_EMAIL = 'obfuscated';
const String TEST_USER_FIRST_NAME = 'John';
const String TEST_USER_LAST_NAME = 'Doe';
const String TEST_VALID_JWT = 'obfuscated';
const String TEST_INVALID_JWT = 'aBcDeFgHijKlmNOpQrSTuVWxYz';

const String API_OLD_ROOT_URL = 'obfuscated';
const String API_BASE_URL = String.fromEnvironment('API_BASE_URL');

const String SERVER_AVATAR_FOLDER = 'avatars/';
const String SERVER_PHOTOS_FOLDER = 'photos/';

const String API_GRAPHQL_ENDPOINT = '/graphql';
const String API_AVATARS_ENDPOINT = '/avatars';

const String API_CHECK_ACCOUNT_ENDPOINT = '/rest/checkAccount';
const String API_PRE_REGISTER_ENDPOINT = '/rest/preRegister';
const String API_RESEND_OTP_ENDPOINT = '/rest/resendOtp';
const String API_CONFIRM_EMAIL_ENDPOINT = '/rest/confirmEmail';
const String API_COMPLETE_REGISTRATION_ENDPOINT = '/rest/completeRegistration';
const String API_AUTHENTICATE_ENDPOINT = '/rest/authenticate';

const String LYCHEE_BASE_URL = String.fromEnvironment('LYCHEE_BASE_URL');
const String LYCHEE_ALBUM_ENDPOINT = '/api/v2/Album';
const String LYCHEE_ROOT_ALBUM_ID = String.fromEnvironment('LYCHEE_ROOT_ALBUM_ID');

const String DATE_FORMAT = 'dd/MM/yyyy HH:mm';
const String DATE_FORMAT_TXT = 'dd MMM yyyy HH:mm';
const String PRICE_FORMAT = '####.##';
const int OTP_VALIDITY = 600;
const double UI_FORM_PADDING = 16.0;
const double UI_FORM_FIELD_SPACING = 8.0;
