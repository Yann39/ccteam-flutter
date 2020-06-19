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

class News {

    // database connection and table name
    private $conn;
    private $table_name = "news";
    private $news_members_table_name = "news_members";

    // object properties
    public $id;
    public $title;
    public $catch_line;
    public $content;
    public $news_date;
    public $created_on;
    public $created_by;
    public $modified_on;
    public $modified_by;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // get all news
    function read() {

        // query to get all records
        $query = "SELECT n.id, n.title, n.catch_line, n.content, n.news_date, n.created_on, n.created_by, n.modified_on, n.modified_by FROM " . $this->table_name . " n ORDER BY n.news_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get a news given its id
    function readOne() {

        // query to get record corresponding to specified id
        $query = "SELECT n.title, n.catch_line, n.content, n.news_date, n.created_on, n.created_by, n.modified_on, n.modified_by FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

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
        $this->catch_line = $row['catch_line'];
        $this->content = $row['content'];
        $this->news_date = $row['news_date'];
        $this->created_on = $row['created_on'];
        $this->created_by = $row['created_by'];
        $this->modified_on = $row['modified_on'];
        $this->modified_by = $row['modified_by'];
    }

    // create news
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET title = :title, catch_line = :catch_line, content = :content, news_date = :news_date, created_on = :created_on, created_by = :created_by";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title = htmlspecialchars(strip_tags($this->title));
        $this->catch_line = htmlspecialchars(strip_tags($this->catch_line));
        $this->content = htmlspecialchars(strip_tags($this->content));
        $this->news_date = htmlspecialchars(strip_tags($this->news_date));
        $this->created_on = htmlspecialchars(strip_tags($this->created_on));
        $this->created_by = htmlspecialchars(strip_tags($this->created_by));

        // bind values
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":catch_line", $this->catch_line);
        $stmt->bindParam(":content", $this->content);
        $stmt->bindParam(":news_date", $this->news_date);
        $stmt->bindParam(":created_on", $this->created_on);
        $stmt->bindParam(":created_by", $this->created_by);

        // execute query
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }

        return -1;
    }

    // update news
    function update() {

        // query to update record
        $query = "UPDATE " . $this->table_name . " SET title = :title, catch_line = :catch_line, content = :content, news_date = :news_date, modified_on = :modified_on, modified_by = :modified_by WHERE id = :id";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title = htmlspecialchars(strip_tags($this->title));
        $this->catch_line = htmlspecialchars(strip_tags($this->catch_line));
        $this->content = htmlspecialchars(strip_tags($this->content));
        $this->news_date = htmlspecialchars(strip_tags($this->news_date));
        $this->id = htmlspecialchars(strip_tags($this->id));
        $this->modified_on = htmlspecialchars(strip_tags($this->modified_on));
        $this->modified_by = htmlspecialchars(strip_tags($this->modified_by));

        // bind new values
        $stmt->bindParam(':title', $this->title);
        $stmt->bindParam(':catch_line', $this->catch_line);
        $stmt->bindParam(':content', $this->content);
        $stmt->bindParam(':news_date', $this->news_date);
        $stmt->bindParam(':id', $this->id);
        $stmt->bindParam(":modified_on", $this->modified_on);
        $stmt->bindParam(":modified_by", $this->modified_by);

        // execute the query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // delete news
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

    // search news
    function search($keywords){

        // query to search across all records
        $query = "SELECT n.title, n.catch_line, n.content, n.news_date, n.created_on, n.created_by, n.modified_on, n.modified_by FROM " . $this->table_name . " n WHERE n.title LIKE ? OR n.catch_line LIKE ? OR n.content LIKE ? ORDER BY n.created_on DESC";

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

    // like news
    function like($news_id, $member_id) {

        // query
        $query = "INSERT INTO " . $this->news_members_table_name . " SET news_id = :news_id, member_id = :member_id, created_on = :created_on";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind data
        $stmt->bindParam(':news_id', $news_id);
        $stmt->bindParam(':member_id', $member_id);
        $stmt->bindParam(':created_on', date('Y-m-d H:i:s'));

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // unlike news
    function unlike($news_id, $member_id) {

        // query
        $query = "DELETE FROM " . $this->news_members_table_name . " WHERE news_id = ? AND member_id = ?";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind data
        $stmt->bindParam(1, $news_id);
        $stmt->bindParam(2, $member_id);

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }
}