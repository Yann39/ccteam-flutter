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
    public $bike;
    public $registration_date;
    public $created;
    public $modified;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // read member
    function read() {

        // select all query
        $query = "SELECT n.id, n.first_name, n.last_name, n.email, n.active, n.phone, n.bike, n.registration_date, n.created, n.modified FROM " . $this->table_name . " n ORDER BY n.registration_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // used when filling up the update member form
    function readOne() {

        // query to read single record
        $query = "SELECT n.first_name, n.last_name, n.email, n.active, n.phone, n.bike, n.registration_date, n.created, n.modified FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id of product to be updated
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
        $this->phone = $row['phone'];
        $this->bike = $row['bike'];
        $this->registration_date = $row['registration_date'];
        $this->created = $row['created'];
        $this->modified = $row['modified'];
    }

    // read event
    function readByEvent($event_id) {

        // select all query
        $query = "SELECT n.id, n.first_name, n.last_name, n.email, n.active, n.phone, n.bike, n.registration_date, n.created, n.modified FROM " . $this->table_name . " n INNER JOIN events_members em ON n.id = em.member_id WHERE em.event_id = $event_id ORDER BY n.registration_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // read event
    function readByEmail($email) {

        // select all query
        $query = "SELECT n.email, n.password, n.active FROM " . $this->table_name . " n WHERE n.email = ?";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind id of product to be updated
        $stmt->bindParam(1, $email);

        // execute query
        $stmt->execute();

        // get retrieved row
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        // set values to object properties
        $this->email = $row['email'];
        $this->active = $row['active'];
        $this->phone = $row['password'];
    }

    // create member
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET first_name = :first_name, last_name = :last_name, email = :email, active = :active, phone = :phone, bike = :bike, registration_date = :registration_date, created = :created";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->first_name=htmlspecialchars(strip_tags($this->first_name));
        $this->last_name=htmlspecialchars(strip_tags($this->last_name));
        $this->email=htmlspecialchars(strip_tags($this->email));
        $this->active=htmlspecialchars(strip_tags($this->active));
        $this->phone=htmlspecialchars(strip_tags($this->phone));
        $this->bike=htmlspecialchars(strip_tags($this->bike));
        $this->registration_date=htmlspecialchars(strip_tags($this->registration_date));
        $this->created=htmlspecialchars(strip_tags($this->created));

        // bind values
        $stmt->bindParam(":first_name", $this->first_name);
        $stmt->bindParam(":last_name", $this->last_name);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":active", $this->active);
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

    // update the member
    function update() {

        // update query
        $query = "UPDATE " . $this->table_name . " SET first_name = :first_name, last_name = :last_name, email = :email, active = :active, phone = :phone, bike = :bike, registration_date = :registration_date WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->first_name=htmlspecialchars(strip_tags($this->first_name));
        $this->last_name=htmlspecialchars(strip_tags($this->last_name));
        $this->email=htmlspecialchars(strip_tags($this->email));
        $this->active=htmlspecialchars(strip_tags($this->active));
        $this->phone=htmlspecialchars(strip_tags($this->phone));
        $this->bike=htmlspecialchars(strip_tags($this->bike));
        $this->registration_date=htmlspecialchars(strip_tags($this->registration_date));
        $this->id=htmlspecialchars(strip_tags($this->id));

        // bind new values
        $stmt->bindParam(":first_name", $this->first_name);
        $stmt->bindParam(":last_name", $this->last_name);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":active", $this->active);
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

    // delete the member
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

    // search member
    function search($keywords){

        // select all query
        $query = "SELECT n.first_name, n.last_name, n.email, n.active, n.phone, n.bike, n.registration_date, n.created FROM " . $this->table_name . " n WHERE n.first_name LIKE ? OR n.last_name LIKE ? ORDER BY n.registration_date DESC";

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