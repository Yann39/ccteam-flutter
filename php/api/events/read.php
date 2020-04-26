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
include_once '../objects/events.php';
include_once '../objects/tracks.php';
include_once '../objects/members.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare Event and Member objects
$event = new Event($db);
$member = new Member($db);

// query events and get number of records
$stmt = $event->read();
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

        // query members for that specific event and get number of records
        $stmt2 = $member->readByEvent($id);
        $num2 = $stmt2->rowCount();

        // members array to include in the response
        $member_arr = array();

        // if at least one record has been found
        if ($num2 > 0) {

            // get retrieved rows
            while ($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {

                // array representing the member
                $member_item = array(
                    "id" =>  $row2['id'],
                    "first_name" => $row2['first_name'],
                    "last_name" => $row2['last_name'],
                    "email" => $row2['email'],
                    "phone" => $row2['phone'],
                    "bike" => $row2['bike'],
                    "registration_date" => $row2['registration_date']
                );

                // add it to the members array
                array_push($member_arr, $member_item);
            }
        }

        // get full track object
        $track = null;
        if ($track_id != null) {
            $track = new Track($db);
            $track->id = $track_id;
            $track->readOne();
        }

        // get created by member
        $memberCreated = null;
        if ($created_by != null) {
            $memberCreated = new Member($db);
            $memberCreated->id = $created_by;
            $memberCreated->readOne();
        }

        // get created by member
        $memberModified = null;
        if ($modified_by != null) {
            $memberModified = new Member($db);
            $memberModified->id = $created_by;
            $memberModified->readOne();
        }

        // array representing the event
        $event_item = array(
            "id" => $id,
            "title" => $title,
            "description" => $description,
            "event_date" => $event_date,
            "track" => $track,
            "organizer" => $organizer,
            "price" => $price,
            "members" => $member_arr,
            "created_on" => $created_on,
            "created_by" => $memberCreated,
            "modified_on" => $modified_on,
            "modified_by" => $memberModified
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