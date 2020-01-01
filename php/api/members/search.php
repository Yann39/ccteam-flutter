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

// include needed classes
include_once '../config/core.php';
include_once '../config/database.php';
include_once '../objects/members.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// prepare Member object
$member = new Member($db);

// get search string from parameter
$keywords = isset($_GET["s"]) ? $_GET["s"] : "";

// query members and get number of records
$stmt = $member->search($keywords);
$num = $stmt->rowCount();

// if at least one record has been found
if ($num > 0) {

    // members array which will be the returned response content
    $member_arr = array();
    $member_arr["records"] = array();

    // retrieve our table contents
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {

        // extract row, this will make $row['name'] to just $name only
        extract($row);

        // array representing the member
        $member_item = array(
            "id" => $id,
            "first_name" => $first_name,
            "last_name" => $last_name,
            "email" => $email,
            "active" => $active,
            "admin" => $admin,
            "phone" => $phone,
            "bike" => $bike,
            "registration_date" => $registration_date
            "created_on" => $created_on,
            "modified_on" => $modified_on
        );

        // add it to the members array
        array_push($member_arr["records"], $member_item);
    }

    // set response code - 200 OK
    http_response_code(200);

    // display response in json format
    echo json_encode($member_arr);

} else {

    // set response code - 404 Not Found
    http_response_code(404);
}
?>