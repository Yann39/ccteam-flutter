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
include_once '../config/database.php';
include_once '../objects/events.php';
include_once '../objects/members.php';

// instantiate database and event object
$database = new Database();
$db = $database->getConnection();

// initialize object
$event = new Event($db);
$member = new Member($db);

// query events
$stmt = $event->read();
$num = $stmt->rowCount();

// check if at least one record has been found
if ($num > 0) {

    // events array
    $event_arr = array();
    $event_arr["records"] = array();

    // retrieve table content
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

        // extract row, this will make $row['name'] to just $name only
        extract($row);

        $stmt2 = $member->readByEvent($id);
        $num2 = $stmt2->rowCount();

        if ($num2 > 0) {

            $member_arr = array();

            // get retrieved rows
            while ($row2 = $stmt2->fetch(PDO::FETCH_ASSOC)) {

                // create array
                $member_item = array(
                    "id" =>  $row2['id'],
                    "first_name" => $row2['first_name'],
                    "last_name" => $row2['last_name'],
                    "email" => $row2['email'],
                    "phone" => $row2['phone'],
                    "bike" => $row2['bike'],
                    "registration_date" => $row2['registration_date']
                );

                array_push($member_arr, $member_item);
            }
        }

        $event_item = array(
            "id" => $id,
            "title" => $title,
            "description" => $description,
            "event_date" => $event_date,
            "track_id" => $track_id,
            "organizer" => $organizer,
            "price" => $price,
            "members" => $member_arr,
            "created" => $created,
            "modified" => $modified
        );

        array_push($event_arr["records"], $event_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show news data in json format
    echo json_encode($event_arr);
} else {

    // set response code - 404 Not Found
    http_response_code(404);
}