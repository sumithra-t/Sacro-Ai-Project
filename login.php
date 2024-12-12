<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

require "dbh.php"; // Connect to the database

// Check if the connection was successful
if (!$conn) {
    echo json_encode(array("status" => "error", "message" => "Database connection failed"));
    exit;
}

// Get the raw POST data as a string
$json_data = file_get_contents("php://input");

// Decode the JSON data into an associative array
$request_data = json_decode($json_data, true);

// Initialize response array
$response = array();

// Check for JSON errors
if (json_last_error() !== JSON_ERROR_NONE) {
    $response['status'] = "error";
    $response['message'] = "Invalid JSON format";
    echo json_encode($response);
    exit;
}

// Validate 'username' and 'password'
if (isset($request_data['username']) && !empty($request_data['username']) && 
    isset($request_data['password']) && !empty($request_data['password'])) {

    $username = $request_data['username'];
    $password = $request_data['password'];

    try {
        // Prepare the SQL statement
        $sql = "SELECT * FROM users WHERE username = :username";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':username', $username, PDO::PARAM_STR);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        // Check if the user exists and verify the password
        if ($result) {
            if (password_verify($password, $result['password'])) {
                $response['status'] = "success";
                $response['message'] = "Login successful!";
            } else {
                $response['status'] = "error";
                $response['message'] = "Invalid username or password";
            }
        } else {
            $response['status'] = "error";
            $response['message'] = "Invalid username or password";
        }

        // Close the prepared statement
        $stmt->closeCursor();
    } catch (Exception $e) {
        // Handle any errors during database operations
        $response['status'] = "error";
        $response['message'] = "Database error: " . $e->getMessage();
    }
} else {
    // Handle missing 'username' or 'password'
    $response['status'] = "error";
    $response['message'] = "Please provide both username and password";
}

// Close the database connection
$conn = null;

// Respond with JSON
echo json_encode($response);
?>
