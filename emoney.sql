-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 23-10-2020 a las 22:13:01
-- Versión del servidor: 5.7.26
-- Versión de PHP: 7.3.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `emoney`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `p_actualizar_secuencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_actualizar_secuencia` (IN `pa_nombre_tabla` VARCHAR(45))  BEGIN
	DECLARE vl_secuencia_siguiente int(5);
	DECLARE vl_incremento int(1);
	
	SELECT SECUENCIA_SIGUIENTE, INCREMENTO
	  INTO vl_secuencia_siguiente, vl_incremento
		FROM sys_secuencias
	 WHERE NOMBRE_TABLA = pa_nombre_tabla;
	 
	 UPDATE sys_secuencias
	    SET SECUENCIA_ANTERIOR = vl_secuencia_siguiente,
			    SECUENCIA_SIGUIENTE = (vl_incremento + vl_secuencia_siguiente)
		WHERE NOMBRE_TABLA = pa_nombre_tabla;

END$$

DROP PROCEDURE IF EXISTS `p_insertar_billetera`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_insertar_billetera` (IN `pa_id_billetera` VARCHAR(16))  BEGIN
	INSERT INTO billeteras(ID_BILLETERA,FECHA_CREACION,BILLETERA_ASIGNADA,USU_CRE,FEC_CRE)
	VALUES(pa_id_billetera,CURRENT_DATE(),'N','emoney_admin',CURRENT_DATE());

END$$

DROP PROCEDURE IF EXISTS `p_procesar_billeteras`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_procesar_billeteras` ()  BEGIN
  DECLARE vl_tabla varchar(45) DEFAULT 'billeteras';
  DECLARE vl_contador int(2) DEFAULT 1;
	DECLARE vl_billetera varchar(16);
	
	WHILE vl_contador <= 10 DO
		SET vl_billetera = f_generar_billetera(vl_tabla);
		call p_insertar_billetera(vl_billetera);
		call p_actualizar_secuencia(vl_tabla);
		SET vl_contador = vl_contador + 1;
	END WHILE;
END$$

--
-- Funciones
--
DROP FUNCTION IF EXISTS `f_generar_billetera`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_generar_billetera` (`pa_nombre_tabla` VARCHAR(45)) RETURNS VARCHAR(16) CHARSET utf8mb4 BEGIN
	DECLARE vl_incremento int(1);
	DECLARE vl_secuencia_anterior int(5);
	DECLARE vl_secuencia_siguiente int(5);
	DECLARE vl_secuencia varchar(16);
	
	SET vl_incremento = f_obtener_incremento(pa_nombre_tabla);
	SET vl_secuencia_anterior = f_obtener_secuencia_anterior(pa_nombre_tabla);
	SET vl_secuencia_siguiente = f_obtener_secuencia_siguiente(pa_nombre_tabla);
	
	IF vl_secuencia_anterior <=> 0 THEN
		SET vl_secuencia = CONCAT('0000',vl_incremento);
	ELSE
		IF LENGTH(vl_secuencia_siguiente) <=> 1 THEN
			SET vl_secuencia = CONCAT('0000',(vl_secuencia_anterior + vl_incremento));
		ELSEIF LENGTH(vl_secuencia_siguiente) <=> 2 THEN
			SET vl_secuencia = CONCAT('000',(vl_secuencia_anterior + vl_incremento));
		ELSEIF LENGTH(vl_secuencia_siguiente) <=> 3 THEN
			SET vl_secuencia = CONCAT('00',(vl_secuencia_anterior + vl_incremento));
		ELSEIF LENGTH(vl_secuencia_siguiente) <=> 4 THEN
			SET vl_secuencia = CONCAT('0',(vl_secuencia_anterior + vl_incremento));
		ELSE
			SET vl_secuencia = (vl_secuencia_anterior + vl_incremento);
		END IF;
	END IF;
	
	SET vl_secuencia = CONCAT(100,(CURRENT_DATE +0),vl_secuencia);

	RETURN vl_secuencia;
END$$

DROP FUNCTION IF EXISTS `f_obtener_incremento`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_obtener_incremento` (`pa_nombre_tabla` VARCHAR(40)) RETURNS INT(11) BEGIN
	#variable
	DECLARE vl_incremento int(1);

	SELECT INCREMENTO
	  INTO vl_incremento
	  FROM sys_secuencias
	 WHERE NOMBRE_TABLA = pa_nombre_tabla;
	
	RETURN vl_incremento;
