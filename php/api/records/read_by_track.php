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
include_once '../objects/records.php';
include_once '../objects/tracks.php';
include_once '../objects/members.php';

// get trackId from URL parameter
if (isset($_GET["trackId"]) && !empty($_GET["trackId"])) {

    // get database connection
    $database = new Database();
    $db = $database->getConnection();

    // prepare objects
    $record = new Record($db);
    $track = new Track($db);
    $member = new Member($db);

    // query records and get number of records
    $stmt = $record->readByTrack($_GET["trackId"]);
    $num = $stmt->rowCount();

    // if at least one record has been found
    if ($num > 0) {

        // news array which will be the returned response content
        $records_arr = array();
        $records_arr["records"] = array();

        // query track
        $track->id = $_GET["trackId"];
        $track->readOne($id);

        // retrieve table content
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

            // extract row, this will make $row['name'] to just $name only
            extract($row);

            // query member for that specific record
            $member->id = $row['member_id'];
            $member->readOne($id);

            // array representing the news
            $records_item = array(
                "id" => $id,
                "track" => $track,
                "member" => $member,
                "lap_time" => $lap_time,
                "record_date" => $record_date,
                "conditions" => $conditions,
                "comments" => $comments,
                "created_on" => $created_on
            );

            // add it to the news array
            array_push($records_arr["records"], $records_item);
        }

        // set response code - 200 OK
        http_response_code(200);

        // display response in json format
        echo json_encode($records_arr);
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