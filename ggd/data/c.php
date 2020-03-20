<?php
$servername = "localhost";
$username = "ggd";
$password = "GGDmonitor";
$dbname = "GGD_Monitor";
$port = "8889";

// Create connection, set to unicode
$conn = new mysqli($servername, $username, $password, $dbname, $port);
$conn->set_charset("utf8mb4");

// Check connection
if($conn->connect_error) {

    die("Connection failed: " . $conn->connect_error);
}