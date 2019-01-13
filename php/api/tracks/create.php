<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// get database connection
include_once '../config/database.php';

// instantiate track object
include_once '../objects/tracks.php';

$database = new Database();
$db = $database->getConnection();

$track = new Track($db);

// get posted data
$data = json_decode(file_get_contents("php://input"));

// make sure data is not empty
if (!empty($data->name) && !empty($data->description)) {

    // set track property values
    $track->name = $data->name;
    $track->description = $data->description;

    // create the track
    if ($track->create()) {
        // set response code - 201 Created
        http_response_code(201);
    }
    // tell the user we were unable to create the track
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