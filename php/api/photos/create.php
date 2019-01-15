<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// get database connection
include_once '../config/database.php';

// instantiate photo object
include_once '../objects/photos.php';

$database = new Database();
$db = $database->getConnection();

$photo = new Photo($db);

// get posted data
$data = json_decode(file_get_contents("php://input"));

// make sure data is not empty
if (!empty($data->title) && !empty($data->description) && !empty($data->photo_date) && !empty($data->track_id) && !empty($data->organizer) && !empty($data->price)) {

    // set photo property values
    $photo->title = $data->title;
    $photo->description = $data->description;
    $photo->link = $data->link;
    $photo->created = date('Y-m-d H:i:s');

    // create the photo
    if ($photo->create()) {
        // set response code - 201 Created
        http_response_code(201);
    }
    // tell the user we were unable to create the photo
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