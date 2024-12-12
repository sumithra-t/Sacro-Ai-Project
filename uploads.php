<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$servername = "localhost";
$username = "root";
$password = ""; // Update with your MySQL root password
$dbname = "hospital"; // Update with your database name

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(array("status" => "error", "message" => "Connection failed: " . $conn->connect_error)));
}

// Folder where images will be uploaded
$targetDir = "uploads/";

if (!file_exists($targetDir)) {
    mkdir($targetDir, 0777, true);
}

// Get the file from the form input
if (isset($_FILES["image"])) {
    $targetFile = $targetDir . basename($_FILES["image"]["name"]);
    $uploadOk = 1;
    $imageFileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));

    // Check if image file is an actual image
    $check = getimagesize($_FILES["image"]["tmp_name"]);
    if ($check === false) {
        echo json_encode(array("status" => "error", "message" => "File is not an image."));
        $uploadOk = 0;
    }

    // Check if file already exists
    if (file_exists($targetFile)) {
        echo json_encode(array("status" => "error", "message" => "Sorry, file already exists."));
        $uploadOk = 0;
    }

    // Check file size (limit to 5MB)
    if ($_FILES["image"]["size"] > 5000000) {
        echo json_encode(array("status" => "error", "message" => "Sorry, your file is too large."));
        $uploadOk = 0;
    }

    // Only allow specific formats
    if (!in_array($imageFileType, array("jpg", "jpeg", "png", "gif"))) {
        echo json_encode(array("status" => "error", "message" => "Only JPG, JPEG, PNG & GIF files are allowed."));
        $uploadOk = 0;
    }

    // If everything is ok, upload the file
    if ($uploadOk == 1) {
        if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
            $stmt = $conn->prepare("INSERT INTO images (image_path) VALUES (?)");
            if ($stmt === false) {
                echo json_encode(array("status" => "error", "message" => "Database error: " . $conn->error));
            } else {
                $stmt->bind_param("s", $targetFile);
                if ($stmt->execute()) {
                    echo json_encode(array("status" => "success", "message" => "Image uploaded and saved successfully."));
                } else {
                    echo json_encode(array("status" => "error", "message" => "Error saving image path: " . $stmt->error));
                }
                $stmt->close();
            }
        } else {
            echo json_encode(array("status" => "error", "message" => "Error uploading file."));
        }
    }
} else {
    echo json_encode(array("status" => "error", "message" => "No file uploaded."));
}

$conn->close();
?>
