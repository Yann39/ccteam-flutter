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
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header('Content-Type: application/json');

// include database and object files
include_once '../config/database.php';
include_once '../objects/photos.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare photo object
$photo = new Photo($db);

// set ID property of record to read
$photo->id = isset($_GET['id']) ? $_GET['id'] : die();

// read the details of photo to be edited
$photo->readOne();

if ($photo->title!=null) {

    // create array
    $photo_arr = array(
        "id" =>  $photo->id,
        "title" =>  $photo->title,
        "description" => $photo->description,
        "link" => $photo->link
    );

    // set response code - 200 OK
    http_response_code(200);

    // make it json format
    echo json_encode($photo_arr);
} else {

    // set response code - 404 Not found
    http_response_code(404);
}
?>