<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// get database connection
include_once '../config/database.php';

// instantiate event object
include_once '../objects/events.php';

$database = new Database();
$db = $database->getConnection();

$event = new Event($db);

// get posted data
$data = json_decode(file_get_contents("php://input"));

// make sure data is not empty
if (!empty($data->title) && !empty($data->description) && !empty($data->event_date) && !empty($data->track_id) && !empty($data->organizer) && !empty($data->price)) {

    // set event property values
    $event->title = $data->title;
    $event->description = $data->description;
    $event->event_date = $data->event_date;
    $event->track_id = $data->track_id;
    $event->organizer = $data->organizer;
    $event->price = $data->price;
    $event->created = date('Y-m-d H:i:s');

    // create the event
    if ($event->create()) {
        // set response code - 201 Created
        http_response_code(201);
    }
    // tell the user we were unable to create the event
    else {
        // set response code - 503 Service Unavailable
        http_response_code(503);
    }
}

// tell the user data is incomplete
else {

    // set response code - 400 Bad Request
    http_response_code(400);
}
?>