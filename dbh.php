<?php
$host = "localhost"; 
$username = "root"; 
$password = ""; 
$dbname = "hospital"; 

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);  // This line ensures you get detailed error messages
} catch(PDOException $e) {
    echo "Connection failed: " . $e->getMessage();  // Catch any connection error and display the message
}

?>
