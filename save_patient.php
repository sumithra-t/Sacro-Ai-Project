<?php
header("Content-Type: application/json");
include 'db_connection.php'; // Ensure you have a db_connection.php for database connection

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents("php://input"), true);
    $name = $input['name'];
    $age = $input['age'];
    $gender = $input['gender'];

    if (!empty($name) && !empty($age) && !empty($gender)) {
        $query = "INSERT INTO patient_records (name, age, gender) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("sis", $name, $age, $gender);
        
        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Patient saved successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to save patient"]);
        }
        $stmt->close();
    } else {
        echo json_encode(["success" => false, "message" => "Invalid input"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request"]);
}
$conn->close();
?>
