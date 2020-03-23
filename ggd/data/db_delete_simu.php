<?php
	require_once("c.php");
	
	$query = 'DELETE FROM `datasets_simulation` WHERE `ID`=' . $_POST["ID"];

	$result = $conn->query($query);
   
    $conn -> close();

?>