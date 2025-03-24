-- phpMyAdmin SQL Dump
-- version 4.9.11
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 12, 2025 at 11:38 AM
-- Server version: 10.11.8-MariaDB-0ubuntu0.24.04.1-log
-- PHP Version: 7.4.33-nmm7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `d03ddb7f`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`d03ddb7f`@`localhost` PROCEDURE `inserttricks` (IN `n` INT)   BEGIN
   DECLARE counter INT;
   SET counter = 1;

   label1: WHILE counter < n+1 DO
   	 INSERT INTO Tricks (ref_id, name, owner, description, score, startPositions, endPositions, categories, landed, use_in_combos) VALUES (55,  CONCAT("Testtrick",CAST(counter AS VARCHAR(10))), 3, "alkjkdshfakdfhgklajdjflgkajdhzfgkjahzdfkgjahdf", 5.5, "akjlsdflaksdjflfdgkljsdhklaödkflakdjsfölaksdf", "laksjdfoiuerzmncurecnsaldkcnaodkacodsoaejwkcaiefd", "other", false, false);
     SELECT counter;
     SET counter = counter + 1;
   END WHILE label1;
END$$

CREATE DEFINER=`d03ddb7f`@`localhost` PROCEDURE `newUserDataTricks` (IN `start` INT, IN `end` INT)   BEGIN
   DECLARE counter INT;
   SET counter = start;

   label1: WHILE counter < end+1 DO
   	 INSERT INTO UserTricks (ref_id, owner_id) VALUES (counter, 11);
     SELECT counter;
     SET counter = counter + 1;
   END WHILE label1;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Accounts`
--

CREATE TABLE `Accounts` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `password` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 1,
  `is_goofy` tinyint(1) NOT NULL DEFAULT 0,
  `joined` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Accounts`
--

INSERT INTO `Accounts` (`id`, `username`, `password`, `is_public`, `is_goofy`, `joined`) VALUES
(11, 'global', '98b9ba7d03776d97d56690fd51ffd647ab07b6b1c51f6df64b79c6b8f127cbc0', 1, 0, '2024-03-26'),
(12, 'marvin', 'd8fa87b7b3611f60f02e14b4c6ed9233e9a1eac2f9367d324c529ed47cf6fc5e', 1, 0, '2024-03-27'),
(13, 'janniediek', '7d9d3a4ee7f31627aacc9e16fd1ad02c4d2787e51a981fc4bc893b1f0f554b3f', 1, 0, '2024-03-31');

-- --------------------------------------------------------

--
-- Table structure for table `Combos`
--

