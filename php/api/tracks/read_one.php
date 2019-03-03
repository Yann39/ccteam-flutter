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
include_once '../objects/tracks.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare track object
$track = new Track($db);

// set ID property of record to read
$track->id = isset($_GET['id']) ? $_GET['id'] : die();

// read the details of track to be edited
$track->readOne();

if ($track->title!=null) {

    // create array
    $track_arr = array(
        "id" =>  $track->id,
        "name" =>  $track->name
    );

    // set response code - 200 OK
    http_response_code(200);

    // make it json format
    echo json_encode($track_arr);
} else {

    // set response code - 404 Not found
    http_response_code(404);
}
?>