<?php
$servername = "localhost";
$username = "d03ddb7f";
$password = "JtviE4gfKeM3Ke46vdjx";
$database = "d03ddb7f";

$login_key = "U9PHjG7xfmN2dEWFtwXxxy4ewGtGBWh3UCDHN6dSFiUUMytJ";

// Allow from any origin
if (isset($_SERVER['HTTP_ORIGIN'])) {
	// Decide if the origin in $_SERVER['HTTP_ORIGIN'] is one
	// you want to allow, and if so:
	header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
	header('Access-Control-Allow-Credentials: true');
	header('Access-Control-Max-Age: 86400');    // cache for 1 day
}

// Access-Control headers are received during OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {

	if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
		// may also be using PUT, PATCH, HEAD etc
		header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

	if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
		header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");
	
	exit(0);
}

// Create connection
$mysql = new mysqli($servername, $username, $password, $database);
// Check connection
if ($mysql->connect_error) {
  die("Connection failed: " . $mysql->connect_error);
}
// echo "Database connected successfully\n";

// checks if the username of the basic auth exists and if the passwords hash matches the one in the database, sets $account_id and $is_public
$account_id = 0;
$is_public = 1;
$is_not_global = 1;
function ValidateAccess() {
	global $mysql, $account_id, $is_not_global;
	// ---------------------------------------------------------------------------------------------------------------
	// ---------------------------------------------------------------------------------------------------------------
	// ---------------------------------------------------------------------------------------------------------------
	// ---------------------------------------------------------------------------------------------------------------
	// ---------------------------------------------------------------------------------------------------------------
	// ---------------------------------------------------------------------------------------------------------------
	// ---------------------------------------------------------------------------------------------------------------
	// ACHTUGN: (funktioniert lokal nicht weil nur http möglich)
	if (!$_SERVER['HTTPS']) {
		return false;
	}
	$stmt = $mysql->prepare("SELECT * FROM `Accounts` WHERE `username`=?");
	$stmt->bind_param("s", $_SERVER['PHP_AUTH_USER']);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	
	$row = $result->fetch_array(MYSQLI_ASSOC);
	if ($row != null) {
		if ($row["password"] == hash("sha256", $_SERVER['PHP_AUTH_PW'])) {
			$account_id = $row["id"];
			$is_public = $row["is_public"];
			if ($_SERVER['PHP_AUTH_USER'] == "global") {
				$is_not_global = 0;
			}
			return true;
		}
	}
	return false;
}

