<?php
class Track {

    // database connection and table name
    private $conn;
    private $table_name = "tracks";

    // object properties
    public $id;
    public $name;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // read track
    function read() {

        // select all query
        $query = "SELECT n.id, n.name, n.description FROM " . $this->table_name . " n ORDER BY n.name";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // used when filling up the update track form
    function readOne() {

        // query to read single record
        $query = "SELECT n.name, n.description FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id of product to be updated
        $stmt->bindParam(1, $this->id);

        // execute query
        $stmt->execute();

        // get retrieved row
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        // set values to object properties
        $this->name = $row['name'];
        $this->description = $row['description'];
    }

    // create track
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET name = :name, description = :description";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->name=htmlspecialchars(strip_tags($this->name));
        $this->description=htmlspecialchars(strip_tags($this->description));

        // bind values
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":description", $this->description);

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // update the track
    function update() {

        // update query
        $query = "UPDATE " . $this->table_name . " SET name = :name, description = :description WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->name=htmlspecialchars(strip_tags($this->name));
        $this->description=htmlspecialchars(strip_tags($this->description));
        $this->id=htmlspecialchars(strip_tags($this->id));

        // bind new values
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(':id', $this->id);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete the track
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

    // search track
    function search($keywords){

        // select all query
        $query = "SELECT n.name, n.description FROM " . $this->table_name . " n WHERE n.name LIKE ? OR n.description LIKE ? ORDER BY n.name DESC";

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