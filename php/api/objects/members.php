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
class Member {

    // database connection and table name
    private $conn;
    private $table_name = "members";

    // object properties
    public $id;
    public $first_name;
    public $last_name;
    public $email;
    public $phone;
    public $active;
    public $admin;
    public $bike;
    public $registration_date;
    public $created;
    public $modified;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // get all members
    function read() {

        // query to get all records
        $query = "SELECT n.id, n.first_name, n.last_name, n.email, n.active, n.admin, n.phone, n.bike, n.registration_date, n.created, n.modified FROM " . $this->table_name . " n ORDER BY n.registration_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get a member given its id
    function readOne() {

        // query to get record corresponding to specified id
        $query = "SELECT n.first_name, n.last_name, n.email, n.active, n.admin, n.phone, n.bike, n.registration_date, n.created, n.modified FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id
        $stmt->bindParam(1, $this->id);

        // execute query
        $stmt->execute();

        // get retrieved row
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        // set values to object properties
        $this->first_name = $row['first_name'];
        $this->last_name = $row['last_name'];
        $this->email = $row['email'];
        $this->active = $row['active'];
        $this->admin = $row['admin'];
        $this->phone = $row['phone'];
        $this->bike = $row['bike'];
        $this->registration_date = $row['registration_date'];
        $this->created = $row['created'];
        $this->modified = $row['modified'];
    }

    // get all members of the specified event
    function readByEvent($event_id) {

        // query to get all records containing the specified event
        $query = "SELECT n.id, n.first_name, n.last_name, n.email, n.active, n.admin, n.phone, n.bike, n.registration_date, n.created, n.modified FROM " . $this->table_name . " n INNER JOIN events_members em ON n.id = em.member_id WHERE em.event_id = ? ORDER BY n.registration_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id
        $stmt->bindParam(1, $event_id);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get a member given its e-mail address
    function readByEmailForLogin($email) {

        // query to get all records corresponding to the specified e-mail address
        $query = "SELECT n.email, n.password, n.active FROM " . $this->table_name . " n WHERE n.email = ?";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id
        $stmt->bindParam(1, $email);

        // execute query
        $stmt->execute();

        // get retrieved row
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        // set values to object properties
        $this->email = $row['email'];
        $this->active = $row['active'];
        $this->password = $row['password'];
    }

    // create member
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET first_name = :first_name, last_name = :last_name, email = :email, password = :password, active = :active, admin = :admin, phone = :phone, bike = :bike, registration_date = :registration_date, created = :created";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->first_name = htmlspecialchars(strip_tags($this->first_name));
        $this->last_name = htmlspecialchars(strip_tags($this->last_name));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->active = htmlspecialchars(strip_tags($this->active));
        $this->admin = htmlspecialchars(strip_tags($this->admin));
        $this->phone = htmlspecialchars(strip_tags($this->phone));
        $this->bike = htmlspecialchars(strip_tags($this->bike));
        $this->registration_date = htmlspecialchars(strip_tags($this->registration_date));
        $this->created = htmlspecialchars(strip_tags($this->created));

        // bind values
        $stmt->bindParam(":first_name", $this->first_name);
        $stmt->bindParam(":last_name", $this->last_name);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":password", $this->password);
        $stmt->bindParam(":active", $this->active);
        $stmt->bindParam(":admin", $this->admin);
        $stmt->bindParam(":phone", $this->phone);
        $stmt->bindParam(":bike", $this->bike);
        $stmt->bindParam(":registration_date", $this->registration_date);
        $stmt->bindParam(":created", $this->created);

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // update member
    function update() {

        // query to update record
        $query = "UPDATE " . $this->table_name . " SET first_name = :first_name, last_name = :last_name, email = :email, active = :active, admin = :admin, phone = :phone, bike = :bike, registration_date = :registration_date WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->first_name = htmlspecialchars(strip_tags($this->first_name));
        $this->last_name = htmlspecialchars(strip_tags($this->last_name));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->active = htmlspecialchars(strip_tags($this->active));
        $this->admin = htmlspecialchars(strip_tags($this->admin));
        $this->phone = htmlspecialchars(strip_tags($this->phone));
        $this->bike = htmlspecialchars(strip_tags($this->bike));
        $this->registration_date = htmlspecialchars(strip_tags($this->registration_date));
        $this->id = htmlspecialchars(strip_tags($this->id));

        // bind new values
        $stmt->bindParam(":first_name", $this->first_name);
        $stmt->bindParam(":last_name", $this->last_name);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":active", $this->active);
        $stmt->bindParam(":admin", $this->admin);
        $stmt->bindParam(":phone", $this->phone);
        $stmt->bindParam(":bike", $this->bike);
        $stmt->bindParam(":registration_date", $this->registration_date);
        $stmt->bindParam(':id', $this->id);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete member
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

    // search member
    function search($keywords){

        // query to search across all records
        $query = "SELECT n.first_name, n.last_name, n.email, n.active, n.admin, n.phone, n.bike, n.registration_date, n.created FROM " . $this->table_name . " n WHERE n.first_name LIKE ? OR n.last_name LIKE ? ORDER BY n.registration_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $keywords = htmlspecialchars(strip_tags($keywords));
        $keywords = "%{$keywords}%";

        // bind values
        $stmt->bindParam(1, $keywords);
        $stmt->bindParam(2, $keywords);

        // execute query
        $stmt->execute();

        return $stmt;
    }
}