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
	

	$query = "UPDATE `datasets` SET 
		`name` = '" . $_POST["name"] . "',
		`description` = '" . $_POST["description"] . "',
		`keyword` = '" . str_replace(' ', '', $_POST["keyword"]) . "',
		`contact` = '" . $_POST["contact"] . "',
		`department` = '" . $_POST["department"] . "',
		`size` = '" . $_POST["size"] . "',
		`time` = '" . str_replace(' ', '', $_POST["time"]) . "',
		`geo` = '" . $_POST["geo"] . "',
		`type` = '" . str_replace(' ', '', $_POST["type"]) . "',
		`population` = '" . str_replace(' ', '', $_POST["population"]) . "',
		`level` = '" . $_POST["level"] . "',
		`indicator` = '" . str_replace(' ', '', $_POST["indicator"]) . "',
		`publication` = '" . $_POST["publication"] . "'
		WHERE `datasets`.`ID` =" . $_POST["ID"];

	$result = $conn->query($query);
   
    $conn -> close();

?>