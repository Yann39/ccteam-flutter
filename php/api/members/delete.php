<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include database and object file
include_once '../config/database.php';
include_once '../objects/members.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare product object
$member = new Member($db);

// get member id
$data = json_decode(file_get_contents("php://input"));

// set member id to be deleted
$member->id = $data->id;

// delete the member
if ($member->delete()) {

    // set response code - 204 No Content
    http_response_code(204);
}

// if unable to delete the member
else {

    // set response code - 503 Service Unavailable
    http_response_code(503);
}
?>