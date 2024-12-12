<?php
$conn = new mysqli('localhost', 'root', '', 'hospital'); // Change these to your DB credentials

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$imagePath = $_POST['imagePath'];

$sql = "INSERT INTO upload_table (image_path) VALUES ('$imagePath')"; // Adjust table and column names as necessary

if ($conn->query($sql) === TRUE) {
    echo "Image path saved successfully.";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
