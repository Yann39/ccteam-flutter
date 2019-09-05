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
    public $content;
    public $news_date;
    public $created;
    public $modified;

    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }

    // get all news
    function read() {

        // query to get all records
        $query = "SELECT n.id, n.title, n.content, n.news_date, n.created, n.modified FROM " . $this->table_name . " n ORDER BY n.news_date DESC";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // execute query
        $stmt->execute();

        return $stmt;
    }

    // get a news given its id
    function readOne() {

        // query to get record corresponding to specified id
        $query = "SELECT n.title, n.content, n.news_date, n.created, n.modified FROM " . $this->table_name . " n WHERE n.id = ? LIMIT 0,1";

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
        $this->content = $row['content'];
        $this->news_date = $row['news_date'];
        $this->created = $row['created'];
        $this->modified = $row['modified'];
    }

    // create news
    function create() {

        // query to insert record
        $query = "INSERT INTO " . $this->table_name . " SET title = :title, content = :content, news_date = :news_date, created = :created";

        // prepare query
        $stmt = $this->conn->prepare($query);

        // sanitize
        $this->title = htmlspecialchars(strip_tags($this->title));
        $this->content = htmlspecialchars(strip_tags($this->content));
        $this->news_date = htmlspecialchars(strip_tags($this->news_date));
        $this->created = htmlspecialchars(strip_tags($this->created));

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

    // update news
    function update() {

        // query to update record
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
        $query = "SELECT n.title, n.content, n.news_date, n.created FROM " . $this->table_name . " n WHERE n.title LIKE ? OR n.content LIKE ? ORDER BY n.created DESC";

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

        // query to get all records containing the specified event
        $query = "INSERT INTO " . $this->$news_members_table_name . " SET news_id = :news_id, member_id = :member_id, created = :created";

        // prepare query statement
        $stmt = $this->conn->prepare($query);

        // bind data
        $stmt->bindParam(':news_id', $news_id);
        $stmt->bindParam(':member_id', $member_id);
        $stmt->bindParam(':created', date('Y-m-d H:i:s'));

        // execute query
        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    // unlike news
    function unlike($news_id, $member_id) {

        // query to get all records containing the specified event
        $query = "DELETE FROM " . $this->$news_members_table_name . " WHERE news_id = ? AND member_id = ?";

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