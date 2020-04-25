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

class Record {

    // database connection and table name
    private $conn;
    private $table_name = "records";

    // object properties
    public $id;
    public $track_id;
    public $member_id;
    public $lap_time;
    public $record_date;
    public $conditions;
    public $comments;
    public $created_on;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // get all records
    function read() {

        // query to get all records
        $query = "SELECT r.id, r.track_id, r.member_id, r.lap_time, r.record_date, r.conditions, r.comments, r.created_on FROM " . $this->table_name . " r";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get a record given its id
    function readOne() {

        // query to get record corresponding to specified id
        $query = "SELECT r.id, r.track_id, r.member_id, r.lap_time, r.record_date, r.conditions, r.comments, r.created_on FROM " . $this->table_name . " r WHERE r.id = ? LIMIT 0,1";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id
        $stmt->bindParam(1, $this->id);

        // execute query
        $stmt->execute();

        // get retrieved row
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        // set values to object properties
        $this->track_id = $row['track_id'];
        $this->member_id = $row['member_id'];
        $this->lap_time = $row['lap_time'];
        $this->record_date = $row['record_date'];
        $this->conditions = $row['conditions'];
        $this->comments = $row['comments'];
        $this->created_on = $row['created_on'];
    }

    // get all records for the specified track
    function readByTrack($track_id) {

        // query to get all records containing the specified event
        $query = "SELECT r.id, r.track_id, r.member_id, r.lap_time, r.record_date, r.conditions, r.comments, r.created_on FROM " . $this->table_name . " r WHERE r.track_id = ? ORDER BY r.lap_time ASC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id
        $stmt->bindParam(1, $track_id);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get all records for the specified track
    function readByMember($member_id) {

        // query to get all records containing the specified member
        $query = "SELECT r.id, r.track_id, r.member_id, r.lap_time, r.record_date, r.conditions, r.comments, r.created_on FROM " . $this->table_name . " r WHERE r.member_id = ? ORDER BY r.record_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id
        $stmt->bindParam(1, $member_id);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // create record
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET track_id = :track_id, member_id = :member_id, lap_time = :lap_time, record_date = :record_date, conditions = :conditions, comments = :comments, created_on = :created_on";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->track_id = htmlspecialchars(strip_tags($this->track_id));
        $this->member_id = htmlspecialchars(strip_tags($this->member_id));
        $this->lap_time = htmlspecialchars(strip_tags($this->lap_time));
        $this->record_date = htmlspecialchars(strip_tags($this->record_date));
        $this->conditions = htmlspecialchars(strip_tags($this->conditions));
        $this->comments = htmlspecialchars(strip_tags($this->comments));
        $this->created_on = htmlspecialchars(strip_tags($this->created_on));

        // bind values
        $stmt->bindParam(":track_id", $this->track_id);
        $stmt->bindParam(":member_id", $this->member_id);
        $stmt->bindParam(":lap_time", $this->lap_time);
        $stmt->bindParam(":record_date", $this->record_date);
        $stmt->bindParam(":conditions", $this->conditions);
        $stmt->bindParam(":comments", $this->comments);
        $stmt->bindParam(":created_on", $this->created_on);

        // execute query
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }

        return -1;
    }

    // update record
    function update() {

        // query to update record
        $query = "UPDATE " . $this->table_name . " SET track_id = :track_id, member_id = :member_id, lap_time = :lap_time, record_date = :record_date, conditions = :conditions, comments = :comments WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->track_id = htmlspecialchars(strip_tags($this->track_id));
        $this->member_id = htmlspecialchars(strip_tags($this->member_id));
        $this->lap_time = htmlspecialchars(strip_tags($this->lap_time));
        $this->record_date = htmlspecialchars(strip_tags($this->record_date));
        $this->conditions = htmlspecialchars(strip_tags($this->conditions));
        $this->comments = htmlspecialchars(strip_tags($this->comments));

        // bind new values
        $stmt->bindParam(":track_id", $this->track_id);
        $stmt->bindParam(":member_id", $this->member_id);
        $stmt->bindParam(":lap_time", $this->lap_time);
        $stmt->bindParam(":record_date", $this->record_date);
        $stmt->bindParam(":conditions", $this->conditions);
        $stmt->bindParam(":comments", $this->comments);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete record
    function delete() {

        // query to delete record
        $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->id = htmlspecialchars(strip_tags($this->id));

        // bind id of record to delete
        $stmt->bindParam(1, $this->id);

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

}