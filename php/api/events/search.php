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
include_once '../config/core.php';
include_once '../config/database.php';
include_once '../objects/events.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare Event object
$event = new Event($db);

// get search string from parameter
$keywords = isset($_GET["s"]) ? $_GET["s"] : "";

// query events and get number of records
$stmt = $event->search($keywords);
$num = $stmt->rowCount();

// if at least one record has been found
if ($num > 0) {

    // events array which will be the returned response content
    $event_arr = array();
    $event_arr["records"] = array();

    // retrieve table content
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

        // extract row, this will make $row['name'] to just $name only
        extract($row);

        // array representing the event
        $event_item = array(
            "id" => $id,
            "title" => $title,
            "description" => $description,
            "event_date" => $event_date,
            "track_id" => $track_id,
            "organizer" => $organizer,
            "price" => $price
        );

        // add it to the events array
        array_push($event_arr["records"], $event_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // display response in json format
    echo json_encode($event_arr);

} else {

    // set response code - 404 Not Found
    http_response_code(404);
}
?>