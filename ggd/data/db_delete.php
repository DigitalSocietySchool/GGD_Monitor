<?php
	require_once("c.php");
	
	$query = 'DELETE FROM `datasets` WHERE `datasets`.`ID`=' . $_POST["ID"];

	$result = $conn->query($query);
   
    $conn -> close();

?>