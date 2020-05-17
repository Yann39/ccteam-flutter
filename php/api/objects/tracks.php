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

class Track {

    // database connection and table name
    private $conn;
    private $table_name = "tracks";

    // object properties
    public $id;
    public $name;
    public $distance;
    public $lap_record;
    public $website;
    public $latitude;
    public $longitude;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // get all tracks
    function read() {

        // query to get all records
        $query = "SELECT n.id, n.name, n.distance, n.lap_record, n.website, n.latitude, n.longitude FROM " . $this->table_name . " n ORDER BY n.name";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get a track given its id
    function readOne() {

        // query to get record corresponding to specified id
        $query = "SELECT n.id, n.name, n.distance, n.lap_record, n.website, n.latitude, n.longitude FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id
        $stmt->bindParam(1, $this->id);

        // execute query
        $stmt->execute();

        // get retrieved row
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        // set values to object properties
        $this->name = $row['name'];
        $this->distance = $row['distance'];
        $this->lap_record = $row['lap_record'];
        $this->website = $row['website'];
        $this->latitude = $row['latitude'];
        $this->longitude = $row['longitude'];
    }

    // create track
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET name = :name, distance = :distance, lap_record = :lap_record, website = :website, latitude = :latitude, longitude = :longitude";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->name=htmlspecialchars(strip_tags($this->name));
        $this->distance=htmlspecialchars(strip_tags($this->distance));
        $this->lap_record=htmlspecialchars(strip_tags($this->lap_record));
        $this->website=htmlspecialchars(strip_tags($this->website));
        $this->latitude=htmlspecialchars(strip_tags($this->latitude));
        $this->longitude=htmlspecialchars(strip_tags($this->longitude));

        // bind values
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":distance", $this->distance);
        $stmt->bindParam(":lap_record", $this->lap_record);
        $stmt->bindParam(":website", $this->website);
        $stmt->bindParam(":latitude", $this->latitude);
        $stmt->bindParam(":longitude", $this->longitude);

        // execute query
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }

        return -1;
    }

    // update track
    function update() {

        // query to update record
        $query = "UPDATE " . $this->table_name . " SET name = :name, distance = :distance, lap_record = :lap_record, website = :website, latitude = :latitude, longitude = :longitude WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->id=htmlspecialchars(strip_tags($this->id));
        $this->name=htmlspecialchars(strip_tags($this->name));
        $this->distance=htmlspecialchars(strip_tags($this->distance));
        $this->lap_record=htmlspecialchars(strip_tags($this->lap_record));
        $this->website=htmlspecialchars(strip_tags($this->website));
        $this->latitude=htmlspecialchars(strip_tags($this->latitude));
        $this->longitude=htmlspecialchars(strip_tags($this->longitude));

        // bind new values
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":distance", $this->distance);
        $stmt->bindParam(":lap_record", $this->lap_record);
        $stmt->bindParam(":website", $this->website);
        $stmt->bindParam(":latitude", $this->latitude);
        $stmt->bindParam(":longitude", $this->longitude);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete track
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

    // search track
    function search($keywords){

        // query to search across all records
        $query = "SELECT n.name, n.distance, n.lap_record, n.website, n.latitude, n.longitude FROM " . $this->table_name . " n WHERE n.name LIKE ? ORDER BY n.name DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $keywords = htmlspecialchars(strip_tags($keywords));
        $keywords = "%{$keywords}%";

        // bind values
        $stmt->bindParam(1, $keywords);

        // execute query
        $stmt->execute();

        return $stmt;
    }
}