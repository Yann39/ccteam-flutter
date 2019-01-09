<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// include database and object files
include_once '../config/database.php';
include_once '../objects/members.php';

// instantiate database and member object
$database = new Database();
$db = $database->getConnection();

// initialize object
$member = new Member($db);

// query members
$stmt = $member->read();
$num = $stmt->rowCount();

// check if at least one record has been found
if ($num > 0) {

    // members array
    $member_arr = array();
    $member_arr["records"] = array();

    // retrieve table content
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

        // extract row, this will make $row['name'] to just $name only
        extract($row);

        $member_item = array(
            "id" => $id,
            "first_name" => $first_name,
            "last_name" => $last_name,
            "email" => $email,
            "phone" => $phone,
            "bike" => $bike,
            "registration_date" => $registration_date,
            "created" => $created,
            "modified" => $modified
        );

        array_push($member_arr["records"], $member_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show news data in json format
    echo json_encode($member_arr);
} else {

    // set response code - 404 Not Found
    http_response_code(404);
}