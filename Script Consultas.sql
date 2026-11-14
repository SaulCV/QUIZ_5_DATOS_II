USE concesionario;

-- 1. Listar todos los vehículos disponibles (no vendidos) ordenados por precio descendente
SELECT v.*
FROM Vehiculos v
LEFT JOIN Ventas vt ON v.id_vehiculo = vt.id_vehiculo
WHERE vt.id_venta IS NULL
ORDER BY v.precio DESC;


-- 2. Mostrar el total de ventas realizadas por cada vendedor (nombre del vendedor y cantidad de ventas)
SELECT 
    vd.id_vendedor,
    CONCAT(vd.nombre, ' ', vd.apellidos) AS vendedor,
    COUNT(vt.id_venta) AS total_ventas
FROM Vendedores vd
LEFT JOIN Ventas vt ON vd.id_vendedor = vt.id_vendedor
GROUP BY vd.id_vendedor, vd.nombre, vd.apellidos
ORDER BY total_ventas DESC;


-- 3. Calcular el ingreso total generado por cada vendedor
SELECT 
    vd.id_vendedor,
    CONCAT(vd.nombre, ' ', vd.apellidos) AS vendedor,
    COALESCE(SUM(vt.precio_venta), 0.00) AS ingreso_total
FROM Vendedores vd
LEFT JOIN Ventas vt ON vd.id_vendedor = vt.id_vendedor
GROUP BY vd.id_vendedor, vd.nombre, vd.apellidos
ORDER BY ingreso_total DESC;


-- 4. Encontrar el cliente que ha realizado la compra más costosa
SELECT 
    c.id_cliente,
    c.cedula,
    CONCAT(c.nombre, ' ', c.apellidos) AS cliente,
    vt.precio_venta AS monto_compra,
    vt.fecha_venta
FROM Clientes c
INNER JOIN Ventas vt ON c.id_cliente = vt.id_cliente
WHERE vt.precio_venta = (SELECT MAX(precio_venta) FROM Ventas);


-- 5. Listar los vehículos vendidos en el último mes con información del cliente comprador
SELECT 
    v.vin,
    v.marca,
    v.modelo,
    v.anio,
    vt.precio_venta,
    vt.fecha_venta,
    c.cedula AS cedula_cliente,
    CONCAT(c.nombre, ' ', c.apellidos) AS cliente,
    c.telefono,
    c.correo
FROM Ventas vt
INNER JOIN Vehiculos v ON vt.id_vehiculo = v.id_vehiculo
INNER JOIN Clientes c ON vt.id_cliente = c.id_cliente
WHERE vt.fecha_venta >= (SELECT MAX(fecha_venta) FROM Ventas) - INTERVAL 1 MONTH
ORDER BY vt.fecha_venta DESC;


-- 6. Calcular la comisión ganada por cada vendedor basado en sus ventas
SELECT 
    vd.id_vendedor,
    CONCAT(vd.nombre, ' ', vd.apellidos) AS vendedor,
    vd.porcentaje_comision,
    COALESCE(SUM(vt.precio_venta), 0.00) AS total_vendido,
    ROUND(COALESCE(SUM(vt.precio_venta * (vd.porcentaje_comision / 100)), 0.00), 2) AS comision_ganada
FROM Vendedores vd
LEFT JOIN Ventas vt ON vd.id_vendedor = vt.id_vendedor
GROUP BY vd.id_vendedor, vd.nombre, vd.apellidos, vd.porcentaje_comision
ORDER BY comision_ganada DESC;


-- 7. Mostrar el promedio de precios de vehículos vendidos agrupados por tipo
SELECT 
    v.estado AS tipo_vehiculo,
    COUNT(vt.id_venta) AS cantidad_vendida,
    ROUND(AVG(vt.precio_venta), 2) AS promedio_precio_venta
FROM Ventas vt
INNER JOIN Vehiculos v ON vt.id_vehiculo = v.id_vehiculo
GROUP BY v.estado;


-- 8. Identificar qué marca de vehículo se ha vendido más veces
SELECT 
    v.marca,
    COUNT(vt.id_venta) AS cantidad_vendida
FROM Ventas vt
INNER JOIN Vehiculos v ON vt.id_vehiculo = v.id_vehiculo
GROUP BY v.marca
HAVING COUNT(vt.id_venta) = (
    SELECT MAX(total_por_marca)
    FROM (
        SELECT COUNT(*) AS total_por_marca
        FROM Ventas vt2
        INNER JOIN Vehiculos v2 ON vt2.id_vehiculo = v2.id_vehiculo
        GROUP BY v2.marca
    ) AS conteos
);