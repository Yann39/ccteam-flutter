<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header('Content-Type: application/json');

// include database and object files
include_once '../config/database.php';
include_once '../objects/events.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare event object
$event = new Event($db);

// set ID property of record to read
$event->id = isset($_GET['id']) ? $_GET['id'] : die();

// read the details of event to be edited
$event->readOne();

if ($event->title!=null) {

    // create array
    $event_arr = array(
        "id" =>  $event->id,
        "title" =>  $event->title,
        "description" => $event->description,
        "event_date" => $event->event_date,
        "track_id" => $event->track_id,
        "organizer" => $event->organizer,
        "price" => $event->price
    );

    // set response code - 200 OK
    http_response_code(200);

    // make it json format
    echo json_encode($event_arr);
} else {

    // set response code - 404 Not found
    http_response_code(404);
}
?>