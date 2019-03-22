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
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// include needed classes
include_once '../config/database.php';
include_once '../objects/news.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare News object
$news = new News($db);

// get posted data
$data = json_decode(file_get_contents("php://input"));

// like the news
if ($news->like($data->news_id, $data->member_id)) {

    // set response code - 200 OK
    http_response_code(200);
}

// if unable to like the news, tell the user
else{

    // set response code - 503 service unavailable
    http_response_code(503);
}
?>