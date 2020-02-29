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
//	print $results;

/*	if ($result->num_rows > 0) {
	    // output data of each row
	    while($row = $result->fetch_assoc()) {
	        echo $row["id"].", ".$row["name"].", ".$row["description"].", ".$row["keyword"].", ".$row["contact"].", ".$row["department"].", ".$row["size"].", ".$row["time"].", ".$row["geo"].", ".$row["type"].", ".$row["pop"].", ".$row["level"].'\n';
	    }
	} 
*/

    $data = array();
    
    for ($x = 0; $x < $result->num_rows; $x++) {
        $data[] = $result->fetch_assoc();
    }
    
    print json_encode($data);     
     
    $conn -> close();

?>