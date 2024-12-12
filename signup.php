<?php
// Include the database connection file
require 'dbh.php';

// Get the JSON data from the request body
$data = json_decode(file_get_contents("php://input"));

// Check if JSON was decoded successfully
if (json_last_error() !== JSON_ERROR_NONE) {
    echo json_encode(array('success' => false, 'message' => 'Invalid JSON format.'));
    exit;
}

// Check if all required fields are set
if (isset($data->username) && isset($data->email) && isset($data->password)) {
    $username = htmlspecialchars($data->username);
    $email = htmlspecialchars($data->email);
    $password = password_hash($data->password, PASSWORD_DEFAULT); // Hash the password

    // Check if the user already exists
    $sql = "SELECT * FROM users WHERE username = :username OR email = :email";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':username', $username);
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        echo json_encode(array('success' => false, 'message' => 'User already exists.'));
    } else {
        // Insert new user into the database
        $sql = "INSERT INTO users (username, email, password) VALUES (:username, :email, :password)";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':password', $password);

        if ($stmt->execute()) {
            echo json_encode(array('success' => true, 'message' => 'Registration successful.'));
        } else {
            // Fetch error details without directly accessing array index
            $errorInfo = $stmt->errorInfo();
            echo json_encode(array('success' => false, 'message' => 'Error: ' . $errorInfo[2]));
        }
    }
} else {
    echo json_encode(array('success' => false, 'message' => 'Please provide a username, email, and password.'));
}
?>
