<?php
	require_once("c.php");
	
	if($_POST["ID"] != '0' ){
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
	} else {
		$query = "INSERT INTO datasets (ID, name, description, keyword, contact, department, size, `time`, geo, type, population, level, publication, indicator) VALUES (
			NULL, 
			'".$_POST["name"]."', 
			'".$_POST["description"]."', 
			'".str_replace(' ', '', $_POST["keyword"])."', 
			'".$_POST["contact"]."', 
			'".$_POST["department"]."', 
			'".$_POST["size"]."', 
			'".str_replace(' ', '', $_POST["time"])."', 
			'".$_POST["geo"]."', 
			'".str_replace(' ', '', $_POST["type"])."', 
			'".str_replace(' ', '', $_POST["population"])."', 
			'".$_POST["level"]."', 
			'".$_POST["publication"]."', 
			'".str_replace(' ', '', $_POST["indicator"])."')";
	}

	$result = $conn->query($query);
   
    $conn -> close();

?>