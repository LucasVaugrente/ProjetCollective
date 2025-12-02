-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 08 oct. 2025 à 07:55
-- Version du serveur : 9.1.0
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
  `id` int NOT NULL AUTO_INCREMENT,
  `titre` varchar(255) NOT NULL,
  `contenu` varchar(255) NOT NULL,
  `id_module` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_module` (`id_module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `mediacours`
--

DROP TABLE IF EXISTS `mediacours`;
CREATE TABLE IF NOT EXISTS `mediacours` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_page` int NOT NULL,
  `ordre` int NOT NULL,
  `url` text NOT NULL,
  `type` text NOT NULL,
  `caption` text,
  PRIMARY KEY (`id`),
  KEY `id_page` (`id_page`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `minijeu`
--

DROP TABLE IF EXISTS `minijeu`;
CREATE TABLE IF NOT EXISTS `minijeu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_cours` int NOT NULL,
  `nom` text NOT NULL,
  `description` text,
  `progression` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_cours` (`id_cours`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `module`
--

DROP TABLE IF EXISTS `module`;
CREATE TABLE IF NOT EXISTS `module` (
  `id` int NOT NULL AUTO_INCREMENT,
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
  `id` int NOT NULL AUTO_INCREMENT,
  `id_cours` int NOT NULL,
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
  `id` int NOT NULL AUTO_INCREMENT,
  `description` text,
  `ordre` int NOT NULL,
  `urlAudio` text,
  `est_vue` int DEFAULT '0',
  `id_cours` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_cours` (`id_cours`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `qcm`
--

DROP TABLE IF EXISTS `qcm`;
CREATE TABLE IF NOT EXISTS `qcm` (
  `idQCM` int NOT NULL AUTO_INCREMENT,
  `numSolution` int NOT NULL,
  `idCours` int NOT NULL,
  `idQuestion` int NOT NULL,
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
  `idQuestion` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`idQuestion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `questionimg`
--

DROP TABLE IF EXISTS `questionimg`;
CREATE TABLE IF NOT EXISTS `questionimg` (
  `idQuestion` int NOT NULL,
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
  `idQuestion` int NOT NULL,
  `txt` text NOT NULL,
  PRIMARY KEY (`idQuestion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reponse`
--

DROP TABLE IF EXISTS `reponse`;
CREATE TABLE IF NOT EXISTS `reponse` (
  `idReponse` int NOT NULL AUTO_INCREMENT,
  `idQCM` int NOT NULL,
  PRIMARY KEY (`idReponse`),
  KEY `idQCM` (`idQCM`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `reponseimg`
--

DROP TABLE IF EXISTS `reponseimg`;
CREATE TABLE IF NOT EXISTS `reponseimg` (
  `idReponse` int NOT NULL,
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
  `idReponse` int NOT NULL,
  `txt` text NOT NULL,
  PRIMARY KEY (`idReponse`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
