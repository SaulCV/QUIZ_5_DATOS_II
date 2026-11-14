
DROP DATABASE IF EXISTS concesionario;
CREATE DATABASE concesionario
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE concesionario;

-- =====================================================================
-- 1. TABLA VEHICULOS
-- =====================================================================
CREATE TABLE Vehiculos (
    id_vehiculo     INT UNSIGNED AUTO_INCREMENT,
    vin             CHAR(17)      NOT NULL,
    marca           VARCHAR(50)   NOT NULL,
    modelo          VARCHAR(50)   NOT NULL,
    anio            SMALLINT      NOT NULL,
    color           VARCHAR(30)   NOT NULL,
    precio          DECIMAL(12,2) NOT NULL,
    estado          VARCHAR(10)   NOT NULL,
    fecha_registro  DATE          NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_vehiculos         PRIMARY KEY (id_vehiculo),
    CONSTRAINT uq_vehiculos_vin     UNIQUE (vin),
    CONSTRAINT chk_vehiculos_anio   CHECK (anio BETWEEN 1900 AND YEAR(fecha_registro)),
    CONSTRAINT chk_vehiculos_precio CHECK (precio > 0),
    CONSTRAINT chk_vehiculos_estado CHECK (estado IN ('Nuevo', 'Usado'))
) ENGINE = InnoDB;

-- =====================================================================
-- 2. TABLA CLIENTES
-- =====================================================================
CREATE TABLE Clientes (
    id_cliente      INT UNSIGNED AUTO_INCREMENT,
    cedula          VARCHAR(20)  NOT NULL,
    nombre          VARCHAR(50)  NOT NULL,
    apellidos       VARCHAR(80)  NOT NULL,
    telefono        VARCHAR(20)  NOT NULL,
    correo          VARCHAR(100) NOT NULL,
    direccion       VARCHAR(200),
    fecha_registro  DATE         NOT NULL DEFAULT (CURRENT_DATE),

    CONSTRAINT pk_clientes        PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_cedula UNIQUE (cedula),
    CONSTRAINT uq_clientes_correo UNIQUE (correo)
) ENGINE = InnoDB;

-- =====================================================================
-- 3. TABLA VENDEDORES
-- =====================================================================
CREATE TABLE Vendedores (
    id_vendedor          INT UNSIGNED AUTO_INCREMENT,
    cedula               VARCHAR(20)  NOT NULL,
    nombre               VARCHAR(50)  NOT NULL,
    apellidos            VARCHAR(80)  NOT NULL,
    fecha_nacimiento     DATE         NOT NULL,
    telefono             VARCHAR(20)  NOT NULL,
    correo               VARCHAR(100) NOT NULL,
    fecha_contratacion   DATE         NOT NULL DEFAULT (CURRENT_DATE),
    porcentaje_comision  DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_vendedores           PRIMARY KEY (id_vendedor),
    CONSTRAINT uq_vendedores_cedula    UNIQUE (cedula),
    CONSTRAINT uq_vendedores_correo    UNIQUE (correo),
    CONSTRAINT chk_vendedores_comision CHECK (porcentaje_comision BETWEEN 0 AND 20),
    CONSTRAINT chk_vendedores_edad     CHECK (fecha_nacimiento <= fecha_contratacion - INTERVAL 21 YEAR)
) ENGINE = InnoDB;

-- =====================================================================
-- 4. TABLA VENTAS (normalizada: referencia a las otras tablas)
-- =====================================================================
CREATE TABLE Ventas (
    id_venta      INT UNSIGNED AUTO_INCREMENT,
    id_vehiculo   INT UNSIGNED  NOT NULL,
    id_cliente    INT UNSIGNED  NOT NULL,
    id_vendedor   INT UNSIGNED  NOT NULL,
    fecha_venta   DATE NOT NULL DEFAULT (CURRENT_DATE),
    precio_venta  DECIMAL(12,2) NOT NULL,
    metodo_pago   VARCHAR(20)   NOT NULL,

    CONSTRAINT pk_ventas          PRIMARY KEY (id_venta),
    CONSTRAINT uq_ventas_vehiculo UNIQUE (id_vehiculo),   -- un vehículo se vende una sola vez
    CONSTRAINT chk_ventas_precio  CHECK (precio_venta > 0),
    CONSTRAINT chk_ventas_metodo  CHECK (metodo_pago IN ('Contado','Financiado','Tarjeta','Transferencia')),

    CONSTRAINT fk_ventas_vehiculo FOREIGN KEY (id_vehiculo)
        REFERENCES Vehiculos (id_vehiculo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (id_cliente)
        REFERENCES Clientes (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_vendedor FOREIGN KEY (id_vendedor)
        REFERENCES Vendedores (id_vendedor)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- =====================================================================
-- 5. TRIGGERS (validan contra la fecha de HOY)
-- =====================================================================
DELIMITER $$

-- Vehículos: año entre 1900 y el año actual (al insertar)
CREATE TRIGGER trg_vehiculos_anio_ins
BEFORE INSERT ON Vehiculos
FOR EACH ROW
BEGIN
    IF NEW.anio < 1900 OR NEW.anio > YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El año del vehículo debe estar entre 1900 y el año actual';
    END IF;
END $$

-- Vehículos: año entre 1900 y el año actual (al modificar)
CREATE TRIGGER trg_vehiculos_anio_upd
BEFORE UPDATE ON Vehiculos
FOR EACH ROW
BEGIN
    IF NEW.anio < 1900 OR NEW.anio > YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El año del vehículo debe estar entre 1900 y el año actual';
    END IF;
END $$

-- Vendedores: mínimo 21 años de edad (al insertar)
CREATE TRIGGER trg_vendedores_edad_ins
BEFORE INSERT ON Vendedores
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE()) < 21 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El vendedor debe tener al menos 21 años de edad';
    END IF;
END $$

-- Vendedores: mínimo 21 años de edad (al modificar)
CREATE TRIGGER trg_vendedores_edad_upd
BEFORE UPDATE ON Vendedores
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE()) < 21 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El vendedor debe tener al menos 21 años de edad';
    END IF;
END $$

DELIMITER ;