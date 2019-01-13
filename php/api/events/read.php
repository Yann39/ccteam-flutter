<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// include database and object files
include_once '../config/database.php';
include_once '../objects/events.php';

// instantiate database and event object
$database = new Database();
$db = $database->getConnection();

// initialize object
$event = new Event($db);

// query events
$stmt = $event->read();
$num = $stmt->rowCount();

// check if at least one record has been found
if ($num > 0) {

    // events array
    $event_arr = array();
    $event_arr["records"] = array();

    // retrieve table content
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

        // extract row, this will make $row['name'] to just $name only
        extract($row);

        $event_item = array(
            "id" => $id,
            "title" => $title,
            "description" => $description,
            "event_date" => $event_date,
            "track_id" => $track_id,
            "organizer" => $organizer,
            "price" => $price,
            "created" => $created,
            "modified" => $modified
        );

        array_push($event_arr["records"], $event_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show news data in json format
    echo json_encode($event_arr);
} else {

    // set response code - 404 Not Found
    http_response_code(404);
}