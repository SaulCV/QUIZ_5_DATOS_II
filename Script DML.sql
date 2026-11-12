
USE concesionario;

-- =====================================================================
-- 10 VEHÍCULOS
-- =====================================================================
INSERT INTO Vehiculos (vin, marca, modelo, anio, color, precio, estado) VALUES
('JTDBR32E000000001', 'Toyota',     'Corolla', 2024, 'Blanco', 14500000.00, 'Nuevo'),
('KMHJ3814000000002', 'Hyundai',    'Tucson',  2019, 'Gris',   11000000.00, 'Usado'),
('3N1AB7AP000000003', 'Nissan',     'Sentra',  2021, 'Negro',   9500000.00, 'Usado'),
('MR0FB8CD000000004', 'Toyota',     'Hilux',   2025, 'Plata',  25000000.00, 'Nuevo'),
('KNADM4A3000000005', 'Kia',        'Rio',     2018, 'Rojo',    7000000.00, 'Usado'),
('JM1BK32F000000006', 'Mazda',      'Mazda 3', 2023, 'Azul',   16200000.00, 'Nuevo'),
('1FTEW1EP000000007', 'Ford',       'Ranger',  2020, 'Blanco', 18000000.00, 'Usado'),
('JHMGE884000000008', 'Honda',      'Fit',     2016, 'Verde',   6200000.00, 'Usado'),
('WVWZZZ1J000000009', 'Volkswagen', 'Jetta',   2026, 'Negro',  17900000.00, 'Nuevo'),
('JS3TD94V000000010', 'Suzuki',     'Vitara',  2022, 'Gris',   15500000.00, 'Nuevo');

-- =====================================================================
-- 6 CLIENTES
-- =====================================================================
INSERT INTO Clientes (cedula, nombre, apellidos, telefono, correo, direccion) VALUES
('702340567', 'Carlos',  'Mora Jiménez',    '8888-1234', 'carlos.mora@correo.com',     'Guápiles, Limón'),
('304560789', 'María',   'Rojas Salas',     '8777-5678', 'maria.rojas@correo.com',     'Cartago centro'),
('115890234', 'Andrés',  'Quesada Brenes',  '8612-3344', 'andres.quesada@correo.com',  'San José, Escazú'),
('401230456', 'Sofía',   'Chaves Ulate',    '8456-7788', 'sofia.chaves@correo.com',    'Heredia, Barva'),
('206540321', 'Javier',  'Calderón Vargas', '8321-9900', 'javier.calderon@correo.com', 'Alajuela, Grecia'),
('503450678', 'Valeria', 'Navarro Sánchez', '8990-4455', 'valeria.navarro@correo.com', 'Liberia, Guanacaste');

-- =====================================================================
-- 4 VENDEDORES (todos mayores de 21, comisión entre 0 y 20 %)
-- =====================================================================
INSERT INTO Vendedores (cedula, nombre, apellidos, fecha_nacimiento, telefono, correo, fecha_contratacion, porcentaje_comision) VALUES
('105670890', 'Laura',   'Solís Rojas',     '1995-05-10', '8888-0000', 'laura.solis@concesionario.com',   '2022-03-01', 5.00),
('206780901', 'Diego',   'Araya Campos',    '1988-11-22', '8999-1111', 'diego.araya@concesionario.com',   '2021-07-15', 3.50),
('109870123', 'Paola',   'Jiménez Cordero', '1992-02-18', '8777-2222', 'paola.jimenez@concesionario.com', '2023-01-10', 4.00),
('304320987', 'Esteban', 'Mora Villalobos', '2000-09-05', '8666-3333', 'esteban.mora@concesionario.com',  '2025-06-01', 2.50);

-- =====================================================================
-- 8 VENTAS
--   Laura (1) = 4 ventas, Diego (2) = 2 ventas, Paola (3) y Esteban (4) = 1 cada uno
--   Vehículos 1 al 8 vendidos; el 9 y el 10 siguen disponibles
--   Carlos y María compraron dos veces
-- =====================================================================
INSERT INTO Ventas (id_vehiculo, id_cliente, id_vendedor, fecha_venta, precio_venta, metodo_pago) VALUES
(1, 1, 1, '2025-02-10', 14000000.00, 'Financiado'),
(2, 2, 1, '2025-04-22', 10500000.00, 'Contado'),
(3, 3, 2, '2025-06-15',  9200000.00, 'Transferencia'),
(4, 4, 1, '2025-09-03', 24500000.00, 'Financiado'),
(5, 5, 3, '2025-11-20',  6800000.00, 'Contado'),
(6, 1, 2, '2026-02-14', 15800000.00, 'Tarjeta'),
(7, 6, 1, '2026-05-08', 17500000.00, 'Financiado'),
(8, 2, 4, '2026-08-30',  5900000.00, 'Contado');

-- =====================================================================
-- VERIFICACIÓN
-- =====================================================================

-- Cantidad de registros por tabla
SELECT 'Vehiculos' AS tabla, COUNT(*) AS total FROM Vehiculos
UNION ALL SELECT 'Clientes',   COUNT(*) FROM Clientes
UNION ALL SELECT 'Vendedores', COUNT(*) FROM Vendedores
UNION ALL SELECT 'Ventas',     COUNT(*) FROM Ventas;

-- Detalle de todas las ventas
SELECT v.id_venta,
       v.fecha_venta,
       CONCAT(c.nombre, ' ', c.apellidos)          AS cliente,
       CONCAT(ve.nombre, ' ', ve.apellidos)        AS vendedor,
       CONCAT(a.marca, ' ', a.modelo, ' ', a.anio) AS vehiculo,
       a.estado,
       v.precio_venta,
       v.metodo_pago
FROM Ventas v
JOIN Clientes   c  ON v.id_cliente  = c.id_cliente
JOIN Vendedores ve ON v.id_vendedor = ve.id_vendedor
JOIN Vehiculos  a  ON v.id_vehiculo = a.id_vehiculo
ORDER BY v.fecha_venta;