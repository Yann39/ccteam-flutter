<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include database and object files
include_once '../config/database.php';
include_once '../objects/members.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare member object
$member = new Member($db);

// get id of member to be edited
$data = json_decode(file_get_contents("php://input"));

// set ID property of member to be edited
$member->id = $data->id;

// set member property values
$member->first_name = $data->first_name;
$member->last_name = $data->last_name;
$member->email = $data->email;
$member->phone = $data->phone;
$member->bike = $data->bike;
$member->registration_date = $data->registration_date;

// update the member
if ($member->update()) {

    // set response code - 200 OK
    http_response_code(200);
}

// if unable to update the member, tell the user
else{

    // set response code - 503 service unavailable
    http_response_code(503);
}
?>