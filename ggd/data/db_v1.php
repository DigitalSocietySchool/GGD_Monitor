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
	//echo "ID,name,description,keywords,contact,department,size,years,geo,type,pop,level\n";


	$query = "SELECT * FROM datasets";

	$result = $conn->query($query);

    $data = array();
    
    for ($x = 0; $x < $result->num_rows; $x++) {
        $data[] = $result->fetch_assoc();
    }
    
    print json_encode($data);     
     
    $conn -> close();

?>