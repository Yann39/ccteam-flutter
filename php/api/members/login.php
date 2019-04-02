<?php
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

// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include needed classes
include_once '../config/database.php';
include_once '../objects/members.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare Member object
$member = new Member($db);

// get posted data
$data = json_decode(file_get_contents("php://input"));

// make sure email and password have been specified
if (!empty($data->email) && !empty($data->password)) {

    // query members
    $member->readByEmail($data->email);

    // check if at least one record has been found
    if ($member->email != null) {

        // if member is active
        if ($member->active == true) {

            if (password_verify($data->password, $member->password)) {
                // set response code - 200 OK
                http_response_code(200);
            } else {
                // set response code - 401 Unauthorized
                http_response_code(401);
            }

        } else {
            // set response code - 403 Forbidden
            http_response_code(403);
        }

    } else {
        // set response code - 404 Not Found
        http_response_code(404);
    }

}

// tell the user data is incomplete
else {

    // set response code - 400 Bad Request
    http_response_code(400);
}
?>