<?php
 
function getParam($paramName, $defaultValue) {
    return (isset($_GET[$paramName])) ?  $_GET[$paramName] : $defaultValue;
}

function printJSON($db, $sql) {
  // Performing SQL query
  $result = dbGet($db, $sql);

  header('Content-type: application/json');
  header('Access-Control-Allow-Origin: *');
  // echo dump($result);
  echo json_encode($result);
}

function main() {
  include "db.php";
  $db = dbInit();

  $sql = '';
  $proc = getParam('proc', 'get_detail');
  $quarter = getParam('quarter', '');
  $category = getParam('category', '');
  $param = '';
  if ($quarter != '') $param = "'$quarter'";
  if ($category != '') $param = $param . "," . "'$category'";

  $sql = "call $proc($param)";
  printJSON($db, $sql);
  // echo $sql;
}

main();

?>
  

