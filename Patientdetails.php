<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

require "dbh.php"; // Connect to the database

$response = array();

// Get input data
$input = json_decode(file_get_contents("php://input"), true);
$patientName = $input['patient_name'];
$age = $input['age'];
$gender = $input['gender'];

// Generate a random id
$id = random_int(100000000, 999999999); // Adjust range as needed for ID length

if (!empty($patientName) && !empty($age) && !empty($gender)) {
    try {
        // Insert patient record with id
        $sql = "INSERT INTO patient_records (id, patient_name, age, gender) VALUES (:id, :patient_name, :age, :gender)";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':patient_name', $patientName);
        $stmt->bindParam(':age', $age);
        $stmt->bindParam(':gender', $gender);

        if ($stmt->execute()) {
            $response['status'] = "success";
            $response['message'] = "Patient saved successfully";
            $response['id'] = $id; // Return the generated id
        } else {
            $response['status'] = "error";
            $response['message'] = "Failed to save patient.";
        }
    } catch (Exception $e) {
        $response['status'] = "error";
        $response['message'] = "Database error: " . $e->getMessage();
    }
} else {
    $response['status'] = "error";
    $response['message'] = "Invalid input.";
}

echo json_encode($response);
?>
