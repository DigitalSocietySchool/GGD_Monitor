<?php
	$servername = "localhost";
	$username = "ggd";
	$password = "GGDmonitor";
	$dbname = "GGD_Monitor";
	$port = "8889";

	// Create connection
	$conn = new mysqli($servername, $username, $password, $dbname, $port);

	// Check connection
	if($conn->connect_error) {
		//echo "Connection failed";
	    die("Connection failed: " . $conn->connect_error);
	}
	
	$query = 'DELETE FROM `datasets` WHERE `datasets`.`ID`=' . $_POST["ID"];

	$result = $conn->query($query);
   
    $conn -> close();

?>