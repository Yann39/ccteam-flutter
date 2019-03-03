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
include_once '../objects/photos.php';

// instantiate database and photo object
$database = new Database();
$db = $database->getConnection();

// initialize object
$photo = new Photo($db);

// get keywords
$keywords = isset($_GET["s"]) ? $_GET["s"] : "";

// query photos
$stmt = $photo->search($keywords);
$num = $stmt->rowCount();

// check if more than 0 record found
if ($num > 0) {

    // photo array
    $photo_arr = array();
    $photo_arr["records"] = array();

    // retrieve our table contents
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // extract row, this will make $row['name'] to just $name only
        extract($row);

        $photo_item = array(
            "id" => $id,
            "title" => $title,
            "description" => $description,
            "link" => $link
        );

        array_push($photo_arr["records"], $photo_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show photo data
    echo json_encode($photo_arr);
} else {
    // set response code - 404 Not Found
    http_response_code(404);
}
?>