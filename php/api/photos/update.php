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

<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include database and object files
include_once '../config/database.php';
include_once '../objects/photos.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare photo object
$photo = new Photo($db);

// get id of photo to be edited
$data = json_decode(file_get_contents("php://input"));

// set ID property of photo to be edited
$photo->id = $data->id;

// set photo property values
$photo->title = $data->title;
$photo->description = $data->description;
$photo->link = $data->link;

// update the photo
if ($photo->update()) {

    // set response code - 200 OK
    http_response_code(200);
}

// if unable to update the photo, tell the user
else{

    // set response code - 503 service unavailable
    http_response_code(503);
}
?>