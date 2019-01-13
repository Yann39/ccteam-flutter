<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header('Content-Type: application/json');

// include database and object files
include_once '../config/database.php';
include_once '../objects/tracks.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare track object
$track = new Track($db);

// set ID property of record to read
$track->id = isset($_GET['id']) ? $_GET['id'] : die();

// read the details of track to be edited
$track->readOne();

if ($track->title!=null) {

    // create array
    $track_arr = array(
        "id" =>  $track->id,
        "name" =>  $track->name
    );

    // set response code - 200 OK
    http_response_code(200);

    // make it json format
    echo json_encode($track_arr);
} else {

    // set response code - 404 Not found
    http_response_code(404);
}
?>