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

// make sure email and password have been specified
if (!empty($data->email) && !empty($data->password)) {

    // query members
    $stmt = $member->readByEmail($data->email);

    // check if at least one record has been found
    if ($member->email != null) {

        // members array
        $member_arr = array();
        $member_arr["records"] = array();

        $is_valid = false;
        if (password_verify($data->password, $member->$password)) {
            $is_valid = true;
        }

        $member_item = array("allowed" => $is_valid);
        array_push($member_arr["records"], $member_item);

        // set response code - 200 OK
        http_response_code(200);

        // show response in json format
        echo json_encode($member_arr);

    }

}

// tell the user data is incomplete
else {

    // set response code - 400 Bad Request
    http_response_code(400);
}
?>