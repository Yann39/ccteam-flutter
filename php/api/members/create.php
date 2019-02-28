<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// get database connection
include_once '../config/database.php';

// instantiate member object
include_once '../objects/members.php';

$database = new Database();
$db = $database->getConnection();

$member = new Member($db);

// get posted data
$data = json_decode(file_get_contents("php://input"));

// make sure data is not empty
if (!empty($data->first_name) && !empty($data->last_name) && !empty($data->email) && !empty($data->password) && !empty($data->phone) && !empty($data->bike) && !empty($data->registration_date)) {

    // hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // set member property values
    $member->first_name = $data->first_name;
    $member->last_name = $data->last_name;
    $member->email = $data->email;
    $member->password = $hashed_password;
    $member->phone = $data->phone;
    $member->bike = $data->bike;
    $member->registration_date = $data->registration_date;
    $member->created = date('Y-m-d H:i:s');

    // create the member
    if ($member->create()) {
        // set response code - 201 Created
        http_response_code(201);
    }
    // tell the user we were unable to create the member
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