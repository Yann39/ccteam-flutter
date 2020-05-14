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
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include needed classes
include_once '../config/database.php';
include_once '../objects/events.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare Event object
$event = new Event($db);

// get posted data
$data = json_decode(file_get_contents("php://input"));

// set event property values
$event->id = $data->id;
$event->title = $data->title;
$event->description = $data->description;
$event->start_date = $data->start_date;
$event->end_date = $data->end_date;
$event->track_id = $data->track_id;
$event->organizer = $data->organizer;
$event->price = $data->price;
$event->modified_on = $data->modified_on;
$event->modified_by = $data->modified_by;

// update the event
if ($event->update()) {

    // set response code - 200 OK
    http_response_code(200);
}

// if unable to update the event, tell the user
else{

    // set response code - 503 service unavailable
    http_response_code(503);
}
?>