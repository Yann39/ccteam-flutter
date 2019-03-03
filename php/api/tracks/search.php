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

// include database and object files
include_once '../config/core.php';
include_once '../config/database.php';
include_once '../objects/tracks.php';

// instantiate database and track object
$database = new Database();
$db = $database->getConnection();

// initialize object
$track = new Track($db);

// get keywords
$keywords = isset($_GET["s"]) ? $_GET["s"] : "";

// query tracks
$stmt = $track->search($keywords);
$num = $stmt->rowCount();

// check if more than 0 record found
if ($num > 0) {

    // track array
    $track_arr = array();
    $track_arr["records"] = array();

    // retrieve our table contents
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // extract row, this will make $row['name'] to just $name only
        extract($row);

        $track_item = array(
            "id" => $id,
            "name" => name
        );

        array_push($track_arr["records"], $track_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show track data
    echo json_encode($track_arr);
} else {
    // set response code - 404 Not Found
    http_response_code(404);
}
?>