<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include database and object files
include_once '../config/database.php';
include_once '../objects/tracks.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare track object
$track = new Track($db);

// get id of track to be edited
$data = json_decode(file_get_contents("php://input"));

// set ID property of track to be edited
$track->id = $data->id;

// set track property values
$track->name = $data->name;
$track->description = $data->description;

// update the track
if ($track->update()) {

    // set response code - 200 OK
    http_response_code(200);
}

// if unable to update the track, tell the user
else{

    // set response code - 503 service unavailable
    http_response_code(503);
}
?>