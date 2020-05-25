<?php
/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of Chachatte Team application.
 *
 * Chachatte Team is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chachatte Team is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chachatte Team. If not, see <http://www.gnu.org/licenses/>.
 */

// required headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Credentials: true");
header('Content-Type: application/json');

// include needed classes
include_once '../config/database.php';
include_once '../objects/news.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare News object
$news = new News($db);

// set ID property of record to read
$news->id = isset($_GET['id']) ? $_GET['id'] : die();

// read the details of news to be edited
$news->readOne();

if ($news->title != null) {

    // news array which will be the returned response content
    $news_arr = array(
        "id" =>  $news->id,
        "title" => $news->title,
        "catch_line" => $news->catch_line,
        "content" => $news->content,
        "news_date" => $news->news_date,
        "created_on" => $news->created_on,
        "created_by" => $news->created_by,
        "modified_on" => $news->modified_on,
        "modified_by" => $news->modified_by
    );

    // set response code - 200 OK
    http_response_code(200);

    // display response in json format
    echo json_encode($news_arr);
} else {

    // set response code - 404 Not found
    http_response_code(404);
}
?>