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

class Event {

    // database connection and table name
    private $conn;
    private $table_name = "events";

    // object properties
    public $id;
    public $title;
    public $description;
    public $event_date;
    public $track_id;
    public $organizer;
    public $price;
    public $created_on;
    public $created_by;
    public $modified_on;
    public $modified_by;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // get all events
    function read() {

        // query to get all records
        $query = "SELECT n.id, n.title, n.description, n.event_date, n.track_id, n.organizer, n.price, n.created_on, n.created_by, n.modified_on, n.modified_by FROM " . $this->table_name . " n ORDER BY n.event_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get an event given its id
    function readOne() {

        // query to get record corresponding to specified id
        $query = "SELECT n.id, n.title, n.description, n.event_date, n.track_id, n.organizer, n.price, n.created_on, n.created_by, n.modified_on, n.modified_by FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

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
        $this->event_date = $row['event_date'];
        $this->track_id = $row['track_id'];
        $this->organizer = $row['organizer'];
        $this->price = $row['price'];
        $this->created_on = $row['created_on'];
        $this->created_by = $row['created_by'];
        $this->modified_on = $row['modified_on'];
        $this->modified_by = $row['modified_by'];
    }

    // create event
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET title = :title, description = :description, event_date = :event_date, track_id = :track_id, organizer = :organizer, price = :price, created_on = :created_on, created_by = :created_by";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title=htmlspecialchars(strip_tags($this->title));
        $this->description=htmlspecialchars(strip_tags($this->description));
        $this->event_date=htmlspecialchars(strip_tags($this->event_date));
        $this->track_id=htmlspecialchars(strip_tags($this->track_id));
        $this->organizer=htmlspecialchars(strip_tags($this->organizer));
        $this->price=htmlspecialchars(strip_tags($this->price));
        $this->created_on=htmlspecialchars(strip_tags($this->created_on));
        $this->created_by=htmlspecialchars(strip_tags($this->created_by));

        // bind values
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":event_date", $this->event_date);
        $stmt->bindParam(":track_id", $this->track_id);
        $stmt->bindParam(":organizer", $this->organizer);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(":created_on", $this->created_on);
        $stmt->bindParam(":created_by", $this->created_by);

        // execute query
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }

        return -1;
    }

    // update event
    function update() {

        // query to update record
        $query = "UPDATE " . $this->table_name . " SET title = :title, description = :description, event_date = :event_date, track_id = :track_id, organizer = :organizer, price = :price, modified_on = :modified_on, modified_by = :modified_by WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title=htmlspecialchars(strip_tags($this->title));
        $this->description=htmlspecialchars(strip_tags($this->description));
        $this->event_date=htmlspecialchars(strip_tags($this->event_date));
        $this->track_id=htmlspecialchars(strip_tags($this->track_id));
        $this->organizer=htmlspecialchars(strip_tags($this->organizer));
        $this->price=htmlspecialchars(strip_tags($this->price));
        $this->id=htmlspecialchars(strip_tags($this->id));
        $this->modified_on=htmlspecialchars(strip_tags($this->modified_on));
        $this->modified_by=htmlspecialchars(strip_tags($this->modified_by));

        // bind new values
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":event_date", $this->event_date);
        $stmt->bindParam(":track_id", $this->track_id);
        $stmt->bindParam(":organizer", $this->organizer);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(":modified_on", $this->modified_on);
        $stmt->bindParam(":modified_by", $this->modified_by);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete event
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

    // search event
    function search($keywords){

        // query to search across all records
        $query = "SELECT n.title, n.description, n.event_date, n.track_id, n.organizer, n.price, n.created_on, n.created_by, n.modified_on, n.modified_by FROM " . $this->table_name . " n WHERE n.title LIKE ? OR n.description LIKE ? OR n.organizer LIKE ? ORDER BY n.event_date DESC";

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