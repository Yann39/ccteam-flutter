<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include database and object file
include_once '../config/database.php';
include_once '../objects/tracks.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare product object
$track = new Track($db);

// get track id
$data = json_decode(file_get_contents("php://input"));

// set track id to be deleted
$track->id = $data->id;

// delete the track
if ($track->delete()) {

    // set response code - 204 No Content
    http_response_code(204);
}

// if unable to delete the track
else {

    // set response code - 503 Service Unavailable
    http_response_code(503);
}
?>