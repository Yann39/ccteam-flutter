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
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header('Content-Type: application/json');

// include needed classes
include_once '../config/database.php';
include_once '../objects/members.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare News object
$member = new Member($db);

// set ID property of record to read
$member->id = isset($_GET['id']) ? $_GET['id'] : die();

// read the details of member to be edited
$member->readOne();

if ($member->email != null) {

    // members array which will be the returned response content
    $member_arr = array(
        "id" =>  $member->id,
        "first_name" => $member->first_name,
        "last_name" => $member->last_name,
        "email" => $member->email,
        "avatar" => $member->avatar,
        "active" => $member->active,
        "admin" => $member->admin,
        "phone" => $member->phone,
        "bike" => $member->bike,
        "registration_date" => $member->registration_date,
        "created_on" => $member->created_on,
        "modified_on" => $member->modified_on
    );

    // set response code - 200 OK
    http_response_code(200);

    // display response in json format
    echo json_encode($member_arr);
} else {

    // set response code - 404 Not found
    http_response_code(404);
}
?>