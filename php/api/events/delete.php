<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include database and object file
include_once '../config/database.php';
include_once '../objects/events.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare product object
$event = new Event($db);

// get event id
$data = json_decode(file_get_contents("php://input"));

// set event id to be deleted
$event->id = $data->id;

// delete the event
if ($event->delete()) {

    // set response code - 204 No Content
    http_response_code(204);
}

// if unable to delete the event
else {

    // set response code - 503 Service Unavailable
    http_response_code(503);
}
?>