// returns the id of an account with the specified username
function GetIdOfUser($username) : ?int {
	global $mysql;
	$stmt = $mysql->prepare("SELECT `id` FROM `Accounts` WHERE `username`=?");
	$stmt->bind_param("s", $username);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	$id = -1;
	unset($id);
	if (isset($row)) {
		$id = $row["id"];
	}
	return $id;
}
// Returns the next free g_id
function GetNextGId() : int {
	global $mysql;
	$stmt = $mysql->prepare('SHOW TABLE STATUS LIKE "Tricks"');
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row["Auto_increment"];
}
// returns the username of an account with the specified id
function GetUsername($user_id) : string {
	global $mysql;
	$stmt = $mysql->prepare("SELECT `username` FROM `Accounts` WHERE `id`=?");
	$stmt->bind_param("i", $user_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row["username"];
}
// Returns all tricknames and if the user landed them or not
/**
[{"name":"180 unispin","landed":1}]
**/
function GetTrickNamesForUser($username) : string {
	global $mysql;
	$user_id = GetIdOfUser($username);
	if (!isset($user_id)) {
		return "ERROR: Username not found";
	}
	$stmt = $mysql->prepare("SELECT t1.name, CASE WHEN t2.ref_id IS NOT NULL THEN 1 ELSE 0 END AS landed FROM Tricks t1 LEFT JOIN UserTricks t2 ON t1.g_id = t2.ref_id AND t2.owner_id = ? WHERE t1.invisible = 0;");
	$stmt->bind_param("i", $user_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	return json_encode($rows);
}
// Returns for all tricks: id,name,landed,date,liked,wishlisted
/**
[{id:1,name:"180 unispin",landed:1,date:"2024-02-10",liked:0,wishlisted:1},{...},...]
**/
function GetTrickListForUser($username) : string {
	global $mysql;
	$user_id = GetIdOfUser($username);
	if (!isset($user_id)) {
		return "ERROR: Username not found";
	}
	$stmt = $mysql->prepare('SELECT t1.g_id, t1.name, CASE WHEN t2.ref_id IS NOT NULL THEN t2.liked ELSE 0 END AS liked, CASE WHEN t2.ref_id IS NOT NULL THEN t2.wishlisted ELSE 0 END AS wishlisted, CASE WHEN t2.ref_id IS NOT NULL THEN t2.landed_on ELSE "0000-00-00" END AS landed_on, CASE WHEN t2.ref_id IS NOT NULL THEN t2.landed ELSE 0 END AS landed FROM Tricks t1 LEFT JOIN UserTricks t2 ON t1.g_id = t2.ref_id AND t2.owner_id = ? WHERE t1.invisible = 0;');
	$stmt->bind_param("i", $user_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	return json_encode($rows);
}
// Finds a global trick based on it's name
/**
{"g_id":1,"name":"180 unispin","description":"jump, spin the uni 180 degrees and land","videolinks":"{}","startPositions":";F;IFC;IBC,;F;IFC;,;F;;IBC,;F;;OFC,;F;OBC;,;F;OBC;OFC","endPositions":";F;IFC;IBC,;F;IFC;,;F;;IBC,;F;;OFC,;F;OBC;,;F;OBC;OFC","tags":"unispin,180","invisible":0,"proposed_by":11}
**/
function GetGlobalTrick($name) : string {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `Tricks` WHERE `name`=? AND `invisible`=0");
	$stmt->bind_param("s", $name);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return json_encode($row);
}

$hasaccess = ValidateAccess();

if ($_SERVER["REQUEST_METHOD"] == "GET") {
	if ($hasaccess) {
		echo "Access granted";
	}else{
		echo "Access denied";
	}
}else if ($hasaccess && $_SERVER["REQUEST_METHOD"] == "POST") {
	parse_str($_SERVER['QUERY_STRING'], $query);
	if (array_key_exists('fname',$query)) {
		$json = file_get_contents('php://input');
		$data = json_decode($json, true);
		echo $query['fname'](...$data);
	}
}

$conn->close();

/**
// Registers a new User
function RegisterUser($username, $hash) {
	global $mysql;
	$stmt = $mysql->prepare('INSERT INTO `Accounts` (`username`, `password`) VALUES (?, ?)');
	$stmt->bind_param("ss", $username, $hash);
	$stmt->execute();
	$stmt->close();
}
// Finds the playlist by the name and owner
function FindPlaylist($owner_id, $name) {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `UserPlaylists` WHERE `name`=? AND `owner_id`=?");
	$stmt->bind_param("si", $name, $owner_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row;
}
// Finds a global trick based on it's name
function FindGlobalTrick($name, $proposed_by) {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `Tricks` WHERE `name`=? AND `proposed_by`=?");
	$stmt->bind_param("si", $name, $proposed_by);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row;
}
// Finds a global combo based on it's name
function FindGlobalCombo($name, $proposed_by) {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `Combos` WHERE `name`=? AND `proposed_by`=?");
	$stmt->bind_param("si", $name, $proposed_by);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row;
}
// Finds a global trick with the specified id
function FindGlobalTrickById($g_id) {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `Tricks` WHERE `g_id`=?");
	$stmt->bind_param("i", $g_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row;
}
// Finds a global combo with the specified id
function FindGlobalComboById($c_id) {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `Combos` WHERE `c_id`=?");
	$stmt->bind_param("i", $c_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row;
}
// Finds a user trick based on it's name
function FindUserTrick($ref_id, $owner_id) {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `UserTricks` WHERE `ref_id`=? AND `owner_id`=?");
	$stmt->bind_param("ii", $ref_id, $owner_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row;
}
// Finds a user combo based on it's name
function FindUserCombo($ref_id, $owner_id) {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `UserCombos` WHERE `ref_id`=? AND `owner_id`=?");
	$stmt->bind_param("ii", $ref_id, $owner_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$row = $result->fetch_array(MYSQLI_ASSOC);
	return $row;
}
function InsertGlobalTrick($trick, $g_id) {
	global $mysql, $account_id, $is_not_global;
	$stmt = $mysql->prepare("INSERT INTO `Tricks` (`g_id`,`name`,`description`,`videolinks`,`startPositions`,`endPositions`,`tags`,`invisible`,`proposed_by`) VALUES (?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE `g_id`=`g_id`");
	$stmt->bind_param("issssssii",$g_id,$trick->name,base64_decode($trick->description),base64_decode($trick->videolinks),$trick->startPositions,$trick->endPositions,$trick->tags,$is_not_global,$account_id);
	$stmt->execute();
	$stmt->close();
}
function InsertUserTrick($trick, $g_id) {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("INSERT INTO `UserTricks` (`ref_id`,`owner_id`,`landed_on`,`meta_data`) VALUES (?,?,?,?)");
	$stmt->bind_param("iiss",$g_id,$account_id,$trick->landed_on,base64_decode($trick->meta_data));
	$stmt->execute();
	$stmt->close();
}
function ReplaceGlobalTrick($trick, $g_id) {
	global $mysql, $account_id, $is_not_global;
	$stmt = $mysql->prepare("REPLACE INTO `Tricks` (`g_id`,`name`,`description`,`videolinks`,`startPositions`,`endPositions`,`tags`,`invisible`,`proposed_by`) VALUES (?,?,?,?,?,?,?,?,?)");
	$stmt->bind_param("issssssii",$g_id,$trick->name,base64_decode($trick->description),base64_decode($trick->videolinks),$trick->startPositions,$trick->endPositions,$trick->tags,$is_not_global,$account_id);
	$stmt->execute();
	$stmt->close();
}
function ReplaceUserTrick($trick, $g_id) {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("REPLACE INTO `UserTricks` (`ref_id`,`owner_id`,`landed_on`,`meta_data`) VALUES (?,?,?,?)");
	$stmt->bind_param("iiss",$g_id,$account_id,$trick->landed_on,base64_decode($trick->meta_data));
	$stmt->execute();
	$stmt->close();
}
// Adds a trick to the global database and one to the user database
//$trick has fields: name, description, videolinks, startPositions, endPositions, tags, landed_on, meta_data
// format: {"name":"testcombo2","description":"oiameucasdkfjuic","videolinks":"oameicamfnaie","trick_ids":"1,2,3","tags":"testtags","landed_on":"2024-02-10","meta_data":"poiaemmcpoa"}
function ProposeTrick($trick, $replace) : ?int {
	global $mysql, $account_id, $is_not_global;
	$globaltrick = FindGlobalTrick($trick->name, $account_id);
	if (isset($trick->g_id)) {
		$tr = FindGlobalTrickById($trick->g_id);
		if ($tr["proposed_by"] == $account_id or $is_not_global == 0) {
			$globaltrick = $tr;
		}
	}
	if (isset($globaltrick)) {
		$g_id = $globaltrick["g_id"];
		if (!$replace) {
			echo ($trick->name)." exists already and cannot be added\n";
			return 1;
		}else{
			$usertrick = FindUserTrick($g_id, $account_id);
			if (isset($usertrick)) {
				// Replace user + global trick
				//echo "Replace user + global trick";
				ReplaceGlobalTrick($trick, $g_id);
				ReplaceUserTrick($trick, $g_id);
				return 0;
			}else{
				// Replace global trick
				// Insert user trick
				//echo "Replace global trick, Insert user trick";
				ReplaceGlobalTrick($trick, $g_id);
				InsertUserTrick($trick, $g_id);
				return 0;
			}
		}
	}else{
		if ($replace) {
			//echo ($trick->name)." does not exist and cannot be replaced\n";
			//return 1;
			// Insert user + global trick
			//echo "Insert user + global trick";
			$g_id = GetNextGId();
			InsertGlobalTrick($trick, $g_id);
			InsertUserTrick($trick, $g_id);
			return 0;
		}else{
			// Insert user + global trick
			//echo "Insert user + global trick";
			$g_id = GetNextGId();
			InsertGlobalTrick($trick, $g_id);
			InsertUserTrick($trick, $g_id);
			return 0;
		}
	}
}
// Deletes the trick with the given trickname, if it was proposed by the user
function DeleteProposedTrick($trickname) : ?int {
	global $mysql, $account_id;
	$globaltrick = FindGlobalTrick($trickname, $account_id);
	if (!isset($globaltrick)) {
		echo ($trickname)." does not exist globally and cannot be deleted\n";
		return 1;
	}
	$stmt = $mysql->prepare("DELETE FROM `Tricks` WHERE `g_id`=?");
	$stmt->bind_param("i", $globaltrick["g_id"]);
	$stmt->execute();
	$stmt->close();
	$usertrick = FindUserTrick($globaltrick["g_id"], $account_id);
	if (isset($usertrick)) {
		$stmt = $mysql->prepare("DELETE FROM `UserTricks` WHERE `ref_id`=? AND `owner_id`=?");
		$stmt->bind_param("ii", $globaltrick["g_id"], $account_id);
		$stmt->execute();
		$stmt->close();
	}
	return 0;
}

// Edits the user trick, trick should have fields: g_id, landed_on, meta_data
// format: {"g_id":116,"landed_on":"2000-02-10","meta_data":"iwmecapouemnnf"}
function EditUserTrick($trick, $replace) : ?int {
	global $account_id;
	if (!isset($trick->g_id)) {
		echo "no g_id was set\n";
		return 1;
	}
	$gtrick = FindGlobalTrickById($trick->g_id);
	if (!isset($gtrick)) {
		echo "did not find any trick with g_id=".strval($trick->g_id)."\n";
		return 1;
	}
	$utrick = FindUserTrick($trick->g_id,$account_id);
	if ($replace and isset($utrick)) {
		ReplaceUserTrick($trick,$trick->g_id);
	}else if ($replace or !isset($utrick)) {
		InsertUserTrick($trick,$trick->g_id);
	}else{
		echo "user trick with ref_id=".($trick->g_id)." exists already and cannot be added\n";
		return 1;
	}
	return 0;
}

function InsertGlobalCombo($combo, $c_id) {
	global $mysql, $account_id, $is_not_global;
	$stmt = $mysql->prepare("INSERT INTO `Combos` (`c_id`,`name`,`description`,`videolinks`,`tags`,`trick_ids`,`invisible`,`proposed_by`) VALUES (?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE `c_id`=`c_id`");
	$stmt->bind_param("isssssii",$c_id,$combo->name,base64_decode($combo->description),base64_decode($combo->videolinks),$combo->tags,$combo->trick_ids,$is_not_global,$account_id);
	$stmt->execute();
	$stmt->close();
}
function InsertUserCombo($combo, $c_id) {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("INSERT INTO `UserCombos` (`ref_id`,`owner_id`,`landed_on`,`meta_data`) VALUES (?,?,?,?)");
	$stmt->bind_param("iiss",$c_id,$account_id,$combo->landed_on,base64_decode($combo->meta_data));
	$stmt->execute();
	$stmt->close();
}
function ReplaceGlobalCombo($combo, $c_id) {
	global $mysql, $account_id, $is_not_global;
	$stmt = $mysql->prepare("REPLACE INTO `Combos` (`c_id`,`name`,`description`,`videolinks`,`tags`,`trick_ids`,`invisible`,`proposed_by`) VALUES (?,?,?,?,?,?,?,?)");
	$stmt->bind_param("isssssii",$c_id,$combo->name,base64_decode($combo->description),base64_decode($combo->videolinks),$combo->tags,$combo->trick_ids,$is_not_global,$account_id);
	$stmt->execute();
	$stmt->close();
}
function ReplaceUserCombo($combo, $c_id) {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("REPLACE INTO `UserCombos` (`ref_id`,`owner_id`,`landed_on`,`meta_data`) VALUES (?,?,?,?)");
	$stmt->bind_param("iiss",$c_id,$account_id,$combo->landed_on,base64_decode($combo->meta_data));
	$stmt->execute();
	$stmt->close();
}
// Adds a combo to the global database and one to the user database
//$combo has fields: name, description, videolinks, tags, trick_ids, landed_on, meta_data
// format: {"name":"testcombo2","description":"lkjadfpweal","videolinks":"oiuamxnuaiel","trick_ids":"1,2,3","tags":"testtags","landed_on":"2024-02-10","meta_data":"kjhdsafkj"}
function ProposeCombo($combo, $replace) : ?int {
	global $mysql, $account_id, $is_not_global;
	$globalcombo = FindGlobalCombo($combo->name, $account_id);
	if (isset($combo->c_id)) {
		$cm = FindGlobalComboById($combo->c_id);
		if ($cm["proposed_by"] == $account_id or $is_not_global == 0) {
			$globalcombo = $cm;
		}
	}
	if (isset($globalcombo)) {
		$c_id = $globalcombo["c_id"];
		if (!$replace) {
			echo ($combo->name)." exists already and cannot be added\n";
			return 1;
		}else{
			$usercombo = FindUserCombo($c_id, $account_id);
			if (isset($usercombo)) {
				// Replace user + global combo
				//echo "Replace user + global combo";
				ReplaceGlobalCombo($combo, $c_id);
				ReplaceUserCombo($combo, $c_id);
				return 0;
			}else{
				// Replace global combo
				// Insert user combo
				//echo "Replace global combo, Insert user combo";
				ReplaceGlobalCombo($combo, $c_id);
				InsertUserCombo($combo, $c_id);
				return 0;
			}
		}
	}else{
		if ($replace) {
			//echo ($combo->name)." does not exist and cannot be replaced\n";
			//return 1;
			// Insert user + global combo
			//echo "Insert user + global combo";
			$c_id = GetNextCId();
			InsertGlobalCombo($combo, $c_id);
			InsertUserCombo($combo, $c_id);
			return 0;
		}else{
			// Insert user + global combo
			//echo "Insert user + global combo";
			$c_id = GetNextCId();
			InsertGlobalCombo($combo, $c_id);
			InsertUserCombo($combo, $c_id);
			return 0;
		}
	}
}
// Deletes the combo with the given comboname, if it was proposed by the user
function DeleteProposedCombo($comboname) : ?int {
	global $mysql, $account_id;
	$globalcombo = FindGlobalCombo($comboname, $account_id);
	if (!isset($globalcombo)) {
		echo ($comboname)." does not exist globally and cannot be deleted\n";
		return 1;
	}
	$stmt = $mysql->prepare("DELETE FROM `Combos` WHERE `c_id`=?");
	$stmt->bind_param("i", $globalcombo["c_id"]);
	$stmt->execute();
	$stmt->close();
	$usercombo = FindUserCombo($globalcombo["c_id"], $account_id);
	if (isset($usercombo)) {
		$stmt = $mysql->prepare("DELETE FROM `UserCombos` WHERE `ref_id`=? AND `owner_id`=?");
		$stmt->bind_param("ii", $globalcombo["c_id"], $account_id);
		$stmt->execute();
		$stmt->close();
	}
	return 0;
}
// Edits the user combo, combo should have fields: c_id, landed_on, meta_data
// format: {"c_id":8,"landed_on":"2001-02-10","meta_data":"kjhasdKHGFDfdjsak"}
function EditUserCombo($combo, $replace) : ?int {
	global $account_id;
	if (!isset($combo->c_id)) {
		echo "no c_id was set\n";
		return 1;
	}
	$gcombo = FindGlobalComboById($combo->c_id);
	if (!isset($gcombo)) {
		echo "did not find any combo with c_id=".strval($combo->c_id)."\n";
		return 1;
	}
	$ucombo = FindUserCombo($combo->c_id,$account_id);
	if ($replace and isset($ucombo)) {
		ReplaceUserCombo($combo,$combo->c_id);
	}else if ($replace or !isset($ucombo)) {
		InsertUserCombo($combo,$combo->c_id);
	}else{
		echo "user combo with ref_id=".($combo->c_id)." exists already and cannot be added\n";
		return 1;
	}
	return 0;
}

// Adds or Edits the given playlist
// format: {"name":"testplaylist","ids":"t1,c1,t2"}
function EditPlaylist($playlist, $replace) : ?int {
	global $mysql, $account_id;
	$pl = FindPlaylist($account_id,$playlist->name);
	if (isset($pl) and !$replace) {
		echo ($playlist->name)." exists already and cannot be added\n";
		return 1;
	}else if (!isset($pl) and $replace) {
		//echo ($playlist->name)." does not exist and cannot be replaced";
		//return 1;
		$replace = false;
	}
	$querystr = "INSERT INTO `UserPlaylists` (`p_id`,`owner_id`,`name`,`ids`) VALUES (?,?,?,?)";
	$p_id = NULL;
	if ($replace) {
		$querystr = "REPLACE INTO `UserPlaylists` (`p_id`,`owner_id`,`name`,`ids`) VALUES (?,?,?,?)";
		$p_id = $pl["p_id"];
	}
	$stmt = $mysql->prepare($querystr);
	$success = $stmt->bind_param("iiss",$p_id,$account_id,$playlist->name,$playlist->ids);
	$stmt->execute();
	$stmt->close();
	if ($success) {
		return 0;
	}
	return 1;
}
// Deletes the playlist with the given name
function DeletePlaylist($plname) : ?int {
	global $mysql, $account_id;
	$playlist = FindPlaylist($account_id, $plname);
	if (!isset($playlist)) {
		echo ($plname)." does not exist and cannot be deleted\n";
		return 1;
	}
	$stmt = $mysql->prepare("DELETE FROM `UserPlaylists` WHERE `name`=? AND `owner_id`=?");
	$stmt->bind_param("si", $plname, $account_id);
	$stmt->execute();
	$stmt->close();
	return 0;
}
// Adds a trick to the database
// format for $dat depends on u and t/c/p, see corresponding functions
function NewTrickOrCombo($fname, $dat) : ?int {
	$replace = str_contains($fname, "r");
	$user_only = str_contains($fname, "u");
	if (str_contains($fname,"t")) {
		if ($user_only) {
			return EditUserTrick($dat, $replace);
		}else{
			return ProposeTrick($dat, $replace);
		}
	}else if (str_contains($fname, "c")) {
		if ($user_only) {
			return EditUserCombo($dat, $replace);
		}else{
			return ProposeCombo($dat, $replace);
		}
	}else if (str_contains($fname, "p")) {
		return EditPlaylist($dat, $replace);
	}
	return 1;
}

// Returns the global Tricks and by the user proposed tricks
// A trick has the fields: name, description, videolinks, startPositions, endPositions, tags, landed_on, meta_data
function GetTricksForUser() {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("SELECT * FROM `UserTricks` WHERE `owner_id`=?");
	$stmt->bind_param("i", $account_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);

	$json = "{";
	$g_ids = array();
	foreach ($rows as $row => $usertrick) {
		$globaltrick = FindGlobalTrickById($usertrick["ref_id"]);
		if (isset($globaltrick)) { //should always be set
			$jsontrick = new stdClass();
			$jsontrick->name = $globaltrick["name"];
			$jsontrick->description = base64_encode($globaltrick["description"]);
			$jsontrick->videolinks = base64_encode($globaltrick["videolinks"]);
			$jsontrick->startPositions = $globaltrick["startPositions"];
			$jsontrick->endPositions = $globaltrick["endPositions"];
			$jsontrick->tags = $globaltrick["tags"];
			$jsontrick->landed_on = $usertrick["landed_on"];
			$jsontrick->meta_data = base64_encode($usertrick["meta_data"]);
			$json .= '"' . strval($usertrick["ref_id"]) . '"' . ":" . json_encode($jsontrick) . ",";
			array_push($g_ids, $usertrick["ref_id"]);
		}
	}
	
	$stmt = $mysql->prepare("SELECT * FROM `Tricks` WHERE `invisible`=0");
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	
	foreach ($rows as $row => $globaltrick) {
		if (!in_array($globaltrick["g_id"], $g_ids)) {
			$jsontrick = new stdClass();
			$jsontrick->name = $globaltrick["name"];
			$jsontrick->description = base64_encode($globaltrick["description"]);
			$jsontrick->videolinks = base64_encode($globaltrick["videolinks"]);
			$jsontrick->startPositions = $globaltrick["startPositions"];
			$jsontrick->endPositions = $globaltrick["endPositions"];
			$jsontrick->tags = $globaltrick["tags"];
			$usertrick = FindUserTrick($globaltrick["g_id"], $account_id);
			if (isset($usertrick)) {
				$jsontrick->landed_on = $usertrick["landed_on"];
				$jsontrick->meta_data = base64_encode($usertrick["meta_data"]);
			}
			$json .= '"' . strval($globaltrick["g_id"]) . '"' . ":" . json_encode($jsontrick) . ",";
		}
	}
	$json = trim($json, ",");
	$json .= "}";
	return $json;
}
// Returns the global Combos and by the user proposed combos
// A combo has the fields: name, description, videolinks, tags, trick_ids, landed_on, meta_data
function GetCombosForUser() {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("SELECT * FROM `UserCombos` WHERE `owner_id`=?");
	$stmt->bind_param("i", $account_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);

	$json = "{";
	$c_ids = array();
	foreach ($rows as $row => $usercombo) {
		$globalcombo = FindGlobalComboById($usercombo["ref_id"]);
		if (isset($globalcombo)) { //should always be set
			$jsoncombo = new stdClass();
			$jsoncombo->name = $globalcombo["name"];
			$jsoncombo->description = base64_encode($globalcombo["description"]);
			$jsoncombo->videolinks = base64_encode($globalcombo["videolinks"]);
			$jsoncombo->trick_ids = $globalcombo["trick_ids"];
			$jsoncombo->tags = $globalcombo["tags"];
			$jsoncombo->landed_on = $usercombo["landed_on"];
			$jsoncombo->meta_data = base64_encode($usercombo["meta_data"]);
			$json .= '"' . strval($usercombo["ref_id"]) . '"' . ":" . json_encode($jsoncombo) . ",";
			array_push($c_ids, $usercombo["ref_id"]);
		}
	}
	
	$stmt = $mysql->prepare("SELECT * FROM `Combos` WHERE `invisible`=0");
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	
	foreach ($rows as $row => $globalcombo) {
		if (!in_array($globalcombo["c_id"], $c_ids)) {
			$jsoncombo = new stdClass();
			$jsoncombo->name = $globalcombo["name"];
			$jsoncombo->description = base64_encode($globalcombo["description"]);
			$jsoncombo->videolinks = base64_encode($globalcombo["videolinks"]);
			$jsoncombo->trick_ids = $globalcombo["trick_ids"];
			$jsoncombo->tags = $globalcombo["tags"];
			$usercombo = FindUserCombo($globalcombo["c_id"], $account_id);
			if (isset($usercombo)) {
				$jsoncombo->landed_on = $usercombo["landed_on"];
				$jsoncombo->meta_data = base64_encode($usercombo["meta_data"]);
			}
			$json .= '"' . strval($globalcombo["c_id"]) . '"' . ":" . json_encode($jsoncombo) . ",";
		}
	}
	$json = trim($json, ",");
	$json .= "}";
	return $json;
}
// returns the playlists of the user
// format: {"23":{"name":"testplaylist","ids":"t1,c1,t2"}}
function GetPlaylists($user_id) {
	global $mysql;
	$stmt = $mysql->prepare("SELECT * FROM `UserPlaylists` WHERE `owner_id`=?");
	$stmt->bind_param("i", $user_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	
	$json = '{';
	foreach ($rows as $row => $playlist) {
		$jsonpl = new stdClass();
		$jsonpl->name = $playlist["name"];
		$jsonpl->ids = $playlist["ids"];
		$json .= '"' . strval($playlist["p_id"]) . '":' . json_encode($jsonpl) . ",";
	}
	$json = trim($json, ",");
	$json .= "}";
	return $json;
}
// returns a list of all public users
function GetUsers() {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("SELECT * FROM `Accounts` WHERE `is_public`=1");
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	
	$list = "{";
	foreach ($rows as $row => $user) {
		$list .= '"'.$user["username"].'":"'.$user["joined"].'",';
	}
	$list = trim($list, ",");
	return $list."}";
}
// returns the userprofile for the specified user
// returns string: {"name":"testusername","joined":"2024-02-21","tricks":{},"combos":{},"playlists":{}}
function GetUserProfile($user) {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("SELECT * FROM `Accounts` WHERE `is_public`=1 AND `username`=?");
	$stmt->bind_param("s", $user);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	if (!isset($rows) or !isset($rows[0])) {
		echo "user ".$user." not found";
		return "<-error";
	}
	$userdata = $rows[0];
	$json = '{"name":"'.$user.'","joined":"'.$userdata["joined"].'","tricks":{';
	
	$stmt = $mysql->prepare("SELECT * FROM `UserTricks` WHERE `owner_id`=?");
	$stmt->bind_param("i", $userdata["id"]);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	
	foreach ($rows as $row => $usertrick) {
		$globaltrick = FindGlobalTrickById($usertrick["ref_id"]);
		if (isset($globaltrick)) { //should always be set
			$jsontrick = new stdClass();
			$jsontrick->name = $globaltrick["name"];
			$jsontrick->description = base64_encode($globaltrick["description"]);
			$jsontrick->videolinks = base64_encode($globaltrick["videolinks"]);
			$jsontrick->startPositions = $globaltrick["startPositions"];
			$jsontrick->endPositions = $globaltrick["endPositions"];
			$jsontrick->tags = $globaltrick["tags"];
			$jsontrick->landed_on = $usertrick["landed_on"];
			$jsontrick->meta_data = base64_encode($usertrick["meta_data"]);
			$json .= '"' . strval($usertrick["ref_id"]) . '"' . ":" . json_encode($jsontrick) . ",";
		}
	}
	$json = trim($json, ",");
	
	$stmt = $mysql->prepare("SELECT * FROM `UserCombos` WHERE `owner_id`=?");
	$stmt->bind_param("i", $userdata["id"]);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	
	$json .= '},"combos":{';
	foreach ($rows as $row => $usercombo) {
		$globalcombo = FindGlobalComboById($usercombo["ref_id"]);
		if (isset($globalcombo)) { //should always be set
			$jsoncombo = new stdClass();
			$jsoncombo->name = $globalcombo["name"];
			$jsoncombo->description = base64_encode($globalcombo["description"]);
			$jsoncombo->videolinks = base64_encode($globalcombo["videolinks"]);
			$jsoncombo->trick_ids = $globalcombo["trick_ids"];
			$jsoncombo->tags = $globalcombo["tags"];
			$jsoncombo->landed_on = $usercombo["landed_on"];
			$jsoncombo->meta_data = base64_encode($usercombo["meta_data"]);
			$json .= '"' . strval($usercombo["ref_id"]) . '"' . ":" . json_encode($jsoncombo) . ",";
		}
	}
	$json = trim($json, ",");
	$json .= '},"playlists":'.GetPlaylists($userdata["id"]).'}';
	return $json;
}

function GetUserSettings() {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("SELECT * FROM `Accounts` WHERE `id`=?");
	$stmt->bind_param("i", $account_id);
	$stmt->execute();
	$result = $stmt->get_result();
	$stmt->close();
	$rows = $result->fetch_all(MYSQLI_ASSOC);
	if (!isset($rows) or !isset($rows[0])) {
		echo "user ".$user." not found";
		return "<-error";
	}
	$userdata = $rows[0];
	$json = '{"name":"'.$userdata["username"].'","joined":"'.$userdata["joined"].'","id":'.strval($userdata["id"]).',"is_public":'.strval($userdata["is_public"]).',"is_goofy":'.strval($userdata["is_goofy"]).'}';
	return $json;
}
function SetUserSettings($settings) {
	global $mysql, $account_id;
	$stmt = $mysql->prepare("UPDATE `Accounts` SET `is_public`=?,`is_goofy`=? WHERE `id`=?");#UPDATE `Accounts` SET `is_public`=1,`is_goofy`=1 WHERE `id`=12
	$stmt->bind_param("iii", $settings->is_public, $settings->is_goofy, $account_id);
	$stmt->execute();
	$stmt->close();
	return "<-success";
}

$hasaccess = ValidateAccess();
$request_processed = false;

if ($_SERVER["REQUEST_METHOD"] == "PUT" and file_get_contents('php://input') == $login_key) {
	if ($hasaccess) {
		echo "username already exists<-error";
	}else{
		$userid = GetIdOfUser($_SERVER['PHP_AUTH_USER']);
		if (!isset($userid)) {
			RegisterUser($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW']);
			echo "<-success";
		}else{
			echo "username already exists<-error";
		}
	}
	$request_processed = true;
}

if ($hasaccess) {
	if ($_SERVER["REQUEST_METHOD"] == "POST") {
		$json = file_get_contents('php://input');
		$data = json_decode($json);
		$datas = get_object_vars($data);
		if (count($datas) > 0) {
			$err = 0;
			foreach ($datas as $fname => $dat) {
				if (NewTrickOrCombo($fname, $dat) == 1) {
					$err = 1;
				}
			}
			if ($err == 0) {
				echo "<-success";
			}else{
				echo "<-error";
			}
		}else {
			echo "no change<-error";
		}
		$request_processed = true;
	}else if ($_SERVER["REQUEST_METHOD"] == "DELETE") {
		$json = file_get_contents('php://input');
		$data = json_decode($json);
		$datas = get_object_vars($data);
		if (count($datas) > 0) {
			$err = 0;
			foreach ($datas as $fname => $tcname) {
				if (str_contains($fname,"t")) {
					if (DeleteProposedTrick($tcname) == 1) {
						$err = 1;
					}
				}else if (str_contains($fname, "c")) {
					if (DeleteProposedCombo($tcname) == 1) {
						$err = 1;
					}
				}else if (str_contains($fname, "p")) {
					if (DeletePlaylist($tcname) == 1) {
						$err = 1;
					}
				}else{
					echo "incorrect format";
					$err = 1;
				}
			}
			if ($err == 0) {
				echo "<-success";
			}else{
				echo "<-error";
			}
		}else {
			echo "no change<-error";
		}
		$request_processed = true;
	}else if ($_SERVER["REQUEST_METHOD"] == "GET") {
		$json = file_get_contents('php://input');
		$data = json_decode($json);
		if (isset($data->what)) {
			//echo ($data->what)." is what";
			if ($data->what == "tricks") {
				echo GetTricksForUser();
			}else if ($data->what == "combos") {
				echo GetCombosForUser();
			}else if ($data->what == "playlists") {
				echo GetPlaylists($account_id);
			}else if ($data->what == "users") {
				echo GetUsers();
			}else if ($data->what == "userprofile") {
				echo GetUserProfile($data->user);
			}else if ($data->what == "settings") {
				echo GetUserSettings();
			}else if ($data->what == "alltricks") {
				echo GetTrickNamesForUser();
			}else{
				echo "incorrect format<-error";
			}
		}else{
			echo "incorrect format<-error";
		}
		$request_processed = true;
	}else if ($_SERVER["REQUEST_METHOD"] == "OPTIONS") {
		$json = file_get_contents('php://input');
		$data = json_decode($json);
		if (isset($data->what)) {
			//echo ($data->what)." is what";
			if ($data->what == "settings") {
				echo SetUserSettings($data->settings);
			}else{
				echo "incorrect format<-error";
			}
		}else{
			echo "incorrect format<-error";
		}
		$request_processed = true;
	}
	if (!$request_processed) {
		echo "Access granted";
	}
}else{
	if (!$request_processed) {
		echo "Access denied";
	}
}
$conn->close();
**/

//function GetTricksNumberOfOwner($owner, $only_landed) {
//	global $mysql;
//	$req_str = "SELECT COUNT(*) as `tricks` FROM `Tricks` WHERE `owner`=?";
//	if ($only_landed) {
//		$req_str = "SELECT COUNT(*) as `tricks` FROM `Tricks` WHERE `owner`=? AND `landed` IS NOT NULL";
//	}
//	$stmt = $mysql->prepare($req_str);
//	$stmt->bind_param("s", $owner);
//	$stmt->execute();
//	$result = $stmt->get_result();
//	$stmt->close();
//	$rows = $result->fetch_all(MYSQLI_ASSOC);
//	return $rows[0]["tricks"];
//}
//function GetUsersAndTricksNumAsJSON() {
//	global $mysql;
//	$stmt = $mysql->prepare("SELECT `id`, `username` FROM `Accounts`");
//	$stmt->execute();
//	$result = $stmt->get_result();
//	$stmt->close();
//	$rows = $result->fetch_all(MYSQLI_ASSOC);
//	$json = "{";
//	foreach ($rows as $row => $userarr) {
//		if ($userarr["id"] != 1) {
//			$jsonuser = new stdClass();
//			$jsonuser->l = GetTricksNumberOfOwner($userarr["id"], true);
//			$jsonuser->a = GetTricksNumberOfOwner($userarr["id"], false);
//			$jsonuser->n = $userarr["username"];
//			$json .= '"' . $userarr["id"] . '"' . ":" . json_encode($jsonuser) . ",";
//		}
//	}
//	$json = trim($json, ",");
//	$json .= "}";
//	return $json;
//}

?>
