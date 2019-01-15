<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include database and object files
include_once '../config/database.php';
include_once '../objects/photos.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare photo object
$photo = new Photo($db);

// get id of photo to be edited
$data = json_decode(file_get_contents("php://input"));

// set ID property of photo to be edited
$photo->id = $data->id;

// set photo property values
$photo->title = $data->title;
$photo->description = $data->description;
$photo->link = $data->link;

// update the photo
if ($photo->update()) {

    // set response code - 200 OK
    http_response_code(200);
}

// if unable to update the photo, tell the user
else{

    // set response code - 503 service unavailable
    http_response_code(503);
}
?>