END$$

DROP FUNCTION IF EXISTS `f_obtener_secuencia_anterior`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_obtener_secuencia_anterior` (`pa_nombre_tabla` VARCHAR(45)) RETURNS INT(11) BEGIN
	DECLARE vl_secuencia_anterior int(5);
	
	SELECT SECUENCIA_ANTERIOR
	  INTO vl_secuencia_anterior
		FROM sys_secuencias
	 WHERE NOMBRE_TABLA = pa_nombre_tabla;

	RETURN vl_secuencia_anterior;
END$$

DROP FUNCTION IF EXISTS `f_obtener_secuencia_siguiente`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `f_obtener_secuencia_siguiente` (`pa_nombre_tabla` VARCHAR(45)) RETURNS INT(11) BEGIN
	DECLARE vl_secuencia_siguiente int(5);
	
	SELECT SECUENCIA_SIGUIENTE
	  INTO vl_secuencia_siguiente
		FROM sys_secuencias
	 WHERE NOMBRE_TABLA = pa_nombre_tabla;

	RETURN vl_secuencia_siguiente;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `billeteras`
--

DROP TABLE IF EXISTS `billeteras`;
CREATE TABLE IF NOT EXISTS `billeteras` (
  `ID_BILLETERA` varchar(16) NOT NULL,
  `FECHA_CREACION` datetime NOT NULL,
  `BILLETERA_ASIGNADA` char(1) NOT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  PRIMARY KEY (`ID_BILLETERA`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

--
-- Volcado de datos para la tabla `billeteras`
--

INSERT INTO `billeteras` (`ID_BILLETERA`, `FECHA_CREACION`, `BILLETERA_ASIGNADA`, `USU_CRE`, `FEC_CRE`, `USU_MOD`, `FEC_MOD`) VALUES
('10', '2020-03-13 00:00:00', 's', 'emoney_admin', '2020-03-13 00:00:00', 'yo', '2020-03-15 06:17:02'),
('1002020031700045', '2020-03-17 00:00:00', 'S', 'emoney_admin', '2020-03-17 00:00:00', 'juanito', '2020-03-21 02:46:27'),
('1002020031700046', '2020-03-17 00:00:00', 'S', 'emoney_admin', '2020-03-17 00:00:00', 'juanito', '2020-03-21 02:47:34'),
('1002020031700047', '2020-03-17 00:00:00', 'S', 'emoney_admin', '2020-03-17 00:00:00', 'juanito', '2020-03-21 20:06:42'),
('1002020031700048', '2020-03-17 00:00:00', 'S', 'emoney_admin', '2020-03-17 00:00:00', 'juanito', '2020-03-21 20:27:50'),
('1002020031700049', '2020-03-17 00:00:00', 'S', 'emoney_admin', '2020-03-17 00:00:00', 'juanito', '2020-03-22 23:02:22'),
('1002020031700050', '2020-03-17 00:00:00', 'S', 'emoney_admin', '2020-03-17 00:00:00', 'juanito', '2020-03-22 23:05:20'),
('1002020032200051', '2020-03-22 00:00:00', 'S', 'emoney_admin', '2020-03-22 00:00:00', 'juanito', '2020-03-23 02:53:01'),
('1002020032200052', '2020-03-22 00:00:00', 'S', 'emoney_admin', '2020-03-22 00:00:00', 'juanito', '2020-09-16 19:27:46'),
('1002020032200053', '2020-03-22 00:00:00', 'S', 'emoney_admin', '2020-03-22 00:00:00', 'yo', '2020-09-16 19:33:34'),
('1002020032200054', '2020-03-22 00:00:00', 'S', 'emoney_admin', '2020-03-22 00:00:00', 'yo', '2020-09-22 17:32:20'),
('1002020032200055', '2020-03-22 00:00:00', 'S', 'emoney_admin', '2020-03-22 00:00:00', 'yo', '2020-10-11 22:28:43'),
('1002020032200056', '2020-03-22 00:00:00', 'S', 'emoney_admin', '2020-03-22 00:00:00', 'yo', '2020-10-11 22:35:03'),
('1002020032200057', '2020-03-22 00:00:00', 'S', 'emoney_admin', '2020-03-22 00:00:00', 'yo', '2020-10-11 23:06:23'),
('1002020032200058', '2020-03-22 00:00:00', 'N', 'emoney_admin', '2020-03-22 00:00:00', NULL, NULL),
('1002020032200059', '2020-03-22 00:00:00', 'N', 'emoney_admin', '2020-03-22 00:00:00', NULL, NULL),
('1002020032200060', '2020-03-22 00:00:00', 'N', 'emoney_admin', '2020-03-22 00:00:00', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `billeteras_clientes`
--

DROP TABLE IF EXISTS `billeteras_clientes`;
CREATE TABLE IF NOT EXISTS `billeteras_clientes` (
  `ID_CLIENTE` bigint(20) DEFAULT NULL,
  `ID_BILLETERA` varchar(16) DEFAULT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  UNIQUE KEY `IDX_BILCLIE_BIL` (`ID_BILLETERA`) USING BTREE,
  UNIQUE KEY `IDX_BILCLIE_CLIE` (`ID_CLIENTE`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

--
-- Volcado de datos para la tabla `billeteras_clientes`
--

INSERT INTO `billeteras_clientes` (`ID_CLIENTE`, `ID_BILLETERA`, `USU_CRE`, `FEC_CRE`, `USU_MOD`, `FEC_MOD`) VALUES
(9999999998852, '1002020031700047', 'juanito', '2020-03-21 20:06:42', NULL, NULL),
(9999999998853, '1002020031700048', 'juanito', '2020-03-21 20:27:50', NULL, NULL),
(9999999998858, '1002020031700049', 'juanito', '2020-03-22 23:02:22', NULL, NULL),
(9999999998859, '1002020031700050', 'juanito', '2020-03-22 23:05:20', NULL, NULL),
(9999999998860, '1002020032200051', 'juanito', '2020-03-23 02:53:01', NULL, NULL),
(9999999998862, '1002020032200052', 'juanito', '2020-09-16 19:27:46', NULL, NULL),
(9999999998863, '1002020032200053', 'yo', '2020-09-16 19:33:34', NULL, NULL),
(9999999998866, '1002020032200054', 'yo', '2020-09-22 17:32:20', NULL, NULL),
(9999999998868, '1002020032200055', 'yo', '2020-10-11 22:28:43', NULL, NULL),
(9999999998869, '1002020032200056', 'yo', '2020-10-11 22:35:03', NULL, NULL),
(9999999998870, '1002020032200057', 'yo', '2020-10-11 23:06:23', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

DROP TABLE IF EXISTS `clientes`;
CREATE TABLE IF NOT EXISTS `clientes` (
  `id_cliente` bigint(20) NOT NULL AUTO_INCREMENT,
  `IDENTIDAD` varchar(13) NOT NULL,
  `PRIMER_NOMBRE` char(45) NOT NULL,
  `SEGUNDO_NOMBRE` char(45) DEFAULT NULL,
  `PRIMER_APELLIDO` char(45) NOT NULL,
  `SEGUNDO_APELLIDO` char(45) DEFAULT NULL,
  `FECHA_NACIMIENTO` date NOT NULL,
  `SEXO` char(1) NOT NULL,
  `EMAIL` varchar(30) NOT NULL,
  `DIRECCION` varchar(120) DEFAULT NULL,
  `PIN` varchar(255) NOT NULL,
  `ESTADO_CLIENTE` char(1) NOT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  PRIMARY KEY (`id_cliente`) USING BTREE,
  UNIQUE KEY `IDX_CLI_IDENTIDAD` (`id_cliente`) USING BTREE,
  UNIQUE KEY `IDENTIDAD` (`IDENTIDAD`),
  UNIQUE KEY `EMAIL` (`EMAIL`),
  UNIQUE KEY `PIN` (`PIN`)
) ENGINE=InnoDB AUTO_INCREMENT=9999999998871 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `IDENTIDAD`, `PRIMER_NOMBRE`, `SEGUNDO_NOMBRE`, `PRIMER_APELLIDO`, `SEGUNDO_APELLIDO`, `FECHA_NACIMIENTO`, `SEXO`, `EMAIL`, `DIRECCION`, `PIN`, `ESTADO_CLIENTE`, `USU_CRE`, `FEC_CRE`, `USU_MOD`, `FEC_MOD`) VALUES
(9999999998852, '6777767956655', 'Juan', 'de la candelaria', 'Velasquez', 'Gomez', '2020-04-09', 'm', 'xaxddAxxx@gmail.com', NULL, '75776', 'a', 'juanito', '2020-03-21 20:06:42', NULL, NULL),
(9999999998853, '0801198677505', 'Pedro', 'de la candelaria', 'Velasquez', 'Gomez', '2020-04-09', 'm', 'xadfhgjhkj@gmail.com', NULL, '9009', 'a', 'juanito', '2020-03-21 20:27:50', NULL, NULL),
(9999999998858, '0801198677506', 'Pedro', 'de la candelaria', 'Velasquez', 'Gomez', '2020-04-09', 'm', 'xadfhcfyvguh@gmail.com', NULL, '8009', 'a', 'juanito', '2020-03-22 23:02:22', NULL, NULL),
(9999999998859, '0801198677507', 'Pedro', 'de la candelaria', 'Velasquez', 'Gomez', '2020-04-09', 'm', 'xadfhcfyvguh11@gmail.com', NULL, '8008', 'a', 'juanito', '2020-03-22 23:05:20', NULL, NULL),
(9999999998860, '0801198677508', 'Pedro', 'de la candelaria', 'Velasquez', 'Gomez', '2020-04-09', 'm', 'xadfhcfyvguh118@gmail.com', NULL, '8007', 'a', 'juanito', '2020-03-23 02:53:01', NULL, NULL),
(9999999998862, '0801198677999', 'Pedro', 'de la candelaria', 'Velasquez', 'Gomez', '2020-04-09', 'm', 'xadfhch118@gmail.com', NULL, '8077', 'a', 'juanito', '2020-09-16 19:27:46', NULL, NULL),
(9999999998863, '0801198677333', 'Maria', 'Rosa', 'Sosa', 'Gomez', '1999-11-01', 'f', 'MariaSosa@xmail.com', NULL, '2020', 'a', 'yo', '2020-09-16 19:33:34', NULL, NULL),
(9999999998866, '0801198677334', 'Petronila', 'Rosa', 'Sosa', 'Gomez', '1999-11-01', 'f', 'Maria', NULL, '2021', 'a', 'yo', '2020-09-22 17:32:20', NULL, NULL),
(9999999998868, '0801198677335', 'Petronila', 'Rosa', 'Sosa', 'Gomez', '1999-11-01', 'f', 'Maria@gamail.com', NULL, '2055', 'a', 'yo', '2020-10-11 22:28:43', NULL, NULL),
(9999999998869, '0801198677345', 'Petronila', 'Rosa', 'Sosa', 'Gomez', '1999-11-01', 'f', 'Mariaaa@gamail.com', NULL, '2056', 'a', 'yo', '2020-10-11 22:35:03', NULL, NULL),
(9999999998870, '0801198677348', 'Petronila', 'Rosa', 'Sosa', 'Gomez', '1999-11-01', 'f', 'Maa@gamail.com', NULL, 'wsedtrfygtuyhioij', 'a', 'yo', '2020-10-11 23:06:23', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `errores`
--

DROP TABLE IF EXISTS `errores`;
CREATE TABLE IF NOT EXISTS `errores` (
  `ID_ERROR` bigint(20) NOT NULL,
  `MENSAJE_ERROR` varchar(400) NOT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  PRIMARY KEY (`ID_ERROR`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_pin`
