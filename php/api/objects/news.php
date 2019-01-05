<?php
class News {

    // database connection and table name
    private $conn;
    private $table_name = "news";

    // object properties
    public $id;
    public $title;
    public $content;
    public $news_date;
    public $created;
    public $modified;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // read news
    function read() {

        // select all query
        $query = "SELECT n.id, n.title, n.content, n.news_date, n.created, n.modified FROM " . $this->table_name . " n ORDER BY n.news_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // used when filling up the update news form
    function readOne() {

        // query to read single record
        $query = "SELECT n.title, n.content, n.news_date, n.created, n.modified FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

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
        $this->content = $row['content'];
        $this->news_date = $row['news_date'];
        $this->created = $row['created'];
        $this->modified = $row['modified'];
    }

    // create news
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET title=:title, content=:content, news_date=:news_date, created=:created";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title=htmlspecialchars(strip_tags($this->title));
        $this->content=htmlspecialchars(strip_tags($this->content));
        $this->news_date=htmlspecialchars(strip_tags($this->news_date));
        $this->created=htmlspecialchars(strip_tags($this->created));

        // bind values
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":content", $this->content);
        $stmt->bindParam(":news_date", $this->news_date);
        $stmt->bindParam(":created", $this->created);

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // update the news
    function update() {

        // update query
        $query = "UPDATE " . $this->table_name . " SET title = :title, content = :content, news_date = :news_date WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title=htmlspecialchars(strip_tags($this->title));
        $this->content=htmlspecialchars(strip_tags($this->content));
        $this->news_date=htmlspecialchars(strip_tags($this->news_date));
        $this->id=htmlspecialchars(strip_tags($this->id));

        // bind new values
        $stmt->bindParam(':title', $this->title);
        $stmt->bindParam(':content', $this->content);
        $stmt->bindParam(':news_date', $this->news_date);
        $stmt->bindParam(':id', $this->id);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete the news
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

    // search news
    function search($keywords){

        // select all query
        $query = "SELECT n.title, n.content, n.news_date, n.created FROM " . $this->table_name . " n WHERE n.title LIKE ? OR n.content LIKE ? ORDER BY n.created DESC";

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