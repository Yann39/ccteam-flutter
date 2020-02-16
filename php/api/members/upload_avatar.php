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
include_once '../objects/members.php';

// get database connection
$database = new Database();
$db = $database->getConnection();

// get uploaded avatar file
if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {

    // load Member object from member id
    $member = new Member($db);
    $member->id = isset($_POST['memberId']) ? $_POST['memberId'] : die();;
    $member->readOne();

    // get details of the uploaded file
    $fileTmpPath = $_FILES['avatar']['tmp_name'];
    $fileName = $_FILES['avatar']['name'];
    $fileSize = $_FILES['avatar']['size'];
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime = finfo_file($finfo, $fileTmpPath);
    $ext = pathinfo($fileName, PATHINFO_EXTENSION);

    // allowed extensions / mime types
    $allowed = array("jpg" => "image/jpg", "jpeg" => "image/jpeg", "gif" => "image/gif", "png" => "image/png");
    $maxSize = 0.5 * 1024 * 1024;

    // check file extension
    if (array_key_exists($ext, $allowed)) {

        // check file mime type
        if (in_array($mime, $allowed)) {

            // check file size (maximum 200 KB)
            if ($fileSize <= $maxSize) {

                    // generate file name
                    $newFileName = $member->id . '_' . md5(time() . $fileName) . '.' . $ext;

                    // create file
                    move_uploaded_file($fileTmpPath, "../../upload/avatars/" . $newFileName);

                    // remove old avatar file if it exists
                    if (file_exists("../../upload/avatars/" . $member->avatar)) {
                        unlink('../../upload/avatars/' . $member->avatar);
                    }

                    // set response code - 200 OK
                    http_response_code(200);

                    // display response in json format
                    echo '{"file":"' . $newFileName . '"}';

            }
            else {
                // set response code - 400 Bad Request
                http_response_code(400);
                exit('File is too big : ' . $fileSize);
            }

        }
        else {
            // set response code - 400 Bad Request
            http_response_code(400);
            exit('File mime type not authorized : ' . $mime);
        }
    }
    else {
        // set response code - 400 Bad Request
        http_response_code(400);
        exit('File extension not authorized : ' . $ext);
    }

}

// if unable to update the member, tell the user
else{

    // set response code - 503 service unavailable
    http_response_code(503);
}
?>