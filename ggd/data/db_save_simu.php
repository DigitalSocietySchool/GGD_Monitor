<?php
	require_once("c.php");
	
	if($_POST["ID"] != '0' ){
		$query = "UPDATE `datasets_simulation` SET 
			`name` = '" . mysqli_real_escape_string($conn, $_POST["name"]) . "',
			`description` = '" . mysqli_real_escape_string($conn, $_POST["description"] ). "',
			`keyword` = '" . mysqli_real_escape_string($conn, $_POST["keyword"]). "',
			`contact` = '" . mysqli_real_escape_string($conn, $_POST["contact"]) . "',
			`department` = '" . $_POST["department"] . "',
			`size` = '" . $_POST["size"] . "',
			`time` = '" . str_replace(' ', '', $_POST["time"]) . "',
			`geo` = '" . $_POST["geo"] . "',
			`type` = '" . str_replace(' ', '', $_POST["type"]) . "',
			`population` = '" . str_replace(' ', '', $_POST["population"]) . "',
			`level` = '" . $_POST["level"] . "',
			`indicator` = '" . mysqli_real_escape_string($conn, str_replace(' ', '', $_POST["indicator"]) ). "',
			`publication` = '" . mysqli_real_escape_string($conn, $_POST["publication"]) . "'
			WHERE `datasets_simulation`.`ID` =" . $_POST["ID"];
	} else {
		$query = "INSERT INTO datasets_simulation (ID, name, description, keyword, contact, department, size, `time`, geo, type, population, level, publication, indicator) VALUES (
			NULL, 
			'".mysqli_real_escape_string($conn, $_POST["name"])."', 
			'".mysqli_real_escape_string($conn, $_POST["description"])."', 
			'".mysqli_real_escape_string($conn, str_replace(' ', '', $_POST["keyword"]))."', 
			'".mysqli_real_escape_string($conn, $_POST["contact"])."', 
			'".$_POST["department"]."', 
			'".$_POST["size"]."', 
			'".str_replace(' ', '', $_POST["time"])."', 
			'".$_POST["geo"]."', 
			'".str_replace(' ', '', $_POST["type"])."', 
			'".str_replace(' ', '', $_POST["population"])."', 
			'".$_POST["level"]."', 
			'".mysqli_real_escape_string($conn, $_POST["publication"])."', 
			'".mysqli_real_escape_string($conn, str_replace(' ', '', $_POST["indicator"]))."')";
	}

	$result = $conn->query($query);
   
    $conn -> close();

?>