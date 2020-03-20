<?php
	require_once("c.php");
	//echo "ID,name,description,keywords,contact,department,size,years,geo,type,pop,level\n";


	$query = "SELECT * FROM datasets"; #  ORDER BY `ID` DESC LIMIT 3

	$result = $conn->query($query);

    $data = array();
    
    for ($x = 0; $x < $result->num_rows; $x++) {
        $data[] = $result->fetch_assoc();
    }
    
    print json_encode($data);     
     
    $conn -> close();

?>