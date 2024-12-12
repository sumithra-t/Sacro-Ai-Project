<?php
// Include the database connection file
require_once('dbh.php');

try {
    // Set the headers to force the browser to download the file
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="data_export.csv"');

    // Open the output stream
    $output = fopen('php://output', 'w');

    // Use a SQL query to fetch all rows from the 'patient_records' table
    $query = "SELECT * FROM patient_records";
    $stmt = $conn->prepare($query);
    $stmt->execute();

    // Fetch the field names (column headers)
    $fields = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($fields) {
        // Write the column headers to the CSV file
        fputcsv($output, array_keys($fields));

        // Write the first row of data
        fputcsv($output, $fields);

        // Fetch the remaining rows and write to the CSV file
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            fputcsv($output, $row);
        }
    } else {
        echo "No data found.";
    }

    // Close the output stream
    fclose($output);

} catch (PDOException $e) {
    // Handle any errors
    echo "Error: " . $e->getMessage();
}

// Close the database connection
$conn = null;
?>
