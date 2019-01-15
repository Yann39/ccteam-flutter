<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// include database and object files
include_once '../config/database.php';
include_once '../objects/photos.php';

// instantiate database and photo object
$database = new Database();
$db = $database->getConnection();

// initialize object
$photo = new Photo($db);

// query photos
$stmt = $photo->read();
$num = $stmt->rowCount();

// check if at least one record has been found
if ($num > 0) {

    // photos array
    $photo_arr = array();
    $photo_arr["records"] = array();

    // retrieve table content
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

        // extract row, this will make $row['name'] to just $name only
        extract($row);

        $photo_item = array(
            "id" => $id,
            "title" => $title,
            "description" => $description,
            "link" => $link,
            "created" => $created,
            "modified" => $modified
        );

        array_push($photo_arr["records"], $photo_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show news data in json format
    echo json_encode($photo_arr);
} else {

    // set response code - 404 Not Found
    http_response_code(404);
}