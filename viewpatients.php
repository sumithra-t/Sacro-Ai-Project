<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

require "dbh.php"; // Connect to the database

$response = array();

// Fetch patient records (example SELECT query)
try {
    $selectSql = "SELECT id, patient_name, age, gender FROM patient_records";
    $selectStmt = $conn->prepare($selectSql);
    $selectStmt->execute();
    $patients = $selectStmt->fetchAll(PDO::FETCH_ASSOC);
    
    $response['status'] = "success";
    $response['patients'] = $patients; // Add the patient records to the response
} catch (Exception $e) {
    $response['status'] = "error";
    $response['message'] = "Database error on SELECT: " . $e->getMessage();
}

echo json_encode($response);
?>
