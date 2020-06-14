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

// include needed classes
include_once '../config/database.php';
include_once '../objects/galleries.php';
include_once '../objects/photos.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare Gallery object
$gallery = new Gallery($db);
$photo = new Photo($db);

// query galleries and get number of records
$stmt = $gallery->read();
$num = $stmt->rowCount();

// if at least one record has been found
if ($num > 0) {

    // galleries array which will be the returned response content
    $gallery_arr = array();
    $gallery_arr["records"] = array();

    // retrieve table content
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

        // extract row, this will make $row['name'] to just $name only
        extract($row);

        // query photos for that specific gallery and get number of records
        $stmt2 = $photo->readByGallery($id);
        $num2 = $stmt2->rowCount();

        // photos array to include in the response
        $photo_arr = array();

        // if at least one record has been found
        if ($num2 > 0) {

            // get retrieved rows
            while ($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {

                $photo_item = array(
                    "id" => $row2['id'],
                    "title" => $row2['title'],
                    "description" => $row2['description'],
                    "link" => $row2['link'],
                    "created_on" => $row2['created_on'],
                    "modified_on" => $row2['modified_on']
                );

                // add it to the members array
                array_push($photo_arr, $photo_item);
            }
        }

        // array representing the gallery
        $gallery_item = array(
            "id" => $id,
            "title" => $title,
            "description" => $description,
            "photos" => $photo_arr,
            "created_on" => $created_on,
            "modified_on" => $modified_on
        );

        // add it to the galleries array
        array_push($gallery_arr["records"], $gallery_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // display response in json format
    echo json_encode($gallery_arr);
} else {

    // set response code - 404 Not Found
    http_response_code(404);
}