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

class Photo {

    // database connection and table name
    private $conn;
    private $table_name = "photos";

    // object properties
    public $id;
    public $title;
    public $description;
    public $link;
    public $created_on;
    public $modified_on;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // get all photos
    function read() {

        // query to get all records
        $query = "SELECT n.id, n.title, n.description, n.link, n.created_on, n.modified_on FROM " . $this->table_name . " n ORDER BY n.created_on DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get a photo given its id
    function readOne() {

        // query to get record corresponding to specified id
        $query = "SELECT n.title, n.description, n.link, n.created_on, n.modified_on FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id
        $stmt->bindParam(1, $this->id);

        // execute query
        $stmt->execute();

        // get retrieved row
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        // set values to object properties
        $this->title = $row['title'];
        $this->description = $row['description'];
        $this->link = $row['link'];
        $this->created_on = $row['created_on'];
        $this->modified_on = $row['modified_on'];
    }

    // create photo
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET title = :title, description = :description, link = :link, created_on = :created_on";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title=htmlspecialchars(strip_tags($this->title));
        $this->description=htmlspecialchars(strip_tags($this->description));
        $this->link=htmlspecialchars(strip_tags($this->link));
        $this->created_on=htmlspecialchars(strip_tags($this->created_on));

        // bind values
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":link", $this->link);
        $stmt->bindParam(":created_on", $this->created_on);

        // execute query
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }

        return -1;
    }

    // update photo
    function update() {

        // query to update record
        $query = "UPDATE " . $this->table_name . " SET title = :title, description = :description, link = :link, modified_on = :modified_on WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title=htmlspecialchars(strip_tags($this->title));
        $this->description=htmlspecialchars(strip_tags($this->description));
        $this->link=htmlspecialchars(strip_tags($this->link));
        $this->id=htmlspecialchars(strip_tags($this->id));
        $this->modified_on=htmlspecialchars(strip_tags($this->modified_on));

        // bind new values
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":link", $this->link);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(':modified_on', $this->modified_on);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete photo
    function delete() {

        // query to delete record
        $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->id=htmlspecialchars(strip_tags($this->id));

        // bind id of record to delete
        $stmt->bindParam(1, $this->id);

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // search photo
    function search($keywords){

        // query to search across all records
        $query = "SELECT n.title, n.description, n.link, n.created_on, n.modified_on FROM " . $this->table_name . " n WHERE n.title LIKE ? OR n.description LIKE ? ORDER BY n.created_on DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $keywords = htmlspecialchars(strip_tags($keywords));
        $keywords = "%{$keywords}%";

        // bind values
        $stmt->bindParam(1, $keywords);
        $stmt->bindParam(2, $keywords);
        $stmt->bindParam(3, $keywords);

        // execute query
        $stmt->execute();

        return $stmt;
    }
}