--

DROP TABLE IF EXISTS `historial_pin`;
CREATE TABLE IF NOT EXISTS `historial_pin` (
  `ID_SOLICITUD` bigint(20) NOT NULL,
  `FECHA_SOLICITUD` datetime NOT NULL,
  `ID_CLIENTE` bigint(20) DEFAULT NULL,
  `PIN_ANTERIOR` varchar(20) NOT NULL,
  `PIN_ACTUAL` varchar(20) NOT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  PRIMARY KEY (`ID_SOLICITUD`) USING BTREE,
  KEY `fk_HISTORIAL_PIN_CLIENTES` (`ID_CLIENTE`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos_billeteras`
--

DROP TABLE IF EXISTS `movimientos_billeteras`;
CREATE TABLE IF NOT EXISTS `movimientos_billeteras` (
  `ID_MOVIMIENTO` bigint(20) NOT NULL,
  `FECHA_MOVIMIENTO` datetime NOT NULL,
  `ID_TRANSACCION` bigint(20) DEFAULT NULL,
  `MONTO_TRANSACCION` double NOT NULL,
  `SALDO_ANTERIOR` double NOT NULL,
  `SALDO_POSTERIOR` double NOT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  PRIMARY KEY (`ID_MOVIMIENTO`) USING BTREE,
  KEY `fk_MOVIMIENTOS_BILLETERAS_TRANSACCIONES` (`ID_TRANSACCION`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `saldo_billetera`
--

DROP TABLE IF EXISTS `saldo_billetera`;
CREATE TABLE IF NOT EXISTS `saldo_billetera` (
  `ID_BILLETERA` varchar(16) NOT NULL,
  `SALDO_BILLETERA` double NOT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  UNIQUE KEY `IDX_BILL_SALDO` (`ID_BILLETERA`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

--
-- Volcado de datos para la tabla `saldo_billetera`
--

INSERT INTO `saldo_billetera` (`ID_BILLETERA`, `SALDO_BILLETERA`, `USU_CRE`, `FEC_CRE`, `USU_MOD`, `FEC_MOD`) VALUES
('1002020031700047', 0, 'juanito', '2020-03-21 20:06:42', NULL, NULL),
('1002020031700048', 0, 'juanito', '2020-03-21 20:27:50', NULL, NULL),
('1002020031700049', 0, 'juanito', '2020-03-22 23:02:22', NULL, NULL),
('1002020031700050', 0, 'juanito', '2020-03-22 23:05:20', NULL, NULL),
('1002020032200051', 0, 'juanito', '2020-03-23 02:53:01', NULL, NULL),
('1002020032200052', 0, 'juanito', '2020-09-16 19:27:46', NULL, NULL),
('1002020032200053', 0, 'yo', '2020-09-16 19:33:34', NULL, NULL),
('1002020032200054', 0, 'yo', '2020-09-22 17:32:20', NULL, NULL),
('1002020032200055', 0, 'yo', '2020-10-11 22:28:43', NULL, NULL),
('1002020032200056', 0, 'yo', '2020-10-11 22:35:03', NULL, NULL),
('1002020032200057', 0, 'yo', '2020-10-11 23:06:23', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicios`
--

DROP TABLE IF EXISTS `servicios`;
CREATE TABLE IF NOT EXISTS `servicios` (
  `ID_SERVICIO` bigint(20) NOT NULL,
  `NOMBRE` varchar(45) NOT NULL,
  `DESCRIPCION` varchar(200) NOT NULL,
  `ESTADO_SERVICIO` char(1) NOT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  PRIMARY KEY (`ID_SERVICIO`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sys_secuencias`
--

DROP TABLE IF EXISTS `sys_secuencias`;
CREATE TABLE IF NOT EXISTS `sys_secuencias` (
  `ID_TABLA` bigint(20) NOT NULL,
  `NOMBRE_TABLA` varchar(60) NOT NULL,
  `INCREMENTO` int(11) NOT NULL,
  `SECUENCIA_ANTERIOR` int(11) NOT NULL,
  `SECUENCIA_SIGUIENTE` int(11) NOT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  PRIMARY KEY (`ID_TABLA`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

--
-- Volcado de datos para la tabla `sys_secuencias`
--

INSERT INTO `sys_secuencias` (`ID_TABLA`, `NOMBRE_TABLA`, `INCREMENTO`, `SECUENCIA_ANTERIOR`, `SECUENCIA_SIGUIENTE`, `USU_CRE`, `FEC_CRE`, `USU_MOD`, `FEC_MOD`) VALUES
(1, 'billeteras', 1, 60, 61, 'yo', '2020-03-13 00:00:00', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transacciones`
--

DROP TABLE IF EXISTS `transacciones`;
CREATE TABLE IF NOT EXISTS `transacciones` (
  `ID_TRANSACCION` bigint(20) NOT NULL,
  `FECHA_TRANSACCION` datetime NOT NULL,
  `ID_BILLETERA` varchar(16) NOT NULL,
  `TIPO_TRANSACCION` varchar(2) NOT NULL,
  `ID_SERVICIO` bigint(20) DEFAULT NULL,
  `ESTADO_TRANSACCION` char(1) NOT NULL,
  `ID_ERROR` bigint(20) DEFAULT NULL,
  `USU_CRE` varchar(45) NOT NULL,
  `FEC_CRE` datetime NOT NULL,
  `USU_MOD` varchar(45) DEFAULT NULL,
  `FEC_MOD` datetime DEFAULT NULL,
  PRIMARY KEY (`ID_TRANSACCION`) USING BTREE,
  KEY `fk_TRANSACCIONES_BILLETERAS` (`ID_BILLETERA`) USING BTREE,
  KEY `fk_TRANSACCIONES_ERRORES` (`ID_ERROR`) USING BTREE,
  KEY `fk_TRANSACCIONES_SERVICIOS` (`ID_SERVICIO`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `billeteras_clientes`
--
ALTER TABLE `billeteras_clientes`
  ADD CONSTRAINT `billeteras_clientes_ibfk_1` FOREIGN KEY (`ID_CLIENTE`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_BILLETERAS_CLIENTES_BILLETERAS` FOREIGN KEY (`ID_BILLETERA`) REFERENCES `billeteras` (`ID_BILLETERA`);

--
-- Filtros para la tabla `historial_pin`
--
ALTER TABLE `historial_pin`
  ADD CONSTRAINT `historial_pin_ibfk_1` FOREIGN KEY (`ID_CLIENTE`) REFERENCES `clientes` (`id_cliente`);

--
-- Filtros para la tabla `movimientos_billeteras`
--
ALTER TABLE `movimientos_billeteras`
  ADD CONSTRAINT `fk_MOVIMIENTOS_BILLETERAS_TRANSACCIONES` FOREIGN KEY (`ID_TRANSACCION`) REFERENCES `transacciones` (`ID_TRANSACCION`);

--
-- Filtros para la tabla `saldo_billetera`
--
ALTER TABLE `saldo_billetera`
  ADD CONSTRAINT `fk_SALDO_BILLETERA_BILLETERAS` FOREIGN KEY (`ID_BILLETERA`) REFERENCES `billeteras` (`ID_BILLETERA`);

--
-- Filtros para la tabla `transacciones`
--
ALTER TABLE `transacciones`
  ADD CONSTRAINT `fk_TRANSACCIONES_BILLETERAS` FOREIGN KEY (`ID_BILLETERA`) REFERENCES `billeteras` (`ID_BILLETERA`),
  ADD CONSTRAINT `fk_TRANSACCIONES_ERRORES` FOREIGN KEY (`ID_ERROR`) REFERENCES `errores` (`ID_ERROR`),
  ADD CONSTRAINT `fk_TRANSACCIONES_SERVICIOS` FOREIGN KEY (`ID_SERVICIO`) REFERENCES `servicios` (`ID_SERVICIO`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
