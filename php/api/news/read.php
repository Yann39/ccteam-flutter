<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// include database and object files
include_once '../config/database.php';
include_once '../objects/news.php';

// instantiate database and news object
$database = new Database();
$db = $database->getConnection();

// initialize object
$news = new News($db);

// query news
$stmt = $news->read();
$num = $stmt->rowCount();

// check if at least one record has been found
if ($num > 0) {

    // news array
    $news_arr = array();
    $news_arr["records"] = array();

    // retrieve table content
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

        // extract row, this will make $row['name'] to just $name only
        extract($row);

        $news_item = array(
            "id" => $id,
            "title" => $title,
            "content" => html_entity_decode($content),
            "news_date" => $news_date,
            "created" => $created,
            "modified" => $modified
        );

        array_push($news_arr["records"], $news_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show news data in json format
    echo json_encode($news_arr);
} else {

    // set response code - 404 Not Found
    http_response_code(404);
}