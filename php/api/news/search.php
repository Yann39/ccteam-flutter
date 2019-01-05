<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// include database and object files
include_once '../config/core.php';
include_once '../config/database.php';
include_once '../objects/news.php';

// instantiate database and news object
$database = new Database();
$db = $database->getConnection();

// initialize object
$news = new News($db);

// get keywords
$keywords = isset($_GET["s"]) ? $_GET["s"] : "";

// query news
$stmt = $news->search($keywords);
$num = $stmt->rowCount();

// check if more than 0 record found
if ($num > 0) {

    // news array
    $news_arr = array();
    $news_arr["records"] = array();

    // retrieve our table contents
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // extract row, this will make $row['name'] to just $name only
        extract($row);

        $news_item = array(
            "id" => $id,
            "title" => $title,
            "content" => html_entity_decode($content),
            "news_date" => $news_date
        );

        array_push($news_arr["records"], $news_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // show news data
    echo json_encode($news_arr);
} else {
    // set response code - 404 Not Found
    http_response_code(404);
}
?>