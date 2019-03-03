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

<?php
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
    public $created;
    public $modified;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // read event
    function read() {

        // select all query
        $query = "SELECT n.id, n.title, n.description, n.event_date, n.track_id, n.organizer, n.price, n.created, n.modified FROM " . $this->table_name . " n ORDER BY n.event_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // used when filling up the update event form
    function readOne() {

        // query to read single record
        $query = "SELECT n.title, n.description, n.event_date, n.track_id, n.organizer, n.price, n.created, n.modified FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id of product to be updated
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
        $this->created = $row['created'];
        $this->modified = $row['modified'];
    }

    // create event
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET title = :title, description = :description, event_date = :event_date, track_id = :track_id, organizer = :organizer, price = :price, created = :created";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title=htmlspecialchars(strip_tags($this->title));
        $this->description=htmlspecialchars(strip_tags($this->description));
        $this->event_date=htmlspecialchars(strip_tags($this->event_date));
        $this->track_id=htmlspecialchars(strip_tags($this->track_id));
        $this->organizer=htmlspecialchars(strip_tags($this->organizer));
        $this->price=htmlspecialchars(strip_tags($this->price));
        $this->created=htmlspecialchars(strip_tags($this->created));

        // bind values
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":event_date", $this->event_date);
        $stmt->bindParam(":track_id", $this->track_id);
        $stmt->bindParam(":organizer", $this->organizer);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(":created", $this->created);

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // update the event
    function update() {

        // update query
        $query = "UPDATE " . $this->table_name . " SET title = :title, description = :description, event_date = :event_date, track_id = :track_id, organizer = :organizer, price = :price WHERE id = :id";

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

        // bind new values
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":event_date", $this->event_date);
        $stmt->bindParam(":track_id", $this->track_id);
        $stmt->bindParam(":organizer", $this->organizer);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(':id', $this->id);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete the event
    function delete() {

        // delete query
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

        // select all query
        $query = "SELECT n.title, n.description, n.event_date, n.track_id, n.organizer, n.price, n.created FROM " . $this->table_name . " n WHERE n.title LIKE ? OR n.description LIKE ? OR n.organizer LIKE ? ORDER BY n.event_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $keywords = htmlspecialchars(strip_tags($keywords));
        $keywords = "%{$keywords}%";

        // bind
        $stmt->bindParam(1, $keywords);
        $stmt->bindParam(2, $keywords);
        $stmt->bindParam(3, $keywords);

        // execute query
        $stmt->execute();

        return $stmt;
    }
}