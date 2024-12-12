<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "hospital"; // Updated database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(array('message' => "Connection failed: " . $conn->connect_error));

    exit();
}


// Handle different API methods
$method = $_SERVER['REQUEST_METHOD'];
switch ($method) {
    case 'GET':
        getPatients($conn);
        break;
    case 'POST':
        addPatient($conn);
        break;
    case 'PUT':
        updatePatient($conn);
        break;
    case 'DELETE':
        deletePatient($conn);
        break;
    default:
    echo json_encode(array('message' => 'Method not allowed'));

        break;
}

// Function to retrieve all patients
function getPatients($conn) {
    $sql = "SELECT * FROM patient_records";
    $result = $conn->query($sql);
    $patients = array();

    
    while ($row = $result->fetch_assoc()) {
        $patients[] = $row;
    }
    echo json_encode($patients);
}

// Function to add a new patient
function addPatient($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    $name = $data['patient_name'];
    $age = $data['age'];
    $gender = $data['gender'];
    
    // Prepared statement to prevent SQL injection
    $stmt = $conn->prepare("INSERT INTO patient_records (patient_name, age, gender) VALUES (?, ?, ?)");
    $stmt->bind_param("sis", $name, $age, $gender);
    
    if ($stmt->execute()) {
        echo json_encode(array('message' => 'Patient added successfully'));

    } else {
        echo json_encode(array('message' => 'Error adding patient: ' . $stmt->error));
    }
    $stmt->close();
}

// Function to update a patient's details
function updatePatient($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    $id = $data['id'];
    $name = $data['patient_name'];
    $age = $data['age'];
    $gender = $data['gender'];
    
    // Prepared statement to prevent SQL injection
    $stmt = $conn->prepare("UPDATE patient_records SET patient_name=?, age=?, gender=? WHERE id=?");
    $stmt->bind_param("sisi", $name, $age, $gender, $id);
    
    if ($stmt->execute()) {
        echo json_encode(array('message' => 'Patient updated successfully'));
    } else {
        echo json_encode(array('message' => 'Error updating patient: ' . $stmt->error));
    }
    $stmt->close();
}

// Function to delete a patient
function deletePatient($conn) {
    $data = json_decode(file_get_contents("php://input"), true);
    $id = $data['id'];
    
    // Prepared statement to prevent SQL injection
    $stmt = $conn->prepare("DELETE FROM patient_records WHERE id=?");
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        echo json_encode(array('message' => 'Patient deleted successfully'));
    } else {
        echo json_encode(array('message' => 'Error deleting patient: ' . $stmt->error));
    }
    $stmt->close();
}

$conn->close();
?>
