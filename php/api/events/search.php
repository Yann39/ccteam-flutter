<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// include database and object files
include_once '../config/core.php';
include_once '../config/database.php';
include_once '../objects/events.php';

// instantiate database and event object
$database = new Database();
$db = $database->getConnection();

// initialize object
$event = new Event($db);

// get keywords
$keywords = isset($_GET["s"]) ? $_GET["s"] : "";

// query events
$stmt = $event->search($keywords);
$num = $stmt->rowCount();

// check if more than 0 record found
if ($num > 0) {

    // event array
    $event_arr = array();
    $event_arr["records"] = array();

    // retrieve our table contents
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
            "price" => $price
        );

        array_push($event_arr["records"], $event_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show event data
    echo json_encode($event_arr);
} else {
    // set response code - 404 Not Found
    http_response_code(404);
}
?>