-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : lun. 03 nov. 2025 à 09:09
-- Version du serveur : 12.0.2-MariaDB
-- Version de PHP : 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `factoscope`
--

-- --------------------------------------------------------

--
-- Structure de la table `cours`
--

DROP TABLE IF EXISTS `cours`;
CREATE TABLE IF NOT EXISTS `cours` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titre` varchar(255) NOT NULL,
  `contenu` varchar(255) NOT NULL,
  `id_module` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_module` (`id_module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `mediacours`
--

DROP TABLE IF EXISTS `mediacours`;
CREATE TABLE IF NOT EXISTS `mediacours` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_page` int(11) NOT NULL,
  `ordre` int(11) NOT NULL,
  `url` text NOT NULL,
  `type` text NOT NULL,
  `caption` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_page` (`id_page`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `minijeu`
--

DROP TABLE IF EXISTS `minijeu`;
CREATE TABLE IF NOT EXISTS `minijeu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_cours` int(11) NOT NULL,
  `nom` text NOT NULL,
  `description` text DEFAULT NULL,
  `progression` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_cours` (`id_cours`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `module`
--

DROP TABLE IF EXISTS `module`;
CREATE TABLE IF NOT EXISTS `module` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `urlImg` varchar(255) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `objectifcours`
--

DROP TABLE IF EXISTS `objectifcours`;
CREATE TABLE IF NOT EXISTS `objectifcours` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_cours` int(11) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_cours` (`id_cours`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `page`
--

DROP TABLE IF EXISTS `page`;
CREATE TABLE IF NOT EXISTS `page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` text DEFAULT NULL,
  `ordre` int(11) NOT NULL,
  `urlAudio` text DEFAULT NULL,
  `est_vue` int(11) DEFAULT 0,
  `id_cours` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_cours` (`id_cours`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `qcm`
--

DROP TABLE IF EXISTS `qcm`;
CREATE TABLE IF NOT EXISTS `qcm` (
  `idQCM` int(11) NOT NULL AUTO_INCREMENT,
  `numSolution` int(11) NOT NULL,
  `idCours` int(11) NOT NULL,
  `idQuestion` int(11) NOT NULL,
  PRIMARY KEY (`idQCM`),
  UNIQUE KEY `idQuestion` (`idQuestion`),
  KEY `idCours` (`idCours`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `question`
--

DROP TABLE IF EXISTS `question`;
CREATE TABLE IF NOT EXISTS `question` (
  `idQuestion` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`idQuestion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `questionimg`
--

DROP TABLE IF EXISTS `questionimg`;
CREATE TABLE IF NOT EXISTS `questionimg` (
  `idQuestion` int(11) NOT NULL,
  `urlImage` text NOT NULL,
  `caption` text NOT NULL,
  PRIMARY KEY (`idQuestion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `questiontext`
--

DROP TABLE IF EXISTS `questiontext`;
CREATE TABLE IF NOT EXISTS `questiontext` (
  `idQuestion` int(11) NOT NULL,
  `txt` text NOT NULL,
  PRIMARY KEY (`idQuestion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reponse`
--

DROP TABLE IF EXISTS `reponse`;
CREATE TABLE IF NOT EXISTS `reponse` (
  `idReponse` int(11) NOT NULL AUTO_INCREMENT,
  `idQCM` int(11) NOT NULL,
  PRIMARY KEY (`idReponse`),
  KEY `idQCM` (`idQCM`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reponseimg`
--

DROP TABLE IF EXISTS `reponseimg`;
CREATE TABLE IF NOT EXISTS `reponseimg` (
  `idReponse` int(11) NOT NULL,
  `urlImage` text NOT NULL,
  `caption` text NOT NULL,
  PRIMARY KEY (`idReponse`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reponsetext`
--

DROP TABLE IF EXISTS `reponsetext`;
CREATE TABLE IF NOT EXISTS `reponsetext` (
  `idReponse` int(11) NOT NULL,
  `txt` text NOT NULL,
  PRIMARY KEY (`idReponse`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