CREATE TABLE `Combos` (
  `c_id` int(10) UNSIGNED NOT NULL,
  `name` text CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `description` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `videolinks` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `tags` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `trick_ids` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `invisible` tinyint(1) NOT NULL DEFAULT 0,
  `proposed_by` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Combos`
--

INSERT INTO `Combos` (`c_id`, `name`, `description`, `videolinks`, `tags`, `trick_ids`, `invisible`, `proposed_by`) VALUES
(1, '180 to riddim', '180 unispin to riddim roll', '{}', '180,roll,riddim', '1,2', 0, 11);

-- --------------------------------------------------------

--
-- Table structure for table `Tricks`
--

CREATE TABLE `Tricks` (
  `g_id` int(10) UNSIGNED NOT NULL,
  `name` text CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `description` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `videolinks` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `startPositions` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `endPositions` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `tags` text CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `invisible` tinyint(1) NOT NULL DEFAULT 0,
  `proposed_by` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Tricks`
--

INSERT INTO `Tricks` (`g_id`, `name`, `description`, `videolinks`, `startPositions`, `endPositions`, `tags`, `invisible`, `proposed_by`) VALUES
(1, '180 unispin', 'jump, spin the uni 180 degrees and land', '{}', ';F;IFC;IBC,;F;IFC;,;F;;IBC,;F;;OFC,;F;OBC;,;F;OBC;OFC', ';F;IFC;IBC,;F;IFC;,;F;;IBC,;F;;OFC,;F;OBC;,;F;OBC;OFC', 'unispin,180', 0, 11),
(2, 'riddim roll', '', '{}', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', ';F;IFC;IBC,;F;;IBC,;M;IFC;IBC,;M;;IBC', 'roll,riddim', 0, 11),
(3, 'switch riddim', 'switch riddim roll', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'S;F;IFC;IBC,S;F;IFC;,S;M;IFC;IBC,S;M;IFC;', 'roll,riddim,switch', 0, 11),
(4, 'invert riddim', 'invert riddim roll', '{}', ';B;IFC;IBC,;B;IFC;,;M;IFC;IBC,;M;IFC;', ';B;IFC;IBC,;B;;IBC,;M;IFC;IBC,;M;;IBC', 'roll,riddim,invert', 0, 11),
(5, 'switch invert riddim', 'switch invert riddim roll', '{}', 'S;B;IFC;IBC,S;B;;IBC,S;M;IFC;IBC,S;M;;IBC', 'S;B;IFC;IBC,S;B;IFC;,S;M;IFC;IBC,S;M;IFC;', 'roll,riddim,invert,switch', 0, 11),
(6, 'reverse riddim', 'reverse riddim roll', '{}', ';F;IFC;IBC,;F;;IBC,;M;IFC;IBC,;M;;IBC', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', 'roll,riddim,reverse', 0, 11),
(7, 'switch reverse riddim', 'switch reverse riddim roll', '{}', 'S;F;IFC;IBC,S;F;IFC;,S;M;IFC;IBC,S;M;IFC;', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'roll,riddim,reverse,switch', 0, 11),
(8, 'reverse invert riddim', 'reverse invert riddim roll', '{}', ';B;IFC;IBC,;B;;IBC,;M;IFC;IBC,;M;;IBC', ';B;IFC;IBC,;B;IFC;,;M;IFC;IBC,;M;IFC;', 'roll,riddim,reverse,invert', 0, 11),
(9, 'switch reverse invert riddim', 'switch reverse invert riddim roll', '{}', 'S;B;IFC;IBC,S;B;IFC;,S;M;IFC;IBC,S;M;IFC;', 'S;B;IFC;IBC,S;B;;IBC,S;M;IFC;IBC,S;M;;IBC', 'roll,riddim,reverse,invert,switch', 0, 11),
(10, 'halfroll', '', '{}', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', 'S;F;IFC;IBC,S;M;IFC;IBC,S;F;IFC;,S;M;IFC;', 'roll,half', 0, 11),
(11, 'switch halfroll', '', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', ';F;IFC;IBC,;M;IFC;IBC,;F;;IBC,;M;;IBC', 'roll,half,switch', 0, 11),
(12, '360 unispin', 'jump, spin the uni 360 degrees and land', '{}', ';F;IFC;IBC,;F;IFC;,;F;;IBC,;F;;OFC,;F;OBC;,;F;OBC;OFC', ';F;IFC;IBC,;F;IFC;,;F;;IBC,;F;;OFC,;F;OBC;,;F;OBC;OFC', 'unispin,360', 0, 11),
(13, 'crankflip', '', '{}', ';F;IFC;IBC', ';F;IFC;IBC', 'flip', 0, 11),
(14, 'switch 180', 'switch 180 unispin: jump, spin the uni 180 degrees and land', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;F;IFC;,S;F;OBC;,S;F;;OFC,S;F;OBC;OFC', 'S;F;IFC;IBC,S;F;;IBC,S;F;IFC;,S;F;OBC;,S;F;;OFC,S;F;OBC;OFC', 'unispin,180,switch', 0, 11),
(15, 'switch 360', 'switch 360 unispin: jump, spin the uni 360 degrees and land', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;F;IFC;,S;F;OBC;,S;F;;OFC,S;F;OBC;OFC', 'S;F;IFC;IBC,S;F;;IBC,S;F;IFC;,S;F;OBC;,S;F;;OFC,S;F;OBC;OFC', 'unispin,360,switch', 0, 11),
(16, 'switch flip', 'switch crankflip', '{}', 'S;F;IFC;IBC', 'S;F;IFC;IBC', 'flip,switch', 0, 11),
(17, 'rollingwrap', '', '{}', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', ';F;IFC;IBC,;F;;IBC,;M;IFC;IBC,;M;;IBC', 'roll,wrap', 0, 11),
(18, 'reverse rw', 'reverse rollingwrap', '{}', ';F;IFC;IBC,;F;;IBC,;M;IFC;IBC,;M;;IBC', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', 'roll,wrap,reverse', 0, 11),
(19, 'switch rw', 'switch rollingwrap', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'S;F;IFC;IBC,S;F;IFC;,S;M;IFC;IBC,S;M;IFC;', 'roll,wrap,switch', 0, 11),
(20, 'switch reverse rw', 'switch, reverse rollingwrap', '{}', 'S;F;IFC;IBC,S;F;IFC;,S;M;IFC;IBC,S;M;IFC;', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'roll,wrap,reverse,switch', 0, 11),
(21, 'varialroll', '', '{}', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', ';B;;OBC', 'roll,varial', 0, 11),
(22, 'full varialroll', '', '{}', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', 'roll,varial', 0, 11),
(23, 'switch vr', 'switch varialroll', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'S;B;OFC;', 'roll,varial,switch', 0, 11),
(24, 'switch full vr', 'switch full varialroll', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'roll,varial,switch', 0, 11),
(25, 'reverse vr', 'reverse varialroll', '{}', ';B;;OBC', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', 'roll,varial,reverse', 0, 11),
(26, 'reverse full vr', 'reverse full varialroll', '{}', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', 'roll,varial,reverse', 0, 11),
(27, 'switch reverse vr', 'switch reverse varialroll', '{}', 'S;B;OFC;', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'roll,varial,reverse,switch', 0, 11),
(28, 'switch reverse full vr', 'switch reverse full varialroll', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'roll,varial,reverse,switch', 0, 11),
(29, '540 unispin', 'jump, spin the uni 540 degrees and land', '{}', ';F;IFC;IBC,;F;IFC;,;F;;IBC,;F;;OFC,;F;OBC;,;F;OBC;OFC', ';F;IFC;IBC,;F;IFC;,;F;;IBC,;F;;OFC,;F;OBC;,;F;OBC;OFC', 'unispin,540', 1, 12),
(30, 'forward roll', '', '{}', ';F;IFC;IBC,;F;IFC;,;M;IFC;IBC,;M;IFC;', ';F;IFC;IBC,;M;IFC;IBC,;F;IFC;,;M;IFC;', 'roll,forward', 1, 12),
(31, 'switch forward roll', '', '{}', 'S;F;IFC;IBC,S;F;;IBC,S;M;IFC;IBC,S;M;;IBC', 'S;F;IFC;IBC,S;M;IFC;IBC,S;F;;IBC,S;M;;IBC', 'roll,forward,switch', 1, 12);

-- --------------------------------------------------------

--
-- Table structure for table `UserCombos`
--

CREATE TABLE `UserCombos` (
  `ref_id` int(10) UNSIGNED NOT NULL,
  `owner_id` int(10) UNSIGNED NOT NULL,
  `landed_on` date NOT NULL,
  `meta_data` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `UserCombos`
--

INSERT INTO `UserCombos` (`ref_id`, `owner_id`, `landed_on`, `meta_data`) VALUES
(1, 11, '2024-03-27', ''),
(1, 12, '2024-03-28', '');

-- --------------------------------------------------------

--
-- Table structure for table `UserPlaylists`
--

CREATE TABLE `UserPlaylists` (
  `p_id` int(10) UNSIGNED NOT NULL,
  `owner_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `ids` text CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `UserPlaylists`
--

INSERT INTO `UserPlaylists` (`p_id`, `owner_id`, `name`, `ids`) VALUES
(32, 12, 'jonathan', 't1,t12,t13,t22,t10,t8,t6,t25,t2,t17,t11,t3,t21'),
(33, 13, 'randos', 't1,t13,t22'),
(31, 12, 'testpl', 'c1,t1'),
(30, 11, 'testplaylist1', 't2,t3,t4,t6,t5,t8,t7,t9,t10,t11,t1');

-- --------------------------------------------------------

--
-- Table structure for table `UserTricks`
--

CREATE TABLE `UserTricks` (
  `ref_id` int(10) UNSIGNED NOT NULL,
  `owner_id` int(10) UNSIGNED NOT NULL,
  `landed_on` date NOT NULL,
  `meta_data` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `UserTricks`
--

INSERT INTO `UserTricks` (`ref_id`, `owner_id`, `landed_on`, `meta_data`) VALUES
(1, 11, '2024-03-27', ''),
(1, 12, '2024-03-27', ''),
(1, 13, '2016-01-01', ''),
(2, 11, '2024-03-27', ''),
(2, 12, '2024-03-27', ''),
(3, 11, '2024-03-27', ''),
(3, 12, '2024-03-27', ''),
(4, 11, '2024-03-27', ''),
(4, 12, '2024-03-27', ''),
(5, 11, '2024-03-27', ''),
(5, 12, '2024-03-27', ''),
(6, 11, '2024-03-27', ''),
(6, 12, '2024-03-27', ''),
(7, 11, '2024-03-27', ''),
(7, 12, '2024-03-27', ''),
(8, 11, '2024-03-27', ''),
(8, 12, '2024-03-27', ''),
(9, 11, '2024-03-27', ''),
(9, 12, '2024-03-27', ''),
(10, 11, '2024-03-27', ''),
(10, 12, '2024-03-27', ''),
(11, 11, '2024-03-27', ''),
(11, 12, '2024-03-27', ''),
(12, 11, '2024-03-31', ''),
(12, 12, '2024-03-31', ''),
(13, 11, '2024-03-31', ''),
(13, 12, '0000-00-00', ''),
(14, 11, '2024-03-31', ''),
(14, 12, '0000-00-00', ''),
(15, 11, '2024-03-31', ''),
(15, 12, '0000-00-00', ''),
(16, 11, '2024-03-31', ''),
(16, 12, '0000-00-00', ''),
(17, 11, '2024-03-31', ''),
(17, 12, '0000-00-00', ''),
(18, 11, '2024-03-31', ''),
(18, 12, '0000-00-00', ''),
(19, 11, '2024-03-31', ''),
(19, 12, '0000-00-00', ''),
(20, 11, '2024-03-31', ''),
(20, 12, '0000-00-00', ''),
(21, 11, '2024-03-31', ''),
(21, 12, '0000-00-00', ''),
(22, 11, '2024-03-31', ''),
(22, 12, '0000-00-00', ''),
(23, 11, '2024-03-31', ''),
(23, 12, '0000-00-00', ''),
(24, 11, '2024-03-31', ''),
(24, 12, '0000-00-00', ''),
(25, 11, '2024-03-31', ''),
(25, 12, '0000-00-00', ''),
(26, 11, '2024-03-31', ''),
(26, 12, '0000-00-00', ''),
(27, 11, '2024-03-31', ''),
(27, 12, '0000-00-00', ''),
(28, 11, '2024-03-31', ''),
(28, 12, '0000-00-00', ''),
(29, 12, '0000-00-00', ''),
(30, 12, '0000-00-00', ''),
(31, 12, '0000-00-00', '');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Accounts`
--
ALTER TABLE `Accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username_idx` (`username`) USING BTREE;

--
-- Indexes for table `Combos`
--
ALTER TABLE `Combos`
  ADD PRIMARY KEY (`c_id`),
  ADD KEY `name_idx` (`name`(3072));

--
-- Indexes for table `Tricks`
--
ALTER TABLE `Tricks`
  ADD PRIMARY KEY (`g_id`),
  ADD KEY `name_idx` (`name`(3072)) USING BTREE;

--
-- Indexes for table `UserCombos`
--
ALTER TABLE `UserCombos`
  ADD PRIMARY KEY (`ref_id`,`owner_id`);

--
-- Indexes for table `UserPlaylists`
--
ALTER TABLE `UserPlaylists`
  ADD PRIMARY KEY (`name`,`owner_id`) USING BTREE,
  ADD UNIQUE KEY `p_id_idx` (`p_id`) USING BTREE;

--
-- Indexes for table `UserTricks`
--
ALTER TABLE `UserTricks`
  ADD PRIMARY KEY (`ref_id`,`owner_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Accounts`
--
ALTER TABLE `Accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `Combos`
--
ALTER TABLE `Combos`
  MODIFY `c_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `Tricks`
--
ALTER TABLE `Tricks`
  MODIFY `g_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `UserPlaylists`
--
ALTER TABLE `UserPlaylists`
  MODIFY `p_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
