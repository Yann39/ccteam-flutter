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

// make sure required data is not empty
if (!empty($data->first_name) && !empty($data->last_name) && !empty($data->email) && !empty($data->password)) {

    // hash password
    $hashed_password = password_hash($data->password, PASSWORD_DEFAULT);

    // set mandatory member property values
    $member->first_name = $data->first_name;
    $member->last_name = $data->last_name;
    $member->email = $data->email;
    $member->password = $hashed_password;

    // set non mandatory properties if they are set
    if ($data->phone != null) {
        $member->phone = $data->phone;
    }
    if ($data->bike != null) {
        $member->bike = $data->bike;
    }
    $member->registration_date = date('Y-m-d H:i:s');
    if ($data->registration_date != null) {
        $member->registration_date = $data->registration_date;
    }
    $member->active = false;
    if ($data->active != null) {
        $member->active = $data->active;
    }
    $member->admin = false;
    if ($data->admin != null) {
        $member->admin = $data->admin;
    }
    $member->created_on = date('Y-m-d H:i:s');

    // create the member
    $createdId = $member->create();

    // if created successfully we should get the ID
    if ($createdId > -1) {
        // set response code - 201 Created
        http_response_code(201);

        // add URI of the new created item to location header
        header("Location: /members/read_one.php?id=" . $createdId);
    }
    // tell the user we were unable to create the member
    else {
        // set response code - 503 Service Unavailable
        http_response_code(503);
    }
}

// tell the user data is incomplete
else {

    // set response code - 400 Bad Request
    http_response_code(400);
}
?>