DROP DATABASE IF EXISTS LittleCeasarsDB;
CREATE DATABASE IF NOT EXISTS LittleCeasarsDB;
USE LittleCeasarsDB;

CREATE TABLE Franquiciatario (
  id_franquiciatario INT AUTO_INCREMENT PRIMARY KEY,
  nombre_fiscal VARCHAR(255),
  rfc CHAR(13) UNIQUE,
  telefono_contacto VARCHAR(20),
  correo_corporativo VARCHAR(255) UNIQUE,
  fecha_alta DATE,
  activo BOOLEAN
);

CREATE TABLE Tasa_IVA_Catalogo (
  id_tasa INT AUTO_INCREMENT PRIMARY KEY,
  descripcion VARCHAR(255),
  porcentaje DECIMAL(5,2),
  vigente_desde DATE,
  vigente_hasta DATE,
  CHECK (porcentaje >= 0 AND porcentaje <= 100)
);

CREATE TABLE Ubicacion (
  id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
  continente VARCHAR(100),
  pais VARCHAR(100),
  estado VARCHAR(100),
  municipio VARCHAR(100),
  codigo_postal VARCHAR(10),
  id_tasa INT,
  FOREIGN KEY (id_tasa) REFERENCES Tasa_IVA_Catalogo(id_tasa)
);

CREATE TABLE Sucursal (
  id_sucursal INT AUTO_INCREMENT PRIMARY KEY,
  id_franquiciatario INT,
  id_ubicacion INT,
  nombre_tienda VARCHAR(255),
  direccion_exacta VARCHAR(255),
  telefono_sucursal VARCHAR(20),
  presupuesto_mensual DECIMAL(12,2),
  fecha_apertura DATE,
  estatus VARCHAR(50),
  CHECK (presupuesto_mensual >= 0),
  CHECK (estatus IN ('Activa','Temporalmente Cerrada','Clausurada')),
  FOREIGN KEY (id_franquiciatario) REFERENCES Franquiciatario(id_franquiciatario),
  FOREIGN KEY (id_ubicacion) REFERENCES Ubicacion(id_ubicacion)
);

CREATE TABLE Puesto (
  id_puesto INT AUTO_INCREMENT PRIMARY KEY,
  nombre_puesto VARCHAR(100),
  departamento VARCHAR(100),
  salario_base_diario DECIMAL(10,2),
  comisiones_activas BOOLEAN,
  CHECK (salario_base_diario >= 0)
);

CREATE TABLE Empleado (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY,
  id_sucursal INT,
  id_puesto INT,
  nombre VARCHAR(100),
  apellido_paterno VARCHAR(100),
  apellido_materno VARCHAR(100),
  fecha_nacimiento DATE,
  fecha_ingreso DATE,
  fecha_baja DATE,
  estatus VARCHAR(50),
  CHECK (estatus IN ('Activo','Inactivo','Suspendido')),
  FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
  FOREIGN KEY (id_puesto) REFERENCES Puesto(id_puesto)
);

CREATE TABLE Documentacion_Empleado (
  id_doc INT AUTO_INCREMENT PRIMARY KEY,
  id_empleado INT UNIQUE,
  curp CHAR(18) UNIQUE,
  nss CHAR(11) UNIQUE,
  link_ine VARCHAR(255),
  link_acta_nacimiento VARCHAR(255),
  link_comprobante_domicilio VARCHAR(255),
  link_curriculum VARCHAR(255),
  correo_personal VARCHAR(255),
  fecha_vencimiento_ine DATE,
  FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

CREATE TABLE Turno_Laboral (
  id_turno INT AUTO_INCREMENT PRIMARY KEY,
  id_empleado INT,
  id_sucursal INT,
  fecha DATE,
  hora_entrada TIME,
  hora_salida TIME,
  horas_trabajadas DECIMAL(10,2),
  arqueo_caja_inicio DECIMAL(12,2),
  arqueo_caja_final DECIMAL(12,2),
  diferencia_caja DECIMAL(12,2),
  incidencia VARCHAR(50),
  CHECK (horas_trabajadas >= 0),
  CHECK (arqueo_caja_inicio >= 0),
  CHECK (arqueo_caja_final >= 0),
  CHECK (incidencia IS NULL OR incidencia IN ('Retardo','Falta justificada','Falta injustificada')),
  FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
  FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

CREATE TABLE Categoria_Insumo (
  id_categoria_insumo INT AUTO_INCREMENT PRIMARY KEY,
  nombre_categoria VARCHAR(100)
);

CREATE TABLE Insumo (
  id_insumo INT AUTO_INCREMENT PRIMARY KEY,
  id_categoria_insumo INT,
  nombre_insumo VARCHAR(255),
  unidad_medida VARCHAR(20),
  costo_unitario_compra DECIMAL(10,4),
  proveedor_principal VARCHAR(255),
  activo BOOLEAN,
  CHECK (costo_unitario_compra >= 0),
  FOREIGN KEY (id_categoria_insumo) REFERENCES Categoria_Insumo(id_categoria_insumo)
);

CREATE TABLE Proveedor (
  id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre_fiscal VARCHAR(255),
  rfc VARCHAR(13),
  telefono VARCHAR(20),
  correo VARCHAR(255),
  tipo_insumo_suministrado VARCHAR(255),
  condiciones_pago VARCHAR(50),
  CHECK (condiciones_pago IN ('Contado','15 dias','30 dias'))
);

CREATE TABLE Orden_Compra (
  id_orden INT AUTO_INCREMENT PRIMARY KEY,
  id_proveedor INT,
  id_sucursal INT,
  fecha_orden DATE,
  fecha_entrega_estimada DATE,
  fecha_entrega_real DATE,
  estatus VARCHAR(50),
  total_orden DECIMAL(12,2),
  CHECK (total_orden >= 0),
  CHECK (estatus IN ('Pendiente','Recibida','Cancelada')),
  FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
  FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

CREATE TABLE Orden_Compra_Detalle (
  id_detalle_orden INT AUTO_INCREMENT PRIMARY KEY,
  id_orden INT,
  id_insumo INT,
  cantidad_solicitada DECIMAL(12,4),
  precio_unitario_pactado DECIMAL(10,4),
  CHECK (cantidad_solicitada >= 0),
  CHECK (precio_unitario_pactado >= 0),
  FOREIGN KEY (id_orden) REFERENCES Orden_Compra(id_orden),
  FOREIGN KEY (id_insumo) REFERENCES Insumo(id_insumo)
);

CREATE TABLE Inventario_Sucursal (
  id_inventario INT AUTO_INCREMENT PRIMARY KEY,
  id_sucursal INT,
  id_insumo INT,
  cantidad_existencia DECIMAL(12,4),
  fecha_caducidad DATE,
  codigo_lote VARCHAR(100),
  stock_minimo_alerta DECIMAL(12,4),
  fecha_ultimo_conteo DATE,
  CHECK (cantidad_existencia >= 0),
  CHECK (stock_minimo_alerta >= 0),
  UNIQUE (id_sucursal, id_insumo, codigo_lote),
  FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
  FOREIGN KEY (id_insumo) REFERENCES Insumo(id_insumo)
);

CREATE TABLE Categoria_Producto (
  id_categoria_producto INT AUTO_INCREMENT PRIMARY KEY,
  nombre_categoria VARCHAR(100)
);

CREATE TABLE Producto_Final (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  id_categoria_producto INT,
  nombre_platillo VARCHAR(255),
  descripcion VARCHAR(255),
  precio_publico DECIMAL(10,2),
  disponible BOOLEAN,
  tamano VARCHAR(50),
  CHECK (precio_publico >= 0),
  CHECK (tamano IN ('Personal','Mediana','Grande','Familiar','Individual')),
  FOREIGN KEY (id_categoria_producto) REFERENCES Categoria_Producto(id_categoria_producto)
);

CREATE TABLE Receta_BOM (
  id_receta INT AUTO_INCREMENT PRIMARY KEY,
  id_producto_final INT,
  id_insumo INT,
  cantidad_exacta_gastada DECIMAL(10,4),
  unidad_medida VARCHAR(20),
  merma_esperada_porcentaje DECIMAL(5,2),
  CHECK (cantidad_exacta_gastada >= 0),
  CHECK (merma_esperada_porcentaje >= 0 AND merma_esperada_porcentaje <= 100),
  UNIQUE (id_producto_final, id_insumo),
  FOREIGN KEY (id_producto_final) REFERENCES Producto_Final(id_producto),
  FOREIGN KEY (id_insumo) REFERENCES Insumo(id_insumo)
);

CREATE TABLE Vehiculo_Entrega (
  id_vehiculo INT AUTO_INCREMENT PRIMARY KEY,
  placas VARCHAR(20) UNIQUE,
  marca VARCHAR(100),
  modelo VARCHAR(100),
  anio_modelo SMALLINT,
  capacidad_carga_kg DECIMAL(12,2),
  estatus_mecanico VARCHAR(50),
  fecha_ultimo_servicio DATE,
  kilometraje_actual INT,
  CHECK (anio_modelo >= 1990),
  CHECK (capacidad_carga_kg >= 0),
  CHECK (kilometraje_actual >= 0),
  CHECK (estatus_mecanico IN ('Operativo','En taller','Baja'))
);

CREATE TABLE Envio_Logistico (
  id_envio INT AUTO_INCREMENT PRIMARY KEY,
  id_vehiculo INT,
  id_sucursal_origen INT,
  id_sucursal_destino INT,
  id_empleado_chofer INT,
  fecha_salida TIMESTAMP,
  fecha_llegada_estimada TIMESTAMP,
  fecha_llegada_real TIMESTAMP,
  estatus_envio VARCHAR(50),
  observaciones VARCHAR(255),
  CHECK (estatus_envio IN ('Programado','En transito','Entregado','Cancelado')),
  FOREIGN KEY (id_vehiculo) REFERENCES Vehiculo_Entrega(id_vehiculo),
  FOREIGN KEY (id_sucursal_origen) REFERENCES Sucursal(id_sucursal),
  FOREIGN KEY (id_sucursal_destino) REFERENCES Sucursal(id_sucursal),
  FOREIGN KEY (id_empleado_chofer) REFERENCES Empleado(id_empleado)
);

CREATE TABLE Envio_Detalle (
  id_envio_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_envio INT,
  id_insumo INT,
  cantidad_enviada DECIMAL(12,4),
  cantidad_recibida DECIMAL(12,4),
  CHECK (cantidad_enviada >= 0),
  CHECK (cantidad_recibida >= 0),
  FOREIGN KEY (id_envio) REFERENCES Envio_Logistico(id_envio),
  FOREIGN KEY (id_insumo) REFERENCES Insumo(id_insumo)
);

CREATE TABLE Cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre_usuario VARCHAR(100),
  telefono VARCHAR(20) UNIQUE,
  correo VARCHAR(255) UNIQUE,
  fecha_registro DATE,
  canal_adquisicion VARCHAR(50),
  CHECK (canal_adquisicion IN ('App','Mostrador','Telefono','Tercero'))
);

CREATE TABLE Direccion_Entrega (
  id_direccion INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT,
  calle_numero VARCHAR(255),
  colonia VARCHAR(100),
  municipio VARCHAR(100),
  codigo_postal VARCHAR(10),
  referencias VARCHAR(255),
  es_principal BOOLEAN,
  FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE Ticket (
  id_venta INT AUTO_INCREMENT PRIMARY KEY,
  id_sucursal INT,
  id_cliente INT,
  id_direccion_entrega INT,
  id_turno INT,
  id_tasa INT,
  fecha_hora TIMESTAMP,
  tipo_orden VARCHAR(50),
  metodo_pago VARCHAR(50),
  subtotal DECIMAL(12,2),
  descuento_aplicado DECIMAL(12,2),
  iva_monto DECIMAL(12,2),
  total_venta DECIMAL(12,2),
  estatus_ticket VARCHAR(50),
  CHECK (subtotal >= 0),
  CHECK (descuento_aplicado >= 0),
  CHECK (iva_monto >= 0),
  CHECK (total_venta >= 0),
  CHECK (tipo_orden IN ('Local','Para llevar','Domicilio')),
  CHECK (metodo_pago IN ('Efectivo','Tarjeta','App','Voucher')),
  CHECK (estatus_ticket IN ('Pagado','Cancelado','Reembolsado')),
  FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
  FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
  FOREIGN KEY (id_direccion_entrega) REFERENCES Direccion_Entrega(id_direccion),
  FOREIGN KEY (id_turno) REFERENCES Turno_Laboral(id_turno),
  FOREIGN KEY (id_tasa) REFERENCES Tasa_IVA_Catalogo(id_tasa)
);

CREATE TABLE Ticket_Detalle (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_venta INT,
  id_producto INT,
  cantidad_vendida SMALLINT,
  precio_aplicado DECIMAL(10,2),
  descuento_linea DECIMAL(10,2),
  subtotal_linea DECIMAL(10,2),
  CHECK (cantidad_vendida > 0),
  CHECK (precio_aplicado >= 0),
  CHECK (descuento_linea >= 0),
  CHECK (subtotal_linea >= 0),
  FOREIGN KEY (id_venta) REFERENCES Ticket(id_venta),
  FOREIGN KEY (id_producto) REFERENCES Producto_Final(id_producto)
);

CREATE TABLE Promocion (
  id_promo INT AUTO_INCREMENT PRIMARY KEY,
  nombre_campana VARCHAR(255),
  descripcion VARCHAR(255),
  tipo_descuento VARCHAR(50),
  valor_descuento DECIMAL(10,2),
  fecha_inicio DATE,
  fecha_fin DATE,
  activa BOOLEAN,
  canal_aplicable VARCHAR(50),
  CHECK (valor_descuento >= 0),
  CHECK (tipo_descuento IN ('Porcentaje','Monto fijo','2x1','Regalo')),
  CHECK (canal_aplicable IN ('App','Mostrador','Todos'))
);

CREATE TABLE Promocion_Producto (
  id_promo_producto INT AUTO_INCREMENT PRIMARY KEY,
  id_promo INT,
  id_producto INT,
  incremento_demanda_pct DECIMAL(5,2),
  CHECK (incremento_demanda_pct >= 0),
  UNIQUE (id_promo, id_producto),
  FOREIGN KEY (id_promo) REFERENCES Promocion(id_promo),
  FOREIGN KEY (id_producto) REFERENCES Producto_Final(id_producto)
);

CREATE TABLE Periodo_Financiero (
  id_periodo INT AUTO_INCREMENT PRIMARY KEY,
  año SMALLINT,
  mes SMALLINT,
  fecha_inicio DATE,
  fecha_cierre DATE,
  cerrado BOOLEAN,
  CHECK (mes >= 1 AND mes <= 12),
  UNIQUE (año, mes)
);

CREATE TABLE Partida_Costo (
  id_partida INT AUTO_INCREMENT PRIMARY KEY,
  nombre_partida VARCHAR(100),
  tipo VARCHAR(50),
  descripcion VARCHAR(255),
  CHECK (tipo IN ('Fijo','Variable'))
);

CREATE TABLE Costo_Sucursal (
  id_costo INT AUTO_INCREMENT PRIMARY KEY,
  id_sucursal INT,
  id_periodo INT,
  id_partida INT,
  monto DECIMAL(12,2),
  observaciones VARCHAR(255),
  CHECK (monto >= 0),
  UNIQUE (id_sucursal, id_periodo, id_partida),
  FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
  FOREIGN KEY (id_periodo) REFERENCES Periodo_Financiero(id_periodo),
  FOREIGN KEY (id_partida) REFERENCES Partida_Costo(id_partida)
);

CREATE TABLE Ingreso_Sucursal (
  id_ingreso INT AUTO_INCREMENT PRIMARY KEY,
  id_sucursal INT,
  id_periodo INT,
  total_ventas DECIMAL(14,2),
  caja_apertura DECIMAL(12,2),
  caja_cierre DECIMAL(12,2),
  nivel_demanda VARCHAR(50),
  valor_inventario_inicial DECIMAL(12,2),
  valor_inventario_final DECIMAL(12,2),
  CHECK (total_ventas >= 0),
  CHECK (caja_apertura >= 0),
  CHECK (caja_cierre >= 0),
  CHECK (nivel_demanda IN ('Bajo','Normal','Alto','Pico')),
  CHECK (valor_inventario_inicial >= 0),
  CHECK (valor_inventario_final >= 0),
  UNIQUE (id_sucursal, id_periodo),
  FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
  FOREIGN KEY (id_periodo) REFERENCES Periodo_Financiero(id_periodo)
);

CREATE TABLE Balance_Sucursal (
  id_balance INT AUTO_INCREMENT PRIMARY KEY,
  id_sucursal INT,
  id_periodo INT,
  total_ingresos DECIMAL(14,2),
  total_costos_fijos DECIMAL(14,2),
  total_costos_variables DECIMAL(14,2),
  total_costos DECIMAL(14,2),
  utilidad_bruta DECIMAL(14,2),
  punto_equilibrio DECIMAL(14,2),
  margen_operativo_pct DECIMAL(5,2),
  CHECK (total_ingresos >= 0),
  CHECK (total_costos_fijos >= 0),
  CHECK (total_costos_variables >= 0),
  CHECK (total_costos >= 0),
  CHECK (punto_equilibrio >= 0),
  UNIQUE (id_sucursal, id_periodo),
  FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
  FOREIGN KEY (id_periodo) REFERENCES Periodo_Financiero(id_periodo)
);

INSERT INTO Franquiciatario (nombre_fiscal, rfc, telefono_contacto, correo_corporativo, fecha_alta, activo) VALUES
('Carlos Mendoza Garcia','MEGC850214A1B','+528181234501','carlos.mendoza@gmail.com','2024-01-05',true),
('Ana Sofia Ramirez Lopez','RALA900628C2D','+528181234502','ana.ramirez@gmail.com','2024-01-08',true),
('Jorge Alberto Salinas Trevino','SATJ780912E3F','+528181234503','jorge.salinas@gmail.com','2024-01-10',true),
('Mariana Valdez Ortiz','VAOM920304G4H','+528181234504','mariana.valdez@gmail.com','2024-01-12',true),
('Ricardo Garza Villarreal','GAVR810719I5J','+528181234505','ricardo.garza@gmail.com','2024-01-15',true),
('Fernanda Castillo Ruiz','CARF950221K6L','+528181234506','fernanda.castillo@gmail.com','2024-01-18',true),
('Luis Enrique Davila Perez','DAPL870606M7N','+528181234507','luis.davila@gmail.com','2024-01-20',true),
('Paola Alejandra Torres Diaz','TODP930817O8P','+528181234508','paola.torres@gmail.com','2024-01-22',true),
('Miguel Angel Cantu Rojas','CARM840509Q9R','+528181234509','miguel.cantu@gmail.com','2024-01-25',true),
('Daniela Flores Morales','FOMD960113S1T','+528181234510','daniela.flores@gmail.com','2024-01-28',true),
('Oscar Eduardo Hernandez Soto','HESO790722U2V','+528181234511','oscar.hernandez@gmail.com','2024-02-01',true),
('Claudia Beatriz Aguilar Luna','AULC880331W3X','+528181234512','claudia.aguilar@gmail.com','2024-02-03',true),
('Roberto Navarro Jimenez','NAJR820915Y4Z','+528181234513','roberto.navarro@gmail.com','2024-02-05',true),
('Gabriela Ibarra Chavez','IACG910427A5C','+528181234514','gabriela.ibarra@gmail.com','2024-02-08',true),
('Hector Manuel Reyes Silva','RESH770219D6E','+528181234515','hector.reyes@gmail.com','2024-02-10',true),
('Patricia Escamilla Vega','EAVP940711F7G','+528181234516','patricia.escamilla@gmail.com','2024-02-12',true),
('Sergio Alejandro Molina Campos','MOCS860523H8I','+528181234517','sergio.molina@gmail.com','2024-02-15',true),
('Natalia Paredes Fuentes','PAFN970902J9K','+528181234518','natalia.paredes@gmail.com','2024-02-18',true),
('Adrian Lozano Herrera','LOHA830116L1M','+528181234519','adrian.lozano@gmail.com','2024-02-20',true),
('Valeria Robles Medina','ROMV980405N2O','+528181234520','valeria.robles@gmail.com','2024-02-23',true),
('Emilio Santos Cabrera','SACE800629P3Q','+528181234521','emilio.santos@gmail.com','2024-03-01',true),
('Monica Palacios Nunez','PANM890814R4S','+528181234522','monica.palacios@gmail.com','2024-03-03',true),
('Ivan Villarreal Acosta','VIAI850927T5U','+528181234523','ivan.villarreal@gmail.com','2024-03-05',true),
('Laura Estrada Martinez','EAML920118V6W','+528181234524','laura.estrada@gmail.com','2024-03-08',true),
('Rafael Ortega Sanchez','OASR760702X7Y','+528181234525','rafael.ortega@gmail.com','2024-03-10',true),
('Andrea Montemayor Nieto','MONA951211Z8A','+528181234526','andrea.montemayor@gmail.com','2024-03-12',true),
('David Barrera Franco','BAFD870324B9C','+528181234527','david.barrera@gmail.com','2024-03-15',true),
('Karla Benitez Solis','BESK990617D1E','+528181234528','karla.benitez@gmail.com','2024-03-18',true),
('Mauricio Pena Vargas','PEVM810830F2G','+528181234529','mauricio.pena@gmail.com','2024-03-20',true),
('Alejandra Cardenas Meza','CAMA930214H3I','+528181234530','alejandra.cardenas@gmail.com','2024-03-22',true),
('Fernando Leal Quintana','LEQF780926J4K','+528181234531','fernando.leal@gmail.com','2024-03-25',true),
('Isabel Rangel Castañeda','RACI901105L5M','+528181234532','isabel.rangel@gmail.com','2024-03-28',true),
('Guillermo Trejo Maldonado','TEMG840713N6O','+528181234533','guillermo.trejo@gmail.com','2024-04-01',true),
('Lucia Serrano Padilla','SEPL960229P7Q','+528181234534','lucia.serrano@gmail.com','2024-04-03',true),
('Eduardo Carrillo Aguirre','CAAE791219R8S','+528181234535','eduardo.carrillo@gmail.com','2024-04-05',true),
('Renata Guerra Robledo','GURR970508T9U','+528181234536','renata.guerra@gmail.com','2024-04-08',true),
('Alonso Rivas Esquivel','RIEA830621V1W','+528181234537','alonso.rivas@gmail.com','2024-04-10',true),
('Samantha Lugo Beltran','LUBS940903X2Y','+528181234538','samantha.lugo@gmail.com','2024-04-12',true),
('Nicolas Arellano Duarte','AEDN880416Z3A','+528181234539','nicolas.arellano@gmail.com','2024-04-15',true),
('Jimena Villar Moreno','VIMJ950727B4C','+528181234540','jimena.villar@gmail.com','2024-04-18',true);

INSERT INTO Tasa_IVA_Catalogo (descripcion, porcentaje, vigente_desde, vigente_hasta) VALUES
('IVA General',16.00,'2024-01-01',NULL),
('Zona Fronteriza 8%',8.00,'2024-01-01',NULL),
('IVA General Monterrey',16.00,'2024-01-01',NULL),
('IVA General San Pedro',16.00,'2024-01-01',NULL),
('IVA General Guadalupe',16.00,'2024-01-01',NULL),
('IVA General Apodaca',16.00,'2024-01-01',NULL),
('IVA General Escobedo',16.00,'2024-01-01',NULL),
('IVA General Santa Catarina',16.00,'2024-01-01',NULL),
('IVA General Garcia',16.00,'2024-01-01',NULL),
('IVA General Juarez NL',16.00,'2024-01-01',NULL),
('IVA General Saltillo',16.00,'2024-01-01',NULL),
('IVA General Torreon',16.00,'2024-01-01',NULL),
('IVA Frontera Reynosa',8.00,'2024-01-01',NULL),
('IVA Frontera Matamoros',8.00,'2024-01-01',NULL),
('IVA Frontera Nuevo Laredo',8.00,'2024-01-01',NULL),
('IVA Frontera Tijuana',8.00,'2024-01-01',NULL),
('IVA Frontera Mexicali',8.00,'2024-01-01',NULL),
('IVA General Queretaro',16.00,'2024-01-01',NULL),
('IVA General Puebla',16.00,'2024-01-01',NULL),
('IVA General Merida',16.00,'2024-01-01',NULL),
('IVA General Cancun',16.00,'2024-01-01',NULL),
('IVA General Hermosillo',16.00,'2024-01-01',NULL),
('IVA General Chihuahua',16.00,'2024-01-01',NULL),
('IVA General Durango',16.00,'2024-01-01',NULL),
('IVA General Zacatecas',16.00,'2024-01-01',NULL),
('IVA General Leon',16.00,'2024-01-01',NULL),
('IVA General Aguascalientes',16.00,'2024-01-01',NULL),
('IVA General San Luis Potosi',16.00,'2024-01-01',NULL),
('IVA General CDMX',16.00,'2024-01-01',NULL),
('IVA General Toluca',16.00,'2024-01-01',NULL),
('IVA General Cuernavaca',16.00,'2024-01-01',NULL),
('IVA General Veracruz',16.00,'2024-01-01',NULL),
('IVA General Xalapa',16.00,'2024-01-01',NULL),
('IVA General Oaxaca',16.00,'2024-01-01',NULL),
('IVA General Tuxtla',16.00,'2024-01-01',NULL),
('IVA General Villahermosa',16.00,'2024-01-01',NULL),
('IVA General Campeche',16.00,'2024-01-01',NULL),
('IVA General Morelia',16.00,'2024-01-01',NULL),
('IVA General Guadalajara',16.00,'2024-01-01',NULL),
('IVA Exento Convenio Escolar',0.00,'2024-01-01',NULL);

INSERT INTO Ubicacion (continente, pais, estado, municipio, codigo_postal, id_tasa) VALUES
('America','Mexico','Nuevo Leon','Monterrey','64000',1),
('America','Mexico','Nuevo Leon','San Pedro Garza Garcia','66220',1),
('America','Mexico','Nuevo Leon','Guadalupe','67100',1),
('America','Mexico','Nuevo Leon','Apodaca','66600',1),
('America','Mexico','Nuevo Leon','General Escobedo','66050',1),
('America','Mexico','Nuevo Leon','Santa Catarina','66350',1),
('America','Mexico','Nuevo Leon','Garcia','66000',1),
('America','Mexico','Nuevo Leon','Juarez','67250',1),
('America','Mexico','Nuevo Leon','San Nicolas de los Garza','66400',1),
('America','Mexico','Nuevo Leon','Santiago','67300',1),
('America','Mexico','Coahuila','Saltillo','25000',11),
('America','Mexico','Coahuila','Torreon','27000',12),
('America','Mexico','Tamaulipas','Reynosa','88700',13),
('America','Mexico','Tamaulipas','Matamoros','87300',14),
('America','Mexico','Tamaulipas','Nuevo Laredo','88000',15),
('America','Mexico','Baja California','Tijuana','22000',16),
('America','Mexico','Baja California','Mexicali','21000',17),
('America','Mexico','Queretaro','Queretaro','76000',18),
('America','Mexico','Puebla','Puebla','72000',19),
('America','Mexico','Yucatan','Merida','97000',20),
('America','Mexico','Quintana Roo','Cancun','77500',21),
('America','Mexico','Sonora','Hermosillo','83000',22),
('America','Mexico','Chihuahua','Chihuahua','31000',23),
('America','Mexico','Durango','Durango','34000',24),
('America','Mexico','Zacatecas','Zacatecas','98000',25),
('America','Mexico','Guanajuato','Leon','37000',26),
('America','Mexico','Aguascalientes','Aguascalientes','20000',27),
('America','Mexico','San Luis Potosi','San Luis Potosi','78000',28),
('America','Mexico','Ciudad de Mexico','Cuauhtemoc','06000',29),
('America','Mexico','Estado de Mexico','Toluca','50000',30),
('America','Mexico','Morelos','Cuernavaca','62000',31),
('America','Mexico','Veracruz','Veracruz','91700',32),
('America','Mexico','Veracruz','Xalapa','91000',33),
('America','Mexico','Oaxaca','Oaxaca de Juarez','68000',34),
('America','Mexico','Chiapas','Tuxtla Gutierrez','29000',35),
('America','Mexico','Tabasco','Villahermosa','86000',36),
('America','Mexico','Campeche','Campeche','24000',37),
('America','Mexico','Michoacan','Morelia','58000',38),
('America','Mexico','Jalisco','Guadalajara','44100',39),
('America','Mexico','Nuevo Leon','Monterrey','64650',1);

INSERT INTO Sucursal (id_franquiciatario, id_ubicacion, nombre_tienda, direccion_exacta, telefono_sucursal, presupuesto_mensual, fecha_apertura, estatus) VALUES
(1,1,'Pizza Centro Monterrey','Av. Juarez 120, Centro','+528183450001',185000.00,'2024-02-01','Activa'),
(2,2,'Pizza San Pedro Valle','Calzada del Valle 455, Del Valle','+528183450002',245000.00,'2024-02-03','Activa'),
(3,3,'Pizza Guadalupe Linda Vista','Av. Miguel Aleman 890, Linda Vista','+528183450003',175000.00,'2024-02-05','Activa'),
(4,4,'Pizza Apodaca Centro','Av. Concordia 301, Centro','+528183450004',160000.00,'2024-02-07','Activa'),
(5,5,'Pizza Escobedo Sendero','Av. Sendero 1500, Valle del Canada','+528183450005',170000.00,'2024-02-09','Activa'),
(6,6,'Pizza Santa Catarina','Manuel Ordoñez 210, Centro','+528183450006',155000.00,'2024-02-11','Activa'),
(7,7,'Pizza Garcia Cumbres','Av. Heberto Castillo 722, Cumbres Madeira','+528183450007',165000.00,'2024-02-13','Activa'),
(8,8,'Pizza Juarez NL','Av. Arturo B. de la Garza 400, Centro','+528183450008',150000.00,'2024-02-15','Activa'),
(9,9,'Pizza San Nicolas Universidad','Av. Universidad 980, Anahuac','+528183450009',190000.00,'2024-02-17','Activa'),
(10,10,'Pizza Santiago Pueblo Magico','Carretera Nacional 1205, El Cercado','+528183450010',145000.00,'2024-02-19','Activa'),
(11,11,'Pizza Saltillo Centro','Blvd. Venustiano Carranza 410, Centro','+528183450011',175000.00,'2024-02-21','Activa'),
(12,12,'Pizza Torreon Independencia','Blvd. Independencia 990, Navarro','+528183450012',180000.00,'2024-02-23','Activa'),
(13,13,'Pizza Reynosa Hidalgo','Blvd. Hidalgo 850, Las Fuentes','+528183450013',168000.00,'2024-02-25','Activa'),
(14,14,'Pizza Matamoros Centro','Calle Sexta 230, Centro','+528183450014',158000.00,'2024-02-27','Activa'),
(15,15,'Pizza Nuevo Laredo Reforma','Av. Reforma 1400, Jardín','+528183450015',162000.00,'2024-03-01','Activa'),
(16,16,'Pizza Tijuana Rio','Paseo de los Heroes 1010, Zona Rio','+528183450016',210000.00,'2024-03-03','Activa'),
(17,17,'Pizza Mexicali Centro','Calzada Independencia 501, Centro Civico','+528183450017',195000.00,'2024-03-05','Activa'),
(18,18,'Pizza Queretaro Centro Sur','Bernardo Quintana 620, Centro Sur','+528183450018',205000.00,'2024-03-07','Activa'),
(19,19,'Pizza Puebla Angelopolis','Via Atlixcayotl 1501, Angelopolis','+528183450019',215000.00,'2024-03-09','Activa'),
(20,20,'Pizza Merida Montejo','Paseo de Montejo 485, Centro','+528183450020',198000.00,'2024-03-11','Activa'),
(21,21,'Pizza Cancun Nichupte','Av. Nichupte 220, Supermanzana 20','+528183450021',225000.00,'2024-03-13','Activa'),
(22,22,'Pizza Hermosillo Kino','Blvd. Kino 780, Pitic','+528183450022',185000.00,'2024-03-15','Activa'),
(23,23,'Pizza Chihuahua Centro','Av. Universidad 330, Centro','+528183450023',178000.00,'2024-03-17','Activa'),
(24,24,'Pizza Durango Guadiana','Blvd. Guadiana 510, Los Remedios','+528183450024',158000.00,'2024-03-19','Activa'),
(25,25,'Pizza Zacatecas Centro','Av. Hidalgo 215, Centro Historico','+528183450025',148000.00,'2024-03-21','Activa'),
(26,26,'Pizza Leon Campestre','Blvd. Adolfo Lopez Mateos 1700, Campestre','+528183450026',205000.00,'2024-03-23','Activa'),
(27,27,'Pizza Aguascalientes Centro','Av. Madero 301, Zona Centro','+528183450027',176000.00,'2024-03-25','Activa'),
(28,28,'Pizza San Luis Carranza','Av. Venustiano Carranza 1120, Tequis','+528183450028',188000.00,'2024-03-27','Activa'),
(29,29,'Pizza Roma Norte CDMX','Calle Orizaba 95, Roma Norte','+528183450029',260000.00,'2024-03-29','Activa'),
(30,30,'Pizza Toluca Centro','Av. Morelos 440, Centro','+528183450030',172000.00,'2024-04-01','Activa'),
(31,31,'Pizza Cuernavaca Vista Hermosa','Rio Mayo 900, Vista Hermosa','+528183450031',182000.00,'2024-04-03','Activa'),
(32,32,'Pizza Veracruz Boca','Blvd. Manuel Avila Camacho 1320, Costa de Oro','+528183450032',202000.00,'2024-04-05','Activa'),
(33,33,'Pizza Xalapa Americas','Av. Americas 610, Jardines de Virginia','+528183450033',165000.00,'2024-04-07','Activa'),
(34,34,'Pizza Oaxaca Centro','Calle Macedonio Alcala 210, Centro','+528183450034',155000.00,'2024-04-09','Activa'),
(35,35,'Pizza Tuxtla Marimba','Av. Central 780, Centro','+528183450035',158000.00,'2024-04-11','Activa'),
(36,36,'Pizza Villahermosa Tabasco 2000','Paseo Tabasco 1402, Tabasco 2000','+528183450036',187000.00,'2024-04-13','Activa'),
(37,37,'Pizza Campeche Malecon','Av. Resurgimiento 300, San Francisco','+528183450037',152000.00,'2024-04-15','Activa'),
(38,38,'Pizza Morelia Camelinas','Av. Camelinas 2100, Felix Ireta','+528183450038',178000.00,'2024-04-17','Activa'),
(39,39,'Pizza Guadalajara Chapultepec','Av. Chapultepec Sur 350, Americana','+528183450039',230000.00,'2024-04-19','Activa'),
(40,40,'Pizza Cumbres Monterrey','Av. Paseo de los Leones 2500, Cumbres','+528183450040',215000.00,'2024-04-21','Activa');

INSERT INTO Puesto (nombre_puesto, departamento, salario_base_diario, comisiones_activas) VALUES
('Pizzero','Operaciones',420.00,false),
('Auxiliar de Cocina','Operaciones',360.00,false),
('Cajero','Operaciones',380.00,true),
('Repartidor','Logistica',350.00,true),
('Gerente de Sucursal','Administracion',720.00,true),
('Subgerente','Administracion',580.00,true),
('Encargado de Turno','Operaciones',500.00,true),
('Limpieza','Operaciones',330.00,false),
('Almacenista','Logistica',390.00,false),
('Chofer CEDIS','Logistica',520.00,true),
('Supervisor Regional','Administracion',950.00,true),
('Auxiliar Administrativo','Administracion',430.00,false),
('Comprador','Administracion',610.00,true),
('Analista de Inventario','Logistica',560.00,false),
('Tecnico de Mantenimiento','Operaciones',540.00,false),
('Atencion a Cliente','Operaciones',370.00,true),
('Coordinador de Marketing','Administracion',680.00,true),
('Community Manager','Administracion',520.00,false),
('Capacitador','Administracion',650.00,false),
('Auditor Operativo','Administracion',740.00,false),
('Lavaloza','Operaciones',320.00,false),
('Preparador de Masa','Operaciones',390.00,false),
('Parrillero','Operaciones',410.00,false),
('Empacador','Operaciones',340.00,false),
('Host de Mostrador','Operaciones',365.00,true),
('Monitor de Pedidos App','Operaciones',400.00,true),
('Planeador de Rutas','Logistica',575.00,false),
('Coordinador CEDIS','Logistica',760.00,true),
('Auxiliar de Reparto','Logistica',345.00,true),
('Jefe de Cocina','Operaciones',620.00,true),
('Jefe de Caja','Operaciones',560.00,true),
('Control de Calidad','Operaciones',530.00,false),
('Reclutador','Administracion',600.00,false),
('Nominas','Administracion',610.00,false),
('Contador Operativo','Administracion',700.00,false),
('Analista Financiero','Administracion',780.00,false),
('Diseñador Grafico','Administracion',560.00,false),
('Promotor de Ventas','Marketing',390.00,true),
('Encargado de Proveedores','Administracion',630.00,true),
('Director Operativo','Administracion',1400.00,true);

INSERT INTO Empleado (id_sucursal, id_puesto, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, fecha_ingreso, fecha_baja, estatus) VALUES
(1,1,'Mateo','Sanchez','Luna','1996-04-12','2024-02-01',NULL,'Activo'),
(2,2,'Camila','Rios','Mendez','1998-07-25','2024-02-03',NULL,'Activo'),
(3,3,'Diego','Morales','Garcia','1994-11-08','2024-02-05',NULL,'Activo'),
(4,4,'Valentina','Cruz','Herrera','1999-01-19','2024-02-07',NULL,'Activo'),
(5,5,'Sebastian','Lopez','Cardenas','1990-05-30','2024-02-09',NULL,'Activo'),
(6,6,'Regina','Vargas','Salazar','1993-09-14','2024-02-11',NULL,'Activo'),
(7,7,'Emiliano','Torres','Pineda','1997-12-02','2024-02-13',NULL,'Activo'),
(8,8,'Sofia','Nuñez','Farias','2000-03-21','2024-02-15',NULL,'Activo'),
(9,9,'Leonardo','Ortega','Castillo','1995-06-18','2024-02-17',NULL,'Activo'),
(10,10,'Ximena','Aguilar','Santos','1992-10-05','2024-02-19',NULL,'Activo'),
(11,11,'Daniel','Campos','Navarro','1988-02-27','2024-02-21',NULL,'Activo'),
(12,12,'Renata','Molina','Delgado','1996-08-11','2024-02-23',NULL,'Activo'),
(13,13,'Gael','Jimenez','Aguirre','1991-04-04','2024-02-25',NULL,'Activo'),
(14,14,'Luciana','Paz','Robledo','1997-09-28','2024-02-27',NULL,'Activo'),
(15,15,'Santiago','Reyes','Fuentes','1989-12-16','2024-03-01',NULL,'Activo'),
(16,16,'Mariana','Silva','Ibarra','1998-06-07','2024-03-03',NULL,'Activo'),
(17,17,'Rodrigo','Castro','Valdez','1993-01-23','2024-03-05',NULL,'Activo'),
(18,18,'Isabella','Gomez','Trejo','1999-05-09','2024-03-07',NULL,'Activo'),
(19,19,'Andres','Flores','Quiroz','1987-07-31','2024-03-09',NULL,'Activo'),
(20,20,'Victoria','Herrera','Montoya','1994-03-17','2024-03-11',NULL,'Activo'),
(21,21,'Nicolas','Medina','Serrano','2001-02-06','2024-03-13',NULL,'Activo'),
(22,22,'Carolina','Dominguez','Vega','1996-11-20','2024-03-15',NULL,'Activo'),
(23,23,'Javier','Rangel','Acosta','1990-08-02','2024-03-17',NULL,'Activo'),
(24,24,'Natalia','Peña','Maldonado','1997-04-26','2024-03-19',NULL,'Activo'),
(25,25,'Pablo','Estrada','Benitez','1995-10-13','2024-03-21',NULL,'Activo'),
(26,26,'Aitana','Cabrera','Rivas','2000-12-29','2024-03-23',NULL,'Activo'),
(27,27,'Bruno','Villarreal','Escamilla','1992-05-15','2024-03-25',NULL,'Activo'),
(28,28,'Fernanda','Soto','Palacios','1998-09-03','2024-03-27',NULL,'Activo'),
(29,29,'Alan','Guerrero','Leal','1991-01-11','2024-03-29',NULL,'Activo'),
(30,30,'Mia','Cervantes','Barrera','1999-07-22','2024-04-01',NULL,'Activo'),
(31,31,'Iker','Franco','Padilla','1993-06-01','2024-04-03',NULL,'Activo'),
(32,32,'Paula','Duarte','Beltran','1996-02-18','2024-04-05',NULL,'Activo'),
(33,33,'Hugo','Serrano','Meza','1989-09-07','2024-04-07',NULL,'Activo'),
(34,34,'Elena','Arias','Quintana','1994-12-24','2024-04-09',NULL,'Activo'),
(35,35,'Dario','Lugo','Castañeda','1990-03-05','2024-04-11',NULL,'Activo'),
(36,36,'Clara','Montes','Arenas','1997-08-27','2024-04-13',NULL,'Activo'),
(37,37,'Tomas','Arellano','Noriega','1995-11-12','2024-04-15',NULL,'Activo'),
(38,38,'Julia','Vega','Solano','1998-01-30','2024-04-17',NULL,'Activo'),
(39,39,'Marco','Carrillo','Esquivel','1992-04-20','2024-04-19',NULL,'Activo'),
(40,40,'Alexa','Mendoza','Paredes','1986-10-09','2024-04-21',NULL,'Activo');

INSERT INTO Documentacion_Empleado (id_empleado, curp, nss, link_ine, link_acta_nacimiento, link_comprobante_domicilio, link_curriculum, correo_personal, fecha_vencimiento_ine) VALUES
(1,'SALM960412HNLSNT01','10000000001','https://docs.empresa.mx/ine/mateo_sanchez.pdf','https://docs.empresa.mx/actas/mateo_sanchez.pdf','https://docs.empresa.mx/domicilio/mateo_sanchez.pdf','https://docs.empresa.mx/cv/mateo_sanchez.pdf','mateo.sanchez@gmail.com','2030-04-12'),
(2,'RIMC980725MNLSND02','10000000002','https://docs.empresa.mx/ine/camila_rios.pdf','https://docs.empresa.mx/actas/camila_rios.pdf','https://docs.empresa.mx/domicilio/camila_rios.pdf','https://docs.empresa.mx/cv/camila_rios.pdf','camila.rios@gmail.com','2030-07-25'),
(3,'MOGD941108HNLRRG03','10000000003','https://docs.empresa.mx/ine/diego_morales.pdf','https://docs.empresa.mx/actas/diego_morales.pdf','https://docs.empresa.mx/domicilio/diego_morales.pdf','https://docs.empresa.mx/cv/diego_morales.pdf','diego.morales@gmail.com','2029-11-08'),
(4,'CUHV990119MNLRSR04','10000000004','https://docs.empresa.mx/ine/valentina_cruz.pdf','https://docs.empresa.mx/actas/valentina_cruz.pdf','https://docs.empresa.mx/domicilio/valentina_cruz.pdf','https://docs.empresa.mx/cv/valentina_cruz.pdf','valentina.cruz@gmail.com','2031-01-19'),
(5,'LOCS900530HNLPRB05','10000000005','https://docs.empresa.mx/ine/sebastian_lopez.pdf','https://docs.empresa.mx/actas/sebastian_lopez.pdf','https://docs.empresa.mx/domicilio/sebastian_lopez.pdf','https://docs.empresa.mx/cv/sebastian_lopez.pdf','sebastian.lopez@gmail.com','2028-05-30'),
(6,'VASR930914MNLLRG06','10000000006','https://docs.empresa.mx/ine/regina_vargas.pdf','https://docs.empresa.mx/actas/regina_vargas.pdf','https://docs.empresa.mx/domicilio/regina_vargas.pdf','https://docs.empresa.mx/cv/regina_vargas.pdf','regina.vargas@gmail.com','2029-09-14'),
(7,'TOPE971202HNLRSN07','10000000007','https://docs.empresa.mx/ine/emiliano_torres.pdf','https://docs.empresa.mx/actas/emiliano_torres.pdf','https://docs.empresa.mx/domicilio/emiliano_torres.pdf','https://docs.empresa.mx/cv/emiliano_torres.pdf','emiliano.torres@gmail.com','2031-12-02'),
(8,'NUFS000321MNLFRA08','10000000008','https://docs.empresa.mx/ine/sofia_nunez.pdf','https://docs.empresa.mx/actas/sofia_nunez.pdf','https://docs.empresa.mx/domicilio/sofia_nunez.pdf','https://docs.empresa.mx/cv/sofia_nunez.pdf','sofia.nunez@gmail.com','2032-03-21'),
(9,'OOCL950618HNLRSN09','10000000009','https://docs.empresa.mx/ine/leonardo_ortega.pdf','https://docs.empresa.mx/actas/leonardo_ortega.pdf','https://docs.empresa.mx/domicilio/leonardo_ortega.pdf','https://docs.empresa.mx/cv/leonardo_ortega.pdf','leonardo.ortega@gmail.com','2030-06-18'),
(10,'AUSX921005MNLGSN10','10000000010','https://docs.empresa.mx/ine/ximena_aguilar.pdf','https://docs.empresa.mx/actas/ximena_aguilar.pdf','https://docs.empresa.mx/domicilio/ximena_aguilar.pdf','https://docs.empresa.mx/cv/ximena_aguilar.pdf','ximena.aguilar@gmail.com','2028-10-05'),
(11,'CANB880227HNLVVR11','10000000011','https://docs.empresa.mx/ine/daniel_campos.pdf','https://docs.empresa.mx/actas/daniel_campos.pdf','https://docs.empresa.mx/domicilio/daniel_campos.pdf','https://docs.empresa.mx/cv/daniel_campos.pdf','daniel.campos@gmail.com','2029-02-27'),
(12,'MODR960811MNLLLN12','10000000012','https://docs.empresa.mx/ine/renata_molina.pdf','https://docs.empresa.mx/actas/renata_molina.pdf','https://docs.empresa.mx/domicilio/renata_molina.pdf','https://docs.empresa.mx/cv/renata_molina.pdf','renata.molina@gmail.com','2030-08-11'),
(13,'JIAA910404HNLGGR13','10000000013','https://docs.empresa.mx/ine/gael_jimenez.pdf','https://docs.empresa.mx/actas/gael_jimenez.pdf','https://docs.empresa.mx/domicilio/gael_jimenez.pdf','https://docs.empresa.mx/cv/gael_jimenez.pdf','gael.jimenez@gmail.com','2029-04-04'),
(14,'PARL970928MNLBBC14','10000000014','https://docs.empresa.mx/ine/luciana_paz.pdf','https://docs.empresa.mx/actas/luciana_paz.pdf','https://docs.empresa.mx/domicilio/luciana_paz.pdf','https://docs.empresa.mx/cv/luciana_paz.pdf','luciana.paz@gmail.com','2031-09-28'),
(15,'REFS891216HNLVVN15','10000000015','https://docs.empresa.mx/ine/santiago_reyes.pdf','https://docs.empresa.mx/actas/santiago_reyes.pdf','https://docs.empresa.mx/domicilio/santiago_reyes.pdf','https://docs.empresa.mx/cv/santiago_reyes.pdf','santiago.reyes@gmail.com','2028-12-16'),
(16,'SIIM980607MNLRBR16','10000000016','https://docs.empresa.mx/ine/mariana_silva.pdf','https://docs.empresa.mx/actas/mariana_silva.pdf','https://docs.empresa.mx/domicilio/mariana_silva.pdf','https://docs.empresa.mx/cv/mariana_silva.pdf','mariana.silva@gmail.com','2030-06-07'),
(17,'CAVR930123HNLLLD17','10000000017','https://docs.empresa.mx/ine/rodrigo_castro.pdf','https://docs.empresa.mx/actas/rodrigo_castro.pdf','https://docs.empresa.mx/domicilio/rodrigo_castro.pdf','https://docs.empresa.mx/cv/rodrigo_castro.pdf','rodrigo.castro@gmail.com','2029-01-23'),
(18,'GOTI990509MNLMMR18','10000000018','https://docs.empresa.mx/ine/isabella_gomez.pdf','https://docs.empresa.mx/actas/isabella_gomez.pdf','https://docs.empresa.mx/domicilio/isabella_gomez.pdf','https://docs.empresa.mx/cv/isabella_gomez.pdf','isabella.gomez@gmail.com','2031-05-09'),
(19,'FOQA870731HNLRRN19','10000000019','https://docs.empresa.mx/ine/andres_flores.pdf','https://docs.empresa.mx/actas/andres_flores.pdf','https://docs.empresa.mx/domicilio/andres_flores.pdf','https://docs.empresa.mx/cv/andres_flores.pdf','andres.flores@gmail.com','2028-07-31'),
(20,'HEMV940317MNLRNC20','10000000020','https://docs.empresa.mx/ine/victoria_herrera.pdf','https://docs.empresa.mx/actas/victoria_herrera.pdf','https://docs.empresa.mx/domicilio/victoria_herrera.pdf','https://docs.empresa.mx/cv/victoria_herrera.pdf','victoria.herrera@gmail.com','2030-03-17'),
(21,'MESN010206HNLDCR21','10000000021','https://docs.empresa.mx/ine/nicolas_medina.pdf','https://docs.empresa.mx/actas/nicolas_medina.pdf','https://docs.empresa.mx/domicilio/nicolas_medina.pdf','https://docs.empresa.mx/cv/nicolas_medina.pdf','nicolas.medina@gmail.com','2032-02-06'),
(22,'DOVC961120MNLMRG22','10000000022','https://docs.empresa.mx/ine/carolina_dominguez.pdf','https://docs.empresa.mx/actas/carolina_dominguez.pdf','https://docs.empresa.mx/domicilio/carolina_dominguez.pdf','https://docs.empresa.mx/cv/carolina_dominguez.pdf','carolina.dominguez@gmail.com','2030-11-20'),
(23,'RAAJ900802HNLNGV23','10000000023','https://docs.empresa.mx/ine/javier_rangel.pdf','https://docs.empresa.mx/actas/javier_rangel.pdf','https://docs.empresa.mx/domicilio/javier_rangel.pdf','https://docs.empresa.mx/cv/javier_rangel.pdf','javier.rangel@gmail.com','2029-08-02'),
(24,'PEMN970426MNLLLD24','10000000024','https://docs.empresa.mx/ine/natalia_pena.pdf','https://docs.empresa.mx/actas/natalia_pena.pdf','https://docs.empresa.mx/domicilio/natalia_pena.pdf','https://docs.empresa.mx/cv/natalia_pena.pdf','natalia.pena@gmail.com','2031-04-26'),
(25,'EABP951013HNLSNL25','10000000025','https://docs.empresa.mx/ine/pablo_estrada.pdf','https://docs.empresa.mx/actas/pablo_estrada.pdf','https://docs.empresa.mx/domicilio/pablo_estrada.pdf','https://docs.empresa.mx/cv/pablo_estrada.pdf','pablo.estrada@gmail.com','2030-10-13'),
(26,'CARA001229MNLBBB26','10000000026','https://docs.empresa.mx/ine/aitana_cabrera.pdf','https://docs.empresa.mx/actas/aitana_cabrera.pdf','https://docs.empresa.mx/domicilio/aitana_cabrera.pdf','https://docs.empresa.mx/cv/aitana_cabrera.pdf','aitana.cabrera@gmail.com','2032-12-29'),
(27,'VIEB920515HNLSCN27','10000000027','https://docs.empresa.mx/ine/bruno_villarreal.pdf','https://docs.empresa.mx/actas/bruno_villarreal.pdf','https://docs.empresa.mx/domicilio/bruno_villarreal.pdf','https://docs.empresa.mx/cv/bruno_villarreal.pdf','bruno.villarreal@gmail.com','2029-05-15'),
(28,'SOPF980903MNLLLR28','10000000028','https://docs.empresa.mx/ine/fernanda_soto.pdf','https://docs.empresa.mx/actas/fernanda_soto.pdf','https://docs.empresa.mx/domicilio/fernanda_soto.pdf','https://docs.empresa.mx/cv/fernanda_soto.pdf','fernanda.soto@gmail.com','2030-09-03'),
(29,'GULA910111HNLRRL29','10000000029','https://docs.empresa.mx/ine/alan_guerrero.pdf','https://docs.empresa.mx/actas/alan_guerrero.pdf','https://docs.empresa.mx/domicilio/alan_guerrero.pdf','https://docs.empresa.mx/cv/alan_guerrero.pdf','alan.guerrero@gmail.com','2029-01-11'),
(30,'CEBM990722MNLVRR30','10000000030','https://docs.empresa.mx/ine/mia_cervantes.pdf','https://docs.empresa.mx/actas/mia_cervantes.pdf','https://docs.empresa.mx/domicilio/mia_cervantes.pdf','https://docs.empresa.mx/cv/mia_cervantes.pdf','mia.cervantes@gmail.com','2031-07-22'),
(31,'FAPI930601HNLRDK31','10000000031','https://docs.empresa.mx/ine/iker_franco.pdf','https://docs.empresa.mx/actas/iker_franco.pdf','https://docs.empresa.mx/domicilio/iker_franco.pdf','https://docs.empresa.mx/cv/iker_franco.pdf','iker.franco@gmail.com','2029-06-01'),
(32,'DUBP960218MNLRRL32','10000000032','https://docs.empresa.mx/ine/paula_duarte.pdf','https://docs.empresa.mx/actas/paula_duarte.pdf','https://docs.empresa.mx/domicilio/paula_duarte.pdf','https://docs.empresa.mx/cv/paula_duarte.pdf','paula.duarte@gmail.com','2030-02-18'),
(33,'SEMH890907HNLZRG33','10000000033','https://docs.empresa.mx/ine/hugo_serrano.pdf','https://docs.empresa.mx/actas/hugo_serrano.pdf','https://docs.empresa.mx/domicilio/hugo_serrano.pdf','https://docs.empresa.mx/cv/hugo_serrano.pdf','hugo.serrano@gmail.com','2028-09-07'),
(34,'AIQE941224MNLRSR34','10000000034','https://docs.empresa.mx/ine/elena_arias.pdf','https://docs.empresa.mx/actas/elena_arias.pdf','https://docs.empresa.mx/domicilio/elena_arias.pdf','https://docs.empresa.mx/cv/elena_arias.pdf','elena.arias@gmail.com','2030-12-24'),
(35,'LUCD900305HNLGRR35','10000000035','https://docs.empresa.mx/ine/dario_lugo.pdf','https://docs.empresa.mx/actas/dario_lugo.pdf','https://docs.empresa.mx/domicilio/dario_lugo.pdf','https://docs.empresa.mx/cv/dario_lugo.pdf','dario.lugo@gmail.com','2029-03-05'),
(36,'MOAC970827MNLNRL36','10000000036','https://docs.empresa.mx/ine/clara_montes.pdf','https://docs.empresa.mx/actas/clara_montes.pdf','https://docs.empresa.mx/domicilio/clara_montes.pdf','https://docs.empresa.mx/cv/clara_montes.pdf','clara.montes@gmail.com','2031-08-27'),
(37,'AENT951112HNLRSN37','10000000037','https://docs.empresa.mx/ine/tomas_arellano.pdf','https://docs.empresa.mx/actas/tomas_arellano.pdf','https://docs.empresa.mx/domicilio/tomas_arellano.pdf','https://docs.empresa.mx/cv/tomas_arellano.pdf','tomas.arellano@gmail.com','2030-11-12'),
(38,'VESJ980130MNLGLL38','10000000038','https://docs.empresa.mx/ine/julia_vega.pdf','https://docs.empresa.mx/actas/julia_vega.pdf','https://docs.empresa.mx/domicilio/julia_vega.pdf','https://docs.empresa.mx/cv/julia_vega.pdf','julia.vega@gmail.com','2031-01-30'),
(39,'CAEM920420HNLRRR39','10000000039','https://docs.empresa.mx/ine/marco_carrillo.pdf','https://docs.empresa.mx/actas/marco_carrillo.pdf','https://docs.empresa.mx/domicilio/marco_carrillo.pdf','https://docs.empresa.mx/cv/marco_carrillo.pdf','marco.carrillo@gmail.com','2029-04-20'),
(40,'MEPA861009MNLRRL40','10000000040','https://docs.empresa.mx/ine/alexa_mendoza.pdf','https://docs.empresa.mx/actas/alexa_mendoza.pdf','https://docs.empresa.mx/domicilio/alexa_mendoza.pdf','https://docs.empresa.mx/cv/alexa_mendoza.pdf','alexa.mendoza@gmail.com','2028-10-09');

INSERT INTO Turno_Laboral (id_empleado, id_sucursal, fecha, hora_entrada, hora_salida, horas_trabajadas, arqueo_caja_inicio, arqueo_caja_final, diferencia_caja, incidencia) VALUES
(1,1,'2024-05-01','08:00:00','16:00:00',8.00,1500.00,18450.00,0.00,NULL),
(2,2,'2024-05-01','09:00:00','17:00:00',8.00,1800.00,22600.00,25.00,NULL),
(3,3,'2024-05-01','10:00:00','18:00:00',8.00,1600.00,19820.00,-15.00,'Retardo'),
(4,4,'2024-05-01','11:00:00','19:00:00',8.00,1400.00,17640.00,0.00,NULL),
(5,5,'2024-05-01','12:00:00','20:00:00',8.00,1700.00,21150.00,10.00,NULL),
(6,6,'2024-05-02','08:00:00','16:00:00',8.00,1450.00,16890.00,0.00,NULL),
(7,7,'2024-05-02','09:00:00','17:00:00',8.00,1550.00,18775.00,-20.00,'Retardo'),
(8,8,'2024-05-02','10:00:00','18:00:00',8.00,1300.00,15950.00,0.00,NULL),
(9,9,'2024-05-02','11:00:00','19:00:00',8.00,1750.00,21980.00,0.00,NULL),
(10,10,'2024-05-02','12:00:00','20:00:00',8.00,1250.00,15110.00,30.00,NULL),
(11,11,'2024-05-03','08:00:00','16:00:00',8.00,1500.00,18100.00,0.00,NULL),
(12,12,'2024-05-03','09:00:00','17:00:00',8.00,1600.00,19440.00,-10.00,NULL),
(13,13,'2024-05-03','10:00:00','18:00:00',8.00,1450.00,17220.00,0.00,NULL),
(14,14,'2024-05-03','11:00:00','19:00:00',8.00,1350.00,16480.00,0.00,NULL),
(15,15,'2024-05-03','12:00:00','20:00:00',8.00,1400.00,16930.00,15.00,NULL),
(16,16,'2024-05-04','08:00:00','16:00:00',8.00,1900.00,24150.00,0.00,NULL),
(17,17,'2024-05-04','09:00:00','17:00:00',8.00,1800.00,22370.00,-25.00,'Retardo'),
(18,18,'2024-05-04','10:00:00','18:00:00',8.00,1850.00,23110.00,0.00,NULL),
(19,19,'2024-05-04','11:00:00','19:00:00',8.00,1950.00,24880.00,0.00,NULL),
(20,20,'2024-05-04','12:00:00','20:00:00',8.00,1750.00,21660.00,20.00,NULL),
(21,21,'2024-05-05','08:00:00','16:00:00',8.00,2000.00,25900.00,0.00,NULL),
(22,22,'2024-05-05','09:00:00','17:00:00',8.00,1600.00,19520.00,0.00,NULL),
(23,23,'2024-05-05','10:00:00','18:00:00',8.00,1500.00,18180.00,-10.00,NULL),
(24,24,'2024-05-05','11:00:00','19:00:00',8.00,1350.00,16040.00,0.00,NULL),
(25,25,'2024-05-05','12:00:00','20:00:00',8.00,1250.00,14990.00,0.00,NULL),
(26,26,'2024-05-06','08:00:00','16:00:00',8.00,1850.00,23230.00,35.00,NULL),
(27,27,'2024-05-06','09:00:00','17:00:00',8.00,1550.00,18840.00,0.00,NULL),
(28,28,'2024-05-06','10:00:00','18:00:00',8.00,1650.00,20410.00,-20.00,'Retardo'),
(29,29,'2024-05-06','11:00:00','19:00:00',8.00,2200.00,28950.00,0.00,NULL),
(30,30,'2024-05-06','12:00:00','20:00:00',8.00,1500.00,17890.00,0.00,NULL),
(31,31,'2024-05-07','08:00:00','16:00:00',8.00,1600.00,19850.00,10.00,NULL),
(32,32,'2024-05-07','09:00:00','17:00:00',8.00,1750.00,21970.00,0.00,NULL),
(33,33,'2024-05-07','10:00:00','18:00:00',8.00,1450.00,17120.00,0.00,NULL),
(34,34,'2024-05-07','11:00:00','19:00:00',8.00,1300.00,15690.00,-15.00,NULL),
(35,35,'2024-05-07','12:00:00','20:00:00',8.00,1350.00,16280.00,0.00,NULL),
(36,36,'2024-05-08','08:00:00','16:00:00',8.00,1650.00,20620.00,0.00,NULL),
(37,37,'2024-05-08','09:00:00','17:00:00',8.00,1300.00,15480.00,20.00,NULL),
(38,38,'2024-05-08','10:00:00','18:00:00',8.00,1500.00,18440.00,0.00,NULL),
(39,39,'2024-05-08','11:00:00','19:00:00',8.00,2100.00,27300.00,-30.00,'Retardo'),
(40,40,'2024-05-08','12:00:00','20:00:00',8.00,1900.00,23950.00,0.00,NULL);

INSERT INTO Categoria_Insumo (nombre_categoria) VALUES
('Lacteos'),
('Carnes'),
('Masas'),
('Bebidas'),
('Empaque'),
('Verduras'),
('Salsas'),
('Condimentos'),
('Harinas'),
('Quesos'),
('Embutidos'),
('Aceites'),
('Congelados'),
('Postres'),
('Panaderia'),
('Limpieza'),
('Desechables'),
('Enlatados'),
('Mariscos'),
('Frutas'),
('Aderezos'),
('Especias'),
('Bebidas Calientes'),
('Bebidas Frias'),
('Cereales'),
('Proteinas'),
('Granos'),
('Pastas'),
('Dulces'),
('Utensilios'),
('Higiene'),
('Conservas'),
('Fermentos'),
('Toppings'),
('Bases Preparadas'),
('Productos Refrigerados'),
('Productos Secos'),
('Suministros Cocina'),
('Suministros Barra'),
('Suministros Delivery');

INSERT INTO Insumo (id_categoria_insumo, nombre_insumo, unidad_medida, costo_unitario_compra, proveedor_principal, activo) VALUES
(9,'Harina de trigo alta proteina','kg',18.4500,'Molinos del Norte',true),
(10,'Queso mozzarella rallado','kg',92.8000,'Lacteos Regios',true),
(11,'Pepperoni rebanado','kg',135.5000,'Carnes San Juan',true),
(7,'Salsa de tomate italiana','lt',38.2500,'Conservas del Valle',true),
(12,'Aceite de oliva','lt',120.0000,'Aceites Premier',true),
(6,'Champiñon fresco','kg',64.3000,'Verduras La Huerta',true),
(6,'Pimiento verde','kg',42.7000,'Verduras La Huerta',true),
(6,'Cebolla blanca','kg',22.1000,'Central de Abastos MTY',true),
(6,'Jalapeño rebanado','kg',48.9000,'Chiles del Norte',true),
(2,'Pollo cocido deshebrado','kg',89.4000,'Avicola Monterrey',true),
(2,'Carne molida de res','kg',112.7500,'Carnes San Juan',true),
(11,'Jamón de pavo','kg',78.6000,'Embutidos Selectos',true),
(10,'Queso parmesano','kg',145.9000,'Lacteos Regios',true),
(8,'Oregano seco','kg',85.0000,'Especias La Silla',true),
(8,'Albahaca seca','kg',95.0000,'Especias La Silla',true),
(8,'Sal refinada','kg',12.5000,'Salinas del Golfo',true),
(8,'Azucar estandar','kg',24.4000,'Dulces y Basicos MX',true),
(33,'Levadura seca','kg',160.0000,'Fermentos Mexicanos',true),
(3,'Masa preparada individual','pz',9.8000,'Masas Regias',true),
(3,'Masa preparada mediana','pz',14.6000,'Masas Regias',true),
(3,'Masa preparada grande','pz',19.9000,'Masas Regias',true),
(4,'Refresco cola 600 ml','pz',13.2000,'Bebidas del Norte',true),
(4,'Refresco naranja 600 ml','pz',12.9000,'Bebidas del Norte',true),
(4,'Agua natural 600 ml','pz',7.5000,'Bebidas del Norte',true),
(4,'Te helado 600 ml','pz',11.8000,'Bebidas del Norte',true),
(5,'Caja pizza personal','pz',4.1000,'Empaques Monterrey',true),
(5,'Caja pizza mediana','pz',5.6000,'Empaques Monterrey',true),
(5,'Caja pizza grande','pz',7.2000,'Empaques Monterrey',true),
(17,'Vaso desechable 500 ml','pz',1.1500,'Desechables del Centro',true),
(17,'Servilleta paquete','pz',0.4500,'Desechables del Centro',true),
(21,'Aderezo ranch','lt',55.3000,'Aderezos Santa Lucia',true),
(21,'Aderezo chipotle','lt',58.9000,'Aderezos Santa Lucia',true),
(14,'Brownie individual','pz',10.7000,'Postres La Abuela',true),
(14,'Galleta con chispas','pz',8.4000,'Postres La Abuela',true),
(15,'Pan de ajo','pz',6.8000,'Panaderia San Miguel',true),
(15,'Palitos de pan','pz',5.9000,'Panaderia San Miguel',true),
(19,'Camaron pacotilla','kg',185.0000,'Mariscos del Golfo',true),
(20,'Piña en cubos','kg',46.3000,'Frutas Tropicales MX',true),
(34,'Aceituna negra rebanada','kg',72.4000,'Conservas del Valle',true),
(16,'Desengrasante cocina','lt',31.5000,'Limpieza Industrial Norte',true);

INSERT INTO Proveedor (nombre_fiscal, rfc, telefono, correo, tipo_insumo_suministrado, condiciones_pago) VALUES
('Molinos del Norte SA de CV','MNO240101AB1','+528180010001','ventas@molinosdelnorte.mx','Harinas y cereales','30 dias'),
('Lacteos Regios SA de CV','LRE240102AB2','+528180010002','pedidos@lacteosregios.mx','Quesos y lacteos','15 dias'),
('Carnes San Juan SA de CV','CSJ240103AB3','+528180010003','contacto@carnessanjuan.mx','Carnes y embutidos','15 dias'),
('Conservas del Valle SA de CV','CDV240104AB4','+528180010004','ventas@conservasvalle.mx','Salsas y conservas','30 dias'),
('Aceites Premier SA de CV','APR240105AB5','+528180010005','compras@aceitespremier.mx','Aceites comestibles','30 dias'),
('Verduras La Huerta SA de CV','VLH240106AB6','+528180010006','pedidos@verduraslahuerta.mx','Verduras frescas','Contado'),
('Central de Abastos MTY SA de CV','CAM240107AB7','+528180010007','ventas@abastosmty.mx','Verduras y frutas','Contado'),
('Chiles del Norte SA de CV','CDN240108AB8','+528180010008','pedidos@chilesdelnorte.mx','Chiles y encurtidos','15 dias'),
('Avicola Monterrey SA de CV','AMO240109AB9','+528180010009','ventas@avicolamonterrey.mx','Pollo y derivados','15 dias'),
('Embutidos Selectos SA de CV','ESE240110AC1','+528180010010','contacto@embutidosselectos.mx','Embutidos','30 dias'),
('Especias La Silla SA de CV','ELS240111AC2','+528180010011','ventas@especiaslasilla.mx','Especias y condimentos','30 dias'),
('Salinas del Golfo SA de CV','SDG240112AC3','+528180010012','pedidos@salinasgolfo.mx','Sal refinada','30 dias'),
('Dulces y Basicos MX SA de CV','DBM240113AC4','+528180010013','compras@dulcesybasicos.mx','Azucar y basicos','30 dias'),
('Fermentos Mexicanos SA de CV','FME240114AC5','+528180010014','ventas@fermentosmexicanos.mx','Levaduras','30 dias'),
('Masas Regias SA de CV','MRE240115AC6','+528180010015','pedidos@masasregias.mx','Masas preparadas','15 dias'),
('Bebidas del Norte SA de CV','BDN240116AC7','+528180010016','ventas@bebidasdelnorte.mx','Bebidas frias','30 dias'),
('Empaques Monterrey SA de CV','EMO240117AC8','+528180010017','contacto@empaquesmonterrey.mx','Cajas y empaques','30 dias'),
('Desechables del Centro SA de CV','DDC240118AC9','+528180010018','pedidos@desechablescentro.mx','Desechables','30 dias'),
('Aderezos Santa Lucia SA de CV','ASL240119AD1','+528180010019','ventas@aderezossantalucia.mx','Aderezos','15 dias'),
('Postres La Abuela SA de CV','PLA240120AD2','+528180010020','contacto@postreslaabuela.mx','Postres','Contado'),
('Panaderia San Miguel SA de CV','PSM240121AD3','+528180010021','pedidos@panaderiasanmiguel.mx','Panaderia','Contado'),
('Mariscos del Golfo SA de CV','MDG240122AD4','+528180010022','ventas@mariscosgolfo.mx','Mariscos','15 dias'),
('Frutas Tropicales MX SA de CV','FTM240123AD5','+528180010023','pedidos@frutastropicales.mx','Frutas','Contado'),
('Limpieza Industrial Norte SA de CV','LIN240124AD6','+528180010024','ventas@limpiezanorte.mx','Productos de limpieza','30 dias'),
('Refrigerados Nacionales SA de CV','RNA240125AD7','+528180010025','contacto@refrigeradosnacionales.mx','Productos refrigerados','30 dias'),
('Logistica Alimentaria Express SA de CV','LAE240126AD8','+528180010026','ventas@logisticaalimentaria.mx','Transporte frio','15 dias'),
('Suministros Cocina Pro SA de CV','SCP240127AD9','+528180010027','contacto@suministroscocina.mx','Utensilios de cocina','30 dias'),
('Barra y Servicio SA de CV','BYS240128AE1','+528180010028','pedidos@barrayservicio.mx','Suministros de barra','30 dias'),
('Delivery Pack SA de CV','DPA240129AE2','+528180010029','ventas@deliverypack.mx','Empaque delivery','30 dias'),
('Distribuidora del Bajio SA de CV','DDB240130AE3','+528180010030','contacto@distribuidorabajio.mx','Insumos generales','30 dias'),
('Comercializadora Regia SA de CV','CRE240131AE4','+528180010031','ventas@comercializadoraregia.mx','Abarrotes','15 dias'),
('Alimentos Selectos Monterrey SA de CV','ASM240201AE5','+528180010032','pedidos@alimentoselectos.mx','Proteinas','15 dias'),
('Congelados del Norte SA de CV','CDO240202AE6','+528180010033','ventas@congeladosnorte.mx','Congelados','30 dias'),
('Importadora Italiana MX SA de CV','IIM240203AE7','+528180010034','contacto@importadoraitaliana.mx','Ingredientes italianos','30 dias'),
('Distribuidora Pacifico SA de CV','DPA240204AE8','+528180010035','ventas@distribuidorapacifico.mx','Bebidas y secos','30 dias'),
('Abarrotera del Centro SA de CV','ADC240205AE9','+528180010036','pedidos@abarroteracentro.mx','Abarrotes','15 dias'),
('Higiene Empresarial SA de CV','HEM240206AF1','+528180010037','ventas@higieneempresarial.mx','Higiene y limpieza','30 dias'),
('Productos Frescos del Sur SA de CV','PFS240207AF2','+528180010038','contacto@frescosdelsur.mx','Frescos','Contado'),
('Empaque Sustentable MX SA de CV','ESM240208AF3','+528180010039','ventas@empaquesustentable.mx','Empaques ecologicos','30 dias'),
('Insumos Food Service SA de CV','IFS240209AF4','+528180010040','pedidos@insumosfoodservice.mx','Insumos food service','30 dias');

INSERT INTO Orden_Compra (id_proveedor, id_sucursal, fecha_orden, fecha_entrega_estimada, fecha_entrega_real, estatus, total_orden) VALUES
(1,1,'2024-05-01','2024-05-04','2024-05-04','Recibida',18450.00),
(2,2,'2024-05-01','2024-05-04','2024-05-04','Recibida',22600.00),
(3,3,'2024-05-02','2024-05-05','2024-05-05','Recibida',19820.00),
(4,4,'2024-05-02','2024-05-05','2024-05-05','Recibida',17640.00),
(5,5,'2024-05-03','2024-05-06','2024-05-06','Recibida',21150.00),
(6,6,'2024-05-03','2024-05-06','2024-05-06','Recibida',16890.00),
(7,7,'2024-05-04','2024-05-07','2024-05-07','Recibida',18775.00),
(8,8,'2024-05-04','2024-05-07','2024-05-07','Recibida',15950.00),
(9,9,'2024-05-05','2024-05-08','2024-05-08','Recibida',21980.00),
(10,10,'2024-05-05','2024-05-08','2024-05-08','Recibida',15110.00),
(11,11,'2024-05-06','2024-05-09','2024-05-09','Recibida',18100.00),
(12,12,'2024-05-06','2024-05-09','2024-05-09','Recibida',19440.00),
(13,13,'2024-05-07','2024-05-10','2024-05-10','Recibida',17220.00),
(14,14,'2024-05-07','2024-05-10','2024-05-10','Recibida',16480.00),
(15,15,'2024-05-08','2024-05-11','2024-05-11','Recibida',16930.00),
(16,16,'2024-05-08','2024-05-11','2024-05-11','Recibida',24150.00),
(17,17,'2024-05-09','2024-05-12','2024-05-12','Recibida',22370.00),
(18,18,'2024-05-09','2024-05-12','2024-05-12','Recibida',23110.00),
(19,19,'2024-05-10','2024-05-13','2024-05-13','Recibida',24880.00),
(20,20,'2024-05-10','2024-05-13','2024-05-13','Recibida',21660.00),
(21,21,'2024-05-11','2024-05-14','2024-05-14','Recibida',25900.00),
(22,22,'2024-05-11','2024-05-14','2024-05-14','Recibida',19520.00),
(23,23,'2024-05-12','2024-05-15','2024-05-15','Recibida',18180.00),
(24,24,'2024-05-12','2024-05-15','2024-05-15','Recibida',16040.00),
(25,25,'2024-05-13','2024-05-16','2024-05-16','Recibida',14990.00),
(26,26,'2024-05-13','2024-05-16','2024-05-16','Recibida',23230.00),
(27,27,'2024-05-14','2024-05-17','2024-05-17','Recibida',18840.00),
(28,28,'2024-05-14','2024-05-17','2024-05-17','Recibida',20410.00),
(29,29,'2024-05-15','2024-05-18','2024-05-18','Recibida',28950.00),
(30,30,'2024-05-15','2024-05-18','2024-05-18','Recibida',17890.00),
(31,31,'2024-05-16','2024-05-19',NULL,'Pendiente',19850.00),
(32,32,'2024-05-16','2024-05-19',NULL,'Pendiente',21970.00),
(33,33,'2024-05-17','2024-05-20',NULL,'Pendiente',17120.00),
(34,34,'2024-05-17','2024-05-20',NULL,'Pendiente',15690.00),
(35,35,'2024-05-18','2024-05-21',NULL,'Pendiente',16280.00),
(36,36,'2024-05-18','2024-05-21',NULL,'Pendiente',20620.00),
(37,37,'2024-05-19','2024-05-22',NULL,'Pendiente',15480.00),
(38,38,'2024-05-19','2024-05-22',NULL,'Pendiente',18440.00),
(39,39,'2024-05-20','2024-05-23',NULL,'Pendiente',27300.00),
(40,40,'2024-05-20','2024-05-23',NULL,'Pendiente',23950.00);

INSERT INTO Orden_Compra_Detalle (id_orden, id_insumo, cantidad_solicitada, precio_unitario_pactado) VALUES
(1,1,500.0000,18.4500),
(2,2,220.0000,92.8000),
(3,3,120.0000,135.5000),
(4,4,300.0000,38.2500),
(5,5,80.0000,120.0000),
(6,6,150.0000,64.3000),
(7,7,160.0000,42.7000),
(8,8,180.0000,22.1000),
(9,9,100.0000,48.9000),
(10,10,140.0000,89.4000),
(11,11,110.0000,112.7500),
(12,12,130.0000,78.6000),
(13,13,90.0000,145.9000),
(14,14,25.0000,85.0000),
(15,15,20.0000,95.0000),
(16,16,60.0000,12.5000),
(17,17,70.0000,24.4000),
(18,18,40.0000,160.0000),
(19,19,900.0000,9.8000),
(20,20,700.0000,14.6000),
(21,21,600.0000,19.9000),
(22,22,1000.0000,13.2000),
(23,23,850.0000,12.9000),
(24,24,1200.0000,7.5000),
(25,25,800.0000,11.8000),
(26,26,1500.0000,4.1000),
(27,27,1400.0000,5.6000),
(28,28,1300.0000,7.2000),
(29,29,2000.0000,1.1500),
(30,30,3000.0000,0.4500),
(31,31,160.0000,55.3000),
(32,32,150.0000,58.9000),
(33,33,900.0000,10.7000),
(34,34,950.0000,8.4000),
(35,35,1000.0000,6.8000),
(36,36,1000.0000,5.9000),
(37,37,80.0000,185.0000),
(38,38,120.0000,46.3000),
(39,39,100.0000,72.4000),
(40,40,250.0000,31.5000);

INSERT INTO Inventario_Sucursal (id_sucursal, id_insumo, cantidad_existencia, fecha_caducidad, codigo_lote, stock_minimo_alerta, fecha_ultimo_conteo) VALUES
(1,1,180.5000,'2024-08-15','LC-MTY-HAR-001',50.0000,'2024-05-10'),
(2,2,95.2500,'2024-06-20','LC-SPG-QUE-002',30.0000,'2024-05-10'),
(3,3,48.0000,'2024-06-18','LC-GPE-PEP-003',15.0000,'2024-05-10'),
(4,4,120.7500,'2024-09-05','LC-APO-SAL-004',35.0000,'2024-05-10'),
(5,5,32.5000,'2024-12-30','LC-ESC-ACE-005',10.0000,'2024-05-10'),
(6,6,42.0000,'2024-05-18','LC-SCA-CHA-006',12.0000,'2024-05-10'),
(7,7,55.0000,'2024-05-22','LC-GAR-PIM-007',15.0000,'2024-05-10'),
(8,8,60.0000,'2024-05-25','LC-JUA-CEB-008',18.0000,'2024-05-10'),
(9,9,35.0000,'2024-07-01','LC-SNI-JAL-009',10.0000,'2024-05-10'),
(10,10,52.7500,'2024-06-10','LC-SAN-POL-010',15.0000,'2024-05-10'),
(11,11,40.0000,'2024-06-12','LC-SAL-RES-011',12.0000,'2024-05-10'),
(12,12,44.0000,'2024-06-15','LC-TOR-JAM-012',14.0000,'2024-05-10'),
(13,13,22.5000,'2024-07-08','LC-REY-PAR-013',8.0000,'2024-05-10'),
(14,14,8.0000,'2025-01-10','LC-MAT-ORE-014',3.0000,'2024-05-10'),
(15,15,7.5000,'2025-01-10','LC-NLD-ALB-015',3.0000,'2024-05-10'),
(16,16,25.0000,'2025-03-01','LC-TIJ-SAL-016',8.0000,'2024-05-10'),
(17,17,30.0000,'2025-02-20','LC-MEX-AZU-017',10.0000,'2024-05-10'),
(18,18,18.0000,'2025-04-15','LC-QRO-LEV-018',5.0000,'2024-05-10'),
(19,19,360.0000,'2024-05-17','LC-PUE-MPI-019',100.0000,'2024-05-10'),
(20,20,280.0000,'2024-05-17','LC-MER-MME-020',80.0000,'2024-05-10'),
(21,21,250.0000,'2024-05-17','LC-CUN-MGR-021',70.0000,'2024-05-10'),
(22,22,500.0000,'2024-09-30','LC-HER-COL-022',150.0000,'2024-05-10'),
(23,23,420.0000,'2024-09-30','LC-CHI-NAR-023',120.0000,'2024-05-10'),
(24,24,650.0000,'2024-10-15','LC-DUR-AGU-024',180.0000,'2024-05-10'),
(25,25,390.0000,'2024-09-25','LC-ZAC-TEH-025',100.0000,'2024-05-10'),
(26,26,700.0000,'2025-01-30','LC-LEO-CPP-026',200.0000,'2024-05-10'),
(27,27,620.0000,'2025-01-30','LC-AGS-CPM-027',180.0000,'2024-05-10'),
(28,28,580.0000,'2025-01-30','LC-SLP-CPG-028',160.0000,'2024-05-10'),
(29,29,850.0000,'2025-02-15','LC-CDM-VAS-029',250.0000,'2024-05-10'),
(30,30,1500.0000,'2025-03-15','LC-TOL-SER-030',400.0000,'2024-05-10'),
(31,31,70.0000,'2024-07-20','LC-CUE-RAN-031',20.0000,'2024-05-10'),
(32,32,68.0000,'2024-07-20','LC-VER-CHI-032',20.0000,'2024-05-10'),
(33,33,400.0000,'2024-06-01','LC-XAL-BRO-033',100.0000,'2024-05-10'),
(34,34,450.0000,'2024-06-01','LC-OAX-GAL-034',120.0000,'2024-05-10'),
(35,35,520.0000,'2024-05-25','LC-TUX-PAN-035',150.0000,'2024-05-10'),
(36,36,540.0000,'2024-05-25','LC-VIL-PAL-036',150.0000,'2024-05-10'),
(37,37,25.0000,'2024-06-05','LC-CAM-CAM-037',8.0000,'2024-05-10'),
(38,38,55.0000,'2024-05-28','LC-MOR-PIN-038',15.0000,'2024-05-10'),
(39,39,38.0000,'2024-07-18','LC-GDL-ACE-039',12.0000,'2024-05-10'),
(40,40,90.0000,'2025-01-10','LC-CUM-DES-040',25.0000,'2024-05-10');

INSERT INTO Categoria_Producto (nombre_categoria) VALUES
('Pizza Hot-N-Ready'),
('Pizza Especialidad'),
('Pizza Deep Dish'),
('Pizza Stuffed Crust'),
('Crazy Bread'),
('Italian Cheese Bread'),
('Alitas'),
('Bebidas'),
('Combos'),
('Postres'),
('Salsas Extra'),
('Promociones'),
('Pizza Personal'),
('Pizza Mediana'),
('Pizza Grande'),
('Pizza Familiar'),
('Pizza Pepperoni'),
('Pizza Queso'),
('Pizza Hawaiana'),
('Pizza Suprema'),
('Pizza 3 Meat Treat'),
('Pizza Veggie'),
('Pizza BBQ Chicken'),
('Pizza Mexicana'),
('Pizza ExtraMostBestest'),
('Pizza Thin Crust'),
('Pan de Ajo'),
('Complementos'),
('Paquetes Familiares'),
('Paquetes Individuales'),
('Lunch Combo'),
('Crazy Sauce'),
('Dip Ranch'),
('Dip Chipotle'),
('Bebida Individual'),
('Bebida Familiar'),
('Especial Temporada'),
('Producto App'),
('Producto Mostrador'),
('Producto Delivery');

INSERT INTO Producto_Final (id_categoria_producto, nombre_platillo, descripcion, precio_publico, disponible, tamano) VALUES
(1,'Hot-N-Ready Pepperoni','Pizza grande de pepperoni lista para llevar',99.00,true,'Grande'),
(1,'Hot-N-Ready Queso','Pizza grande de queso lista para llevar',99.00,true,'Grande'),
(25,'ExtraMostBestest Pepperoni','Pizza grande con extra queso y extra pepperoni',129.00,true,'Grande'),
(25,'ExtraMostBestest Queso','Pizza grande con extra queso mozzarella',129.00,true,'Grande'),
(3,'Deep Dish Pepperoni','Pizza estilo Detroit con pepperoni',149.00,true,'Grande'),
(3,'Deep Dish Queso','Pizza estilo Detroit con queso',149.00,true,'Grande'),
(4,'Stuffed Crust Pepperoni','Pizza orilla rellena con pepperoni',169.00,true,'Grande'),
(4,'Stuffed Crust Queso','Pizza orilla rellena de queso',169.00,true,'Grande'),
(5,'Crazy Bread','Orden de pan con ajo y parmesano',49.00,true,'Individual'),
(32,'Crazy Sauce','Salsa de tomate para acompañar',15.00,true,'Individual'),
(6,'Italian Cheese Bread','Pan horneado con queso y especias',69.00,true,'Individual'),
(7,'Alitas BBQ','Alitas bañadas en salsa BBQ',99.00,true,'Individual'),
(7,'Alitas Buffalo','Alitas bañadas en salsa buffalo',99.00,true,'Individual'),
(8,'Pepsi 600 ml','Refresco individual 600 ml',25.00,true,'Individual'),
(8,'Manzanita 600 ml','Refresco sabor manzana 600 ml',25.00,true,'Individual'),
(8,'Agua Natural 600 ml','Botella de agua natural',18.00,true,'Individual'),
(36,'Pepsi 2 L','Refresco familiar 2 litros',45.00,true,'Familiar'),
(36,'7Up 2 L','Refresco familiar 2 litros',45.00,true,'Familiar'),
(9,'Combo Pepperoni Crazy Bread','Pizza pepperoni grande con Crazy Bread',139.00,true,'Familiar'),
(9,'Combo Queso Crazy Bread','Pizza queso grande con Crazy Bread',139.00,true,'Familiar'),
(29,'Paquete Familiar Pepperoni','Dos pizzas pepperoni grandes y refresco 2 L',239.00,true,'Familiar'),
(29,'Paquete Familiar Mixto','Pizza pepperoni, pizza queso y refresco 2 L',239.00,true,'Familiar'),
(31,'Lunch Combo Deep Dish','Porcion Deep Dish con bebida individual',79.00,true,'Individual'),
(10,'Brownie','Brownie individual de chocolate',35.00,true,'Individual'),
(10,'Galleta Chispas','Galleta individual con chispas',29.00,true,'Individual'),
(19,'Pizza Hawaiana','Pizza grande con jamon y piña',139.00,true,'Grande'),
(20,'Pizza Suprema','Pizza grande con carne, pimiento, cebolla y champiñon',159.00,true,'Grande'),
(21,'Pizza 3 Meat Treat','Pizza grande con pepperoni, jamon y carne',159.00,true,'Grande'),
(22,'Pizza Veggie','Pizza grande con vegetales mixtos',139.00,true,'Grande'),
(23,'Pizza BBQ Chicken','Pizza grande con pollo y salsa BBQ',159.00,true,'Grande'),
(24,'Pizza Mexicana','Pizza grande con jalapeño, carne y cebolla',149.00,true,'Grande'),
(26,'Thin Crust Pepperoni','Pizza delgada con pepperoni',139.00,true,'Grande'),
(26,'Thin Crust Queso','Pizza delgada con queso',139.00,true,'Grande'),
(33,'Dip Ranch','Aderezo ranch individual',15.00,true,'Individual'),
(34,'Dip Chipotle','Aderezo chipotle individual',15.00,true,'Individual'),
(13,'Pizza Personal Pepperoni','Pizza personal de pepperoni',59.00,true,'Personal'),
(13,'Pizza Personal Queso','Pizza personal de queso',59.00,true,'Personal'),
(30,'Paquete Individual','Pizza personal, bebida y Crazy Sauce',89.00,true,'Personal'),
(37,'Pizza Especial de Temporada','Pizza temporal con ingredientes seleccionados',169.00,true,'Grande'),
(40,'Combo Delivery Familiar','Dos pizzas grandes, Crazy Bread y refresco',279.00,true,'Familiar');

INSERT INTO Receta_BOM (id_producto_final, id_insumo, cantidad_exacta_gastada, unidad_medida, merma_esperada_porcentaje) VALUES
(1,21,1.0000,'pz',1.50),
(1,2,0.2200,'kg',2.00),
(1,3,0.0900,'kg',1.00),
(1,4,0.1200,'lt',1.00),
(2,21,1.0000,'pz',1.50),
(2,2,0.2800,'kg',2.00),
(2,4,0.1200,'lt',1.00),
(3,21,1.0000,'pz',1.50),
(3,2,0.3200,'kg',2.00),
(3,3,0.1300,'kg',1.00),
(4,21,1.0000,'pz',1.50),
(4,2,0.3500,'kg',2.00),
(5,21,1.0000,'pz',1.50),
(5,2,0.2600,'kg',2.00),
(5,3,0.1000,'kg',1.00),
(6,21,1.0000,'pz',1.50),
(6,2,0.3000,'kg',2.00),
(7,21,1.0000,'pz',1.50),
(7,2,0.3300,'kg',2.00),
(7,3,0.1100,'kg',1.00),
(8,21,1.0000,'pz',1.50),
(8,2,0.3600,'kg',2.00),
(9,35,1.0000,'pz',1.00),
(9,13,0.0300,'kg',1.00),
(9,14,0.0050,'kg',0.50),
(10,4,0.0800,'lt',1.00),
(11,36,1.0000,'pz',1.00),
(11,2,0.1200,'kg',2.00),
(11,13,0.0250,'kg',1.00),
(12,10,0.1800,'kg',2.00),
(12,31,0.0600,'lt',1.00),
(13,10,0.1800,'kg',2.00),
(13,32,0.0600,'lt',1.00),
(14,22,1.0000,'pz',0.00),
(15,23,1.0000,'pz',0.00),
(16,24,1.0000,'pz',0.00),
(24,33,1.0000,'pz',0.00),
(25,34,1.0000,'pz',0.00),
(34,31,0.0500,'lt',0.50),
(35,32,0.0500,'lt',0.50);

INSERT INTO Vehiculo_Entrega (placas, marca, modelo, anio_modelo, capacidad_carga_kg, estatus_mecanico, fecha_ultimo_servicio, kilometraje_actual) VALUES
('LCN001A','Nissan','NP300',2021,1200.00,'Operativo','2024-04-15',48500),
('LCN002A','Nissan','NP300',2022,1200.00,'Operativo','2024-04-16',39200),
('LCN003A','Toyota','Hilux',2021,1100.00,'Operativo','2024-04-17',51400),
('LCN004A','Toyota','Hilux',2023,1100.00,'Operativo','2024-04-18',21000),
('LCN005A','Ford','Transit',2020,1500.00,'En taller','2024-03-30',76500),
('LCN006A','Ford','Transit',2022,1500.00,'Operativo','2024-04-20',34800),
('LCN007A','Chevrolet','Express',2021,1400.00,'Operativo','2024-04-21',45500),
('LCN008A','Chevrolet','Express',2023,1400.00,'Operativo','2024-04-22',18900),
('LCN009A','RAM','Promaster',2021,1600.00,'Operativo','2024-04-23',50300),
('LCN010A','RAM','Promaster',2022,1600.00,'Operativo','2024-04-24',36600),
('LCN011A','Volkswagen','Crafter',2020,1700.00,'En taller','2024-03-28',82800),
('LCN012A','Volkswagen','Crafter',2023,1700.00,'Operativo','2024-04-25',15800),
('LCN013A','Mercedes-Benz','Sprinter',2021,1800.00,'Operativo','2024-04-26',47200),
('LCN014A','Mercedes-Benz','Sprinter',2022,1800.00,'Operativo','2024-04-27',33500),
('LCN015A','Isuzu','Elf',2020,2500.00,'Operativo','2024-04-28',92000),
('LCN016A','Isuzu','Elf',2021,2500.00,'Operativo','2024-04-29',68800),
('LCN017A','Hino','300',2022,3000.00,'Operativo','2024-04-30',41200),
('LCN018A','Hino','300',2023,3000.00,'Operativo','2024-05-01',14300),
('LCN019A','Freightliner','M2',2020,4500.00,'Operativo','2024-05-02',104500),
('LCN020A','Freightliner','M2',2021,4500.00,'En taller','2024-04-01',88700),
('LCN021A','International','MV',2022,5000.00,'Operativo','2024-05-03',37600),
('LCN022A','International','MV',2023,5000.00,'Operativo','2024-05-04',11900),
('LCN023A','Kenworth','T370',2021,6000.00,'Operativo','2024-05-05',59400),
('LCN024A','Kenworth','T370',2022,6000.00,'Operativo','2024-05-06',38100),
('LCN025A','Nissan','Urvan',2020,1000.00,'Operativo','2024-05-07',70500),
('LCN026A','Nissan','Urvan',2022,1000.00,'Operativo','2024-05-08',29500),
('LCN027A','Renault','Kangoo',2021,750.00,'Operativo','2024-05-09',43800),
('LCN028A','Renault','Kangoo',2023,750.00,'Operativo','2024-05-10',9700),
('LCN029A','Peugeot','Partner',2021,850.00,'Operativo','2024-05-11',42100),
('LCN030A','Peugeot','Partner',2022,850.00,'Operativo','2024-05-12',30600),
('LCN031A','Fiat','Ducato',2020,1400.00,'Baja','2024-02-15',130000),
('LCN032A','Fiat','Ducato',2021,1400.00,'Operativo','2024-05-13',61200),
('LCN033A','Hyundai','H100',2020,1200.00,'Operativo','2024-05-14',79000),
('LCN034A','Hyundai','H100',2022,1200.00,'Operativo','2024-05-15',33500),
('LCN035A','Kia','K2500',2021,1300.00,'Operativo','2024-05-16',50100),
('LCN036A','Kia','K2500',2023,1300.00,'Operativo','2024-05-17',12800),
('LCN037A','JAC','X200',2022,1500.00,'Operativo','2024-05-18',24700),
('LCN038A','JAC','X200',2023,1500.00,'Operativo','2024-05-19',8600),
('LCN039A','Foton','Aumark',2021,3500.00,'Operativo','2024-05-20',55400),
('LCN040A','Foton','Aumark',2022,3500.00,'Operativo','2024-05-21',29900);

INSERT INTO Envio_Logistico (id_vehiculo, id_sucursal_origen, id_sucursal_destino, id_empleado_chofer, fecha_salida, fecha_llegada_estimada, fecha_llegada_real, estatus_envio, observaciones) VALUES
(1,1,2,10,'2024-05-09 06:00:00','2024-05-09 07:00:00','2024-05-09 06:55:00','Entregado','Entrega de masa y queso para apertura'),
(2,1,3,10,'2024-05-09 06:30:00','2024-05-09 07:30:00','2024-05-09 07:40:00','Entregado','Trafico ligero en Miguel Aleman'),
(3,1,4,10,'2024-05-09 07:00:00','2024-05-09 08:00:00','2024-05-09 08:05:00','Entregado','Recepcion completa'),
(4,1,5,10,'2024-05-09 07:30:00','2024-05-09 08:30:00','2024-05-09 08:25:00','Entregado','Sin observaciones'),
(5,1,6,10,'2024-05-09 08:00:00','2024-05-09 09:00:00',NULL,'Cancelado','Vehiculo enviado a taller'),
(6,1,7,10,'2024-05-09 08:30:00','2024-05-09 09:30:00','2024-05-09 09:20:00','Entregado','Entrega antes de tiempo'),
(7,1,8,10,'2024-05-09 09:00:00','2024-05-09 10:00:00','2024-05-09 10:02:00','Entregado','Recepcion con conteo manual'),
(8,1,9,10,'2024-05-09 09:30:00','2024-05-09 10:30:00','2024-05-09 10:25:00','Entregado','Ruta local metropolitana'),
(9,1,10,10,'2024-05-09 10:00:00','2024-05-09 11:15:00','2024-05-09 11:10:00','Entregado','Carretera Nacional despejada'),
(10,11,12,10,'2024-05-10 06:00:00','2024-05-10 07:30:00','2024-05-10 07:35:00','Entregado','Ruta Saltillo a Torreon programada'),
(11,11,13,10,'2024-05-10 06:30:00','2024-05-10 10:30:00',NULL,'Cancelado','Unidad no disponible'),
(12,13,14,10,'2024-05-10 07:00:00','2024-05-10 09:00:00','2024-05-10 08:55:00','Entregado','Frontera Tamaulipas'),
(13,13,15,10,'2024-05-10 07:30:00','2024-05-10 10:00:00','2024-05-10 10:15:00','Entregado','Demora por revision de carga'),
(14,16,17,10,'2024-05-10 08:00:00','2024-05-10 10:00:00','2024-05-10 09:50:00','Entregado','Ruta Baja California'),
(15,18,19,10,'2024-05-10 08:30:00','2024-05-10 12:30:00','2024-05-10 12:20:00','Entregado','Entrega regional centro'),
(16,20,21,10,'2024-05-10 09:00:00','2024-05-10 13:00:00','2024-05-10 13:10:00','Entregado','Ruta Peninsula'),
(17,22,23,10,'2024-05-11 06:00:00','2024-05-11 12:00:00','2024-05-11 11:45:00','Entregado','Ruta norte larga'),
(18,23,24,10,'2024-05-11 06:30:00','2024-05-11 11:30:00','2024-05-11 11:25:00','Entregado','Recepcion completa'),
(19,24,25,10,'2024-05-11 07:00:00','2024-05-11 12:00:00','2024-05-11 12:05:00','Entregado','Entrega a Zacatecas'),
(20,26,27,10,'2024-05-11 07:30:00','2024-05-11 10:30:00',NULL,'Cancelado','Mantenimiento correctivo'),
(21,27,28,10,'2024-05-11 08:00:00','2024-05-11 11:00:00','2024-05-11 10:55:00','Entregado','Ruta Bajio'),
(22,28,29,10,'2024-05-11 08:30:00','2024-05-11 13:30:00','2024-05-11 13:20:00','Entregado','Carga de empaques y bebidas'),
(23,29,30,10,'2024-05-12 06:00:00','2024-05-12 08:00:00','2024-05-12 07:55:00','Entregado','CDMX a Toluca'),
(24,31,32,10,'2024-05-12 06:30:00','2024-05-12 12:30:00','2024-05-12 12:40:00','Entregado','Ruta Morelos Veracruz'),
(25,32,33,10,'2024-05-12 07:00:00','2024-05-12 09:00:00','2024-05-12 08:50:00','Entregado','Veracruz a Xalapa'),
(26,34,35,10,'2024-05-12 07:30:00','2024-05-12 13:30:00','2024-05-12 13:25:00','Entregado','Oaxaca a Tuxtla'),
(27,35,36,10,'2024-05-12 08:00:00','2024-05-12 15:00:00','2024-05-12 15:20:00','Entregado','Demora por lluvia'),
(28,36,37,10,'2024-05-12 08:30:00','2024-05-12 15:30:00','2024-05-12 15:10:00','Entregado','Ruta sureste'),
(29,38,39,10,'2024-05-13 06:00:00','2024-05-13 11:00:00','2024-05-13 10:50:00','Entregado','Morelia a Guadalajara'),
(30,39,40,10,'2024-05-13 06:30:00','2024-05-13 15:30:00','2024-05-13 15:25:00','Entregado','Traslado a Monterrey Cumbres'),
(31,1,11,10,'2024-05-13 07:00:00','2024-05-13 08:30:00',NULL,'En transito','Ruta Monterrey a Saltillo'),
(32,1,16,10,'2024-05-13 07:30:00','2024-05-13 18:30:00',NULL,'Programado','Carga refrigerada programada'),
(33,1,18,10,'2024-05-13 08:00:00','2024-05-13 17:00:00',NULL,'Programado','Ruta centro programada'),
(34,1,20,10,'2024-05-13 08:30:00','2024-05-14 08:30:00',NULL,'Programado','Ruta peninsula requiere relevo'),
(35,1,22,10,'2024-05-13 09:00:00','2024-05-14 05:00:00',NULL,'Programado','Ruta noroeste'),
(36,1,26,10,'2024-05-13 09:30:00','2024-05-13 18:00:00',NULL,'Programado','Ruta Bajio desde CEDIS'),
(37,1,29,10,'2024-05-13 10:00:00','2024-05-13 20:00:00',NULL,'Programado','Ruta CDMX'),
(38,1,31,10,'2024-05-13 10:30:00','2024-05-13 21:00:00',NULL,'Programado','Ruta Morelos'),
(39,1,34,10,'2024-05-13 11:00:00','2024-05-14 02:00:00',NULL,'Programado','Ruta Oaxaca'),
(40,1,39,10,'2024-05-13 11:30:00','2024-05-14 03:30:00',NULL,'Programado','Ruta Guadalajara');

INSERT INTO Envio_Detalle (id_envio, id_insumo, cantidad_enviada, cantidad_recibida) VALUES
(1,1,80.0000,80.0000),
(2,2,45.0000,44.8000),
(3,3,25.0000,25.0000),
(4,4,60.0000,60.0000),
(5,5,20.0000,0.0000),
(6,6,25.0000,25.0000),
(7,7,30.0000,29.5000),
(8,8,35.0000,35.0000),
(9,9,18.0000,18.0000),
(10,10,28.0000,27.8000),
(11,11,24.0000,0.0000),
(12,12,26.0000,26.0000),
(13,13,12.0000,12.0000),
(14,14,5.0000,5.0000),
(15,15,5.0000,4.9000),
(16,16,10.0000,10.0000),
(17,17,12.0000,12.0000),
(18,18,8.0000,8.0000),
(19,19,120.0000,120.0000),
(20,20,100.0000,0.0000),
(21,21,90.0000,89.0000),
(22,22,160.0000,160.0000),
(23,23,140.0000,140.0000),
(24,24,180.0000,180.0000),
(25,25,130.0000,129.0000),
(26,26,220.0000,220.0000),
(27,27,200.0000,198.0000),
(28,28,190.0000,190.0000),
(29,29,260.0000,260.0000),
(30,30,400.0000,400.0000),
(31,31,24.0000,0.0000),
(32,32,22.0000,0.0000),
(33,33,110.0000,0.0000),
(34,34,120.0000,0.0000),
(35,35,150.0000,0.0000),
(36,36,150.0000,0.0000),
(37,37,10.0000,0.0000),
(38,38,18.0000,0.0000),
(39,39,14.0000,0.0000),
(40,40,30.0000,0.0000);

INSERT INTO Cliente (nombre_usuario, telefono, correo, fecha_registro, canal_adquisicion) VALUES
('Andres Garza','+528110000001','andres.garza@gmail.com','2024-01-05','App'),
('Regina Salinas','+528110000002','regina.salinas@gmail.com','2024-01-06','Mostrador'),
('Mauricio Treviño','+528110000003','mauricio.trevino@gmail.com','2024-01-07','Telefono'),
('Daniela Fuentes','+528110000004','daniela.fuentes@gmail.com','2024-01-08','App'),
('Hector Rivas','+528110000005','hector.rivas@gmail.com','2024-01-09','Tercero'),
('Paola Cantu','+528110000006','paola.cantu@gmail.com','2024-01-10','Mostrador'),
('Luis Navarro','+528110000007','luis.navarro@gmail.com','2024-01-11','App'),
('Camila Robledo','+528110000008','camila.robledo@gmail.com','2024-01-12','Telefono'),
('Sofia Mendoza','+528110000009','sofia.mendoza@gmail.com','2024-01-13','App'),
('Diego Ibarra','+528110000010','diego.ibarra@gmail.com','2024-01-14','Mostrador'),
('Mariana Ortega','+528110000011','mariana.ortega@gmail.com','2024-01-15','Tercero'),
('Ricardo Leal','+528110000012','ricardo.leal@gmail.com','2024-01-16','App'),
('Fernanda Campos','+528110000013','fernanda.campos@gmail.com','2024-01-17','Telefono'),
('Carlos Villarreal','+528110000014','carlos.villarreal@gmail.com','2024-01-18','Mostrador'),
('Natalia Serrano','+528110000015','natalia.serrano@gmail.com','2024-01-19','App'),
('Emilio Paredes','+528110000016','emilio.paredes@gmail.com','2024-01-20','App'),
('Valeria Luna','+528110000017','valeria.luna@gmail.com','2024-01-21','Mostrador'),
('Jorge Palacios','+528110000018','jorge.palacios@gmail.com','2024-01-22','Telefono'),
('Ana Barrera','+528110000019','ana.barrera@gmail.com','2024-01-23','App'),
('Oscar Castillo','+528110000020','oscar.castillo@gmail.com','2024-01-24','Tercero'),
('Claudia Reyes','+528110000021','claudia.reyes@gmail.com','2024-01-25','Mostrador'),
('Roberto Aguilar','+528110000022','roberto.aguilar@gmail.com','2024-01-26','App'),
('Gabriela Morales','+528110000023','gabriela.morales@gmail.com','2024-01-27','Telefono'),
('Sergio Benitez','+528110000024','sergio.benitez@gmail.com','2024-01-28','Mostrador'),
('Monica Vega','+528110000025','monica.vega@gmail.com','2024-01-29','App'),
('Adrian Salazar','+528110000026','adrian.salazar@gmail.com','2024-01-30','Tercero'),
('Laura Franco','+528110000027','laura.franco@gmail.com','2024-01-31','App'),
('Rafael Duarte','+528110000028','rafael.duarte@gmail.com','2024-02-01','Mostrador'),
('Andrea Beltran','+528110000029','andrea.beltran@gmail.com','2024-02-02','Telefono'),
('David Meza','+528110000030','david.meza@gmail.com','2024-02-03','App'),
('Karla Quintana','+528110000031','karla.quintana@gmail.com','2024-02-04','Mostrador'),
('Fernando Cardenas','+528110000032','fernando.cardenas@gmail.com','2024-02-05','App'),
('Isabel Solis','+528110000033','isabel.solis@gmail.com','2024-02-06','Tercero'),
('Guillermo Herrera','+528110000034','guillermo.herrera@gmail.com','2024-02-07','Telefono'),
('Lucia Maldonado','+528110000035','lucia.maldonado@gmail.com','2024-02-08','App'),
('Eduardo Padilla','+528110000036','eduardo.padilla@gmail.com','2024-02-09','Mostrador'),
('Renata Acosta','+528110000037','renata.acosta@gmail.com','2024-02-10','App'),
('Alonso Castañeda','+528110000038','alonso.castaneda@gmail.com','2024-02-11','Telefono'),
('Samantha Esquivel','+528110000039','samantha.esquivel@gmail.com','2024-02-12','Mostrador'),
('Nicolas Montoya','+528110000040','nicolas.montoya@gmail.com','2024-02-13','App');

INSERT INTO Direccion_Entrega (id_cliente, calle_numero, colonia, municipio, codigo_postal, referencias, es_principal) VALUES
(1,'Av. Paseo de los Leones 1200','Cumbres 2do Sector','Monterrey','64610','Casa blanca frente a parque',true),
(2,'Rio Mississippi 245','Del Valle','San Pedro Garza Garcia','66220','Edificio con porton negro',true),
(3,'Av. Miguel Aleman 780','Linda Vista','Guadalupe','67130','Local junto a farmacia',true),
(4,'Av. Concordia 501','Centro','Apodaca','66600','Casa con cochera gris',true),
(5,'Av. Sendero 1400','Valle del Canada','General Escobedo','66050','Privada Las Torres',true),
(6,'Manuel Ordoñez 320','Centro','Santa Catarina','66350','Entre Ocampo y Zaragoza',true),
(7,'Heberto Castillo 905','Cumbres Madeira','Garcia','66000','Casa de dos pisos',true),
(8,'Arturo B. de la Garza 212','Centro','Juarez','67250','A un lado de la secundaria',true),
(9,'Av. Universidad 600','Anahuac','San Nicolas de los Garza','66400','Departamento 4B',true),
(10,'Carretera Nacional 1300','El Cercado','Santiago','67300','Porton verde',true),
(11,'Blvd. Venustiano Carranza 900','Centro','Saltillo','25000','Oficina segundo piso',true),
(12,'Blvd. Independencia 1100','Navarro','Torreon','27000','Frente a plaza comercial',true),
(13,'Blvd. Hidalgo 760','Las Fuentes','Reynosa','88710','Casa azul',true),
(14,'Calle Sexta 140','Centro','Matamoros','87300','Esquina con Morelos',true),
(15,'Av. Reforma 1500','Jardin','Nuevo Laredo','88000','Local B',true),
(16,'Paseo de los Heroes 1015','Zona Rio','Tijuana','22010','Torre medica nivel 3',true),
(17,'Calzada Independencia 600','Centro Civico','Mexicali','21000','Casa con reja blanca',true),
(18,'Bernardo Quintana 800','Centro Sur','Queretaro','76090','Entrada por lateral',true),
(19,'Via Atlixcayotl 1700','Angelopolis','Puebla','72190','Edificio A piso 5',true),
(20,'Paseo de Montejo 500','Centro','Merida','97000','Porton de madera',true),
(21,'Av. Nichupte 300','Supermanzana 20','Cancun','77500','Condominio Sol',true),
(22,'Blvd. Kino 900','Pitic','Hermosillo','83010','Casa esquina',true),
(23,'Av. Universidad 420','Centro','Chihuahua','31000','Departamento 2A',true),
(24,'Blvd. Guadiana 700','Los Remedios','Durango','34000','Cerca del hospital',true),
(25,'Av. Hidalgo 300','Centro Historico','Zacatecas','98000','Casa cantera rosa',true),
(26,'Blvd. Lopez Mateos 1800','Campestre','Leon','37150','Torre 2',true),
(27,'Av. Madero 410','Zona Centro','Aguascalientes','20000','Frente a banco',true),
(28,'Av. Carranza 1200','Tequis','San Luis Potosi','78230','Casa con jardin',true),
(29,'Calle Orizaba 100','Roma Norte','Cuauhtemoc','06700','Departamento 302',true),
(30,'Av. Morelos 500','Centro','Toluca','50000','Oficina 12',true),
(31,'Rio Mayo 950','Vista Hermosa','Cuernavaca','62290','Casa amarilla',true),
(32,'Blvd. Avila Camacho 1400','Costa de Oro','Veracruz','94299','Condominio frente al mar',true),
(33,'Av. Americas 700','Jardines de Virginia','Xalapa','91030','Casa con porton cafe',true),
(34,'Macedonio Alcala 250','Centro','Oaxaca de Juarez','68000','Hotel boutique recepcion',true),
(35,'Av. Central 900','Centro','Tuxtla Gutierrez','29000','Local comercial',true),
(36,'Paseo Tabasco 1500','Tabasco 2000','Villahermosa','86035','Torre empresarial',true),
(37,'Av. Resurgimiento 350','San Francisco','Campeche','24000','Casa frente al malecon',true),
(38,'Av. Camelinas 2200','Felix Ireta','Morelia','58070','Departamento 8',true),
(39,'Av. Chapultepec Sur 400','Americana','Guadalajara','44160','Casa con fachada blanca',true),
(40,'Paseo de los Leones 2550','Cumbres','Monterrey','64650','Privada con caseta',true);

INSERT INTO Ticket (id_sucursal, id_cliente, id_direccion_entrega, id_turno, id_tasa, fecha_hora, tipo_orden, metodo_pago, subtotal, descuento_aplicado, iva_monto, total_venta, estatus_ticket) VALUES
(1,1,1,1,1,'2024-05-01 13:15:00','Domicilio','App',139.00,0.00,22.24,161.24,'Pagado'),
(2,2,2,2,1,'2024-05-01 13:20:00','Local','Tarjeta',99.00,0.00,15.84,114.84,'Pagado'),
(3,3,3,3,1,'2024-05-01 13:25:00','Para llevar','Efectivo',129.00,10.00,19.04,138.04,'Pagado'),
(4,4,4,4,1,'2024-05-01 13:30:00','Domicilio','App',239.00,0.00,38.24,277.24,'Pagado'),
(5,5,5,5,1,'2024-05-01 13:35:00','Local','Tarjeta',49.00,0.00,7.84,56.84,'Pagado'),
(6,6,6,6,1,'2024-05-02 14:10:00','Para llevar','Efectivo',169.00,0.00,27.04,196.04,'Pagado'),
(7,7,7,7,1,'2024-05-02 14:15:00','Domicilio','App',279.00,20.00,41.44,300.44,'Pagado'),
(8,8,8,8,1,'2024-05-02 14:20:00','Local','Voucher',99.00,0.00,15.84,114.84,'Pagado'),
(9,9,9,9,1,'2024-05-02 14:25:00','Para llevar','Tarjeta',149.00,0.00,23.84,172.84,'Pagado'),
(10,10,10,10,1,'2024-05-02 14:30:00','Domicilio','App',159.00,0.00,25.44,184.44,'Pagado'),
(11,11,11,11,11,'2024-05-03 15:05:00','Local','Efectivo',139.00,0.00,22.24,161.24,'Pagado'),
(12,12,12,12,12,'2024-05-03 15:10:00','Para llevar','Tarjeta',129.00,0.00,20.64,149.64,'Pagado'),
(13,13,13,13,13,'2024-05-03 15:15:00','Domicilio','App',169.00,15.00,12.32,166.32,'Pagado'),
(14,14,14,14,14,'2024-05-03 15:20:00','Local','Efectivo',99.00,0.00,7.92,106.92,'Pagado'),
(15,15,15,15,15,'2024-05-03 15:25:00','Para llevar','Tarjeta',239.00,0.00,19.12,258.12,'Pagado'),
(16,16,16,16,16,'2024-05-04 16:00:00','Domicilio','App',279.00,0.00,22.32,301.32,'Pagado'),
(17,17,17,17,17,'2024-05-04 16:05:00','Local','Tarjeta',59.00,0.00,4.72,63.72,'Pagado'),
(18,18,18,18,18,'2024-05-04 16:10:00','Para llevar','Efectivo',139.00,0.00,22.24,161.24,'Pagado'),
(19,19,19,19,19,'2024-05-04 16:15:00','Domicilio','App',159.00,10.00,23.84,172.84,'Pagado'),
(20,20,20,20,20,'2024-05-04 16:20:00','Local','Voucher',79.00,0.00,12.64,91.64,'Pagado'),
(21,21,21,21,21,'2024-05-05 17:00:00','Domicilio','App',239.00,0.00,38.24,277.24,'Pagado'),
(22,22,22,22,22,'2024-05-05 17:05:00','Local','Tarjeta',99.00,0.00,15.84,114.84,'Pagado'),
(23,23,23,23,23,'2024-05-05 17:10:00','Para llevar','Efectivo',129.00,0.00,20.64,149.64,'Pagado'),
(24,24,24,24,24,'2024-05-05 17:15:00','Domicilio','App',149.00,0.00,11.92,160.92,'Pagado'),
(25,25,25,25,25,'2024-05-05 17:20:00','Local','Tarjeta',49.00,0.00,3.92,52.92,'Pagado'),
(26,26,26,26,26,'2024-05-06 18:00:00','Para llevar','Efectivo',169.00,0.00,13.52,182.52,'Pagado'),
(27,27,27,27,27,'2024-05-06 18:05:00','Domicilio','App',279.00,30.00,14.94,263.94,'Pagado'),
(28,28,28,28,28,'2024-05-06 18:10:00','Local','Tarjeta',139.00,0.00,5.56,144.56,'Pagado'),
(29,29,29,29,29,'2024-05-06 18:15:00','Para llevar','Voucher',99.00,0.00,0.00,99.00,'Pagado'),
(30,30,30,30,30,'2024-05-06 18:20:00','Domicilio','App',239.00,0.00,38.24,277.24,'Pagado'),
(31,31,31,31,31,'2024-05-07 19:00:00','Local','Efectivo',129.00,0.00,20.64,149.64,'Pagado'),
(32,32,32,32,32,'2024-05-07 19:05:00','Para llevar','Tarjeta',149.00,0.00,23.84,172.84,'Pagado'),
(33,33,33,33,33,'2024-05-07 19:10:00','Domicilio','App',159.00,0.00,12.72,171.72,'Pagado'),
(34,34,34,34,34,'2024-05-07 19:15:00','Local','Efectivo',69.00,0.00,11.04,80.04,'Pagado'),
(35,35,35,35,35,'2024-05-07 19:20:00','Para llevar','Tarjeta',99.00,0.00,13.86,112.86,'Pagado'),
(36,36,36,36,36,'2024-05-08 20:00:00','Domicilio','App',89.00,0.00,0.00,89.00,'Pagado'),
(37,37,37,37,37,'2024-05-08 20:05:00','Local','Tarjeta',139.00,0.00,22.24,161.24,'Pagado'),
(38,38,38,38,38,'2024-05-08 20:10:00','Para llevar','Efectivo',169.00,20.00,17.88,166.88,'Pagado'),
(39,39,39,39,39,'2024-05-08 20:15:00','Domicilio','App',279.00,0.00,25.11,304.11,'Pagado'),
(40,40,40,40,40,'2024-05-08 20:20:00','Local','Tarjeta',99.00,0.00,15.84,114.84,'Pagado');

INSERT INTO Ticket_Detalle (id_venta, id_producto, cantidad_vendida, precio_aplicado, descuento_linea, subtotal_linea) VALUES
(1,19,1,139.00,0.00,139.00),
(2,1,1,99.00,0.00,99.00),
(3,3,1,129.00,10.00,119.00),
(4,21,1,239.00,0.00,239.00),
(5,9,1,49.00,0.00,49.00),
(6,7,1,169.00,0.00,169.00),
(7,40,1,279.00,20.00,259.00),
(8,2,1,99.00,0.00,99.00),
(9,5,1,149.00,0.00,149.00),
(10,27,1,159.00,0.00,159.00),
(11,20,1,139.00,0.00,139.00),
(12,4,1,129.00,0.00,129.00),
(13,8,1,169.00,15.00,154.00),
(14,1,1,99.00,0.00,99.00),
(15,22,1,239.00,0.00,239.00),
(16,40,1,279.00,0.00,279.00),
(17,36,1,59.00,0.00,59.00),
(18,19,1,139.00,0.00,139.00),
(19,28,1,159.00,10.00,149.00),
(20,23,1,79.00,0.00,79.00),
(21,21,1,239.00,0.00,239.00),
(22,2,1,99.00,0.00,99.00),
(23,3,1,129.00,0.00,129.00),
(24,31,1,149.00,0.00,149.00),
(25,9,1,49.00,0.00,49.00),
(26,7,1,169.00,0.00,169.00),
(27,40,1,279.00,30.00,249.00),
(28,20,1,139.00,0.00,139.00),
(29,1,1,99.00,0.00,99.00),
(30,21,1,239.00,0.00,239.00),
(31,3,1,129.00,0.00,129.00),
(32,5,1,149.00,0.00,149.00),
(33,27,1,159.00,0.00,159.00),
(34,11,1,69.00,0.00,69.00),
(35,12,1,99.00,0.00,99.00),
(36,38,1,89.00,0.00,89.00),
(37,19,1,139.00,0.00,139.00),
(38,39,1,169.00,20.00,149.00),
(39,40,1,279.00,0.00,279.00),
(40,1,1,99.00,0.00,99.00);

INSERT INTO Promocion (nombre_campana, descripcion, tipo_descuento, valor_descuento, fecha_inicio, fecha_fin, activa, canal_aplicable) VALUES
('Hot-N-Ready Lunes','Descuento en pizza pepperoni grande los lunes','Monto fijo',10.00,'2024-05-01','2024-05-31',true,'Todos'),
('Crazy Bread Combo','Precio especial al agregar Crazy Bread','Monto fijo',15.00,'2024-05-01','2024-06-15',true,'Todos'),
('ExtraMostBestest App','Descuento exclusivo en ExtraMostBestest por app','Porcentaje',10.00,'2024-05-01','2024-06-30',true,'App'),
('Deep Dish Fan','Promocion para pizzas Deep Dish','Monto fijo',20.00,'2024-05-05','2024-06-05',true,'Mostrador'),
('Stuffed Crust Weekend','Descuento de fin de semana en Stuffed Crust','Porcentaje',12.00,'2024-05-03','2024-07-01',true,'Todos'),
('Combo Familiar Delivery','Descuento en combo familiar por domicilio','Monto fijo',25.00,'2024-05-01','2024-05-31',true,'App'),
('Lunch Combo Oficina','Precio especial en Lunch Combo','Monto fijo',8.00,'2024-05-01','2024-06-30',true,'Mostrador'),
('Pizza Queso Martes','Promocion martes pizza queso','Monto fijo',10.00,'2024-05-01','2024-05-31',true,'Todos'),
('Pepsi Pack','Descuento al comprar Pepsi 2 L con pizza','Monto fijo',5.00,'2024-05-01','2024-06-30',true,'Todos'),
('Crazy Sauce Gratis','Crazy Sauce gratis en compra minima','Regalo',15.00,'2024-05-01','2024-05-20',true,'App'),
('2x1 Brownie','Segundo brownie gratis','2x1',35.00,'2024-05-10','2024-05-31',true,'Mostrador'),
('Hawaiana Especial','Descuento en pizza hawaiana','Porcentaje',8.00,'2024-05-01','2024-06-01',true,'Todos'),
('Suprema Regia','Precio especial en pizza suprema','Monto fijo',15.00,'2024-05-01','2024-06-15',true,'Todos'),
('3 Meat Treat Noche','Promocion nocturna en pizza 3 Meat Treat','Monto fijo',20.00,'2024-05-01','2024-06-30',true,'App'),
('Veggie Fresh','Descuento en pizza vegetariana','Porcentaje',10.00,'2024-05-01','2024-06-30',true,'Todos'),
('BBQ Chicken App','Promocion BBQ Chicken por app','Monto fijo',15.00,'2024-05-01','2024-06-30',true,'App'),
('Pizza Mexicana Fiesta','Promocion pizza mexicana','Porcentaje',10.00,'2024-05-01','2024-05-31',true,'Todos'),
('Thin Crust Promo','Descuento en pizza Thin Crust','Monto fijo',12.00,'2024-05-01','2024-06-30',true,'Mostrador'),
('Dip Gratis','Dip gratis en compra de alitas','Regalo',15.00,'2024-05-01','2024-06-15',true,'Todos'),
('Personal Lunch','Descuento pizza personal mediodia','Monto fijo',5.00,'2024-05-01','2024-06-30',true,'Mostrador'),
('Delivery Familiar Mayo','Promocion domicilio familiar','Porcentaje',10.00,'2024-05-01','2024-05-31',true,'App'),
('Combo Estudiante','Descuento en paquete individual','Monto fijo',10.00,'2024-05-01','2024-06-30',true,'Mostrador'),
('Noche de Pan','Descuento en Italian Cheese Bread','Monto fijo',8.00,'2024-05-01','2024-06-30',true,'Todos'),
('Alitas Viernes','Descuento en alitas los viernes','Porcentaje',15.00,'2024-05-03','2024-06-28',true,'Todos'),
('Refresco Familiar','Descuento en bebida familiar','Monto fijo',5.00,'2024-05-01','2024-06-30',true,'Todos'),
('App Nuevo Cliente','Descuento primer pedido app','Monto fijo',20.00,'2024-05-01','2024-12-31',true,'App'),
('Mostrador Rapido','Promocion para pedidos de mostrador','Monto fijo',7.00,'2024-05-01','2024-06-30',true,'Mostrador'),
('Pizza y Brownie','Descuento en postre con pizza grande','Monto fijo',10.00,'2024-05-01','2024-06-30',true,'Todos'),
('Temporada Especial','Promocion pizza especial de temporada','Porcentaje',10.00,'2024-05-15','2024-07-15',true,'Todos'),
('Combo Monterrey','Promocion local sucursales Nuevo Leon','Monto fijo',15.00,'2024-05-01','2024-05-31',true,'Todos'),
('Combo Frontera','Promocion sucursales frontera','Monto fijo',12.00,'2024-05-01','2024-06-30',true,'Todos'),
('Hora Pico','Promocion para horarios de alta demanda','Monto fijo',5.00,'2024-05-01','2024-05-31',true,'Mostrador'),
('Pizza Familiar Domingo','Descuento domingo paquete familiar','Porcentaje',10.00,'2024-05-05','2024-06-30',true,'Todos'),
('Crazy Weekend','Descuento Crazy Bread fin de semana','Monto fijo',7.00,'2024-05-03','2024-06-30',true,'Todos'),
('Tarjeta Socio','Descuento con tarjeta de socio','Porcentaje',5.00,'2024-05-01','2024-12-31',true,'Todos'),
('Voucher Empresa','Descuento con voucher corporativo','Monto fijo',15.00,'2024-05-01','2024-12-31',true,'Mostrador'),
('Regreso a Clases','Promocion escolar temporal','Monto fijo',20.00,'2024-08-01','2024-09-15',false,'Todos'),
('Buen Fin Little Caesars','Promocion de temporada Buen Fin','Porcentaje',20.00,'2024-11-15','2024-11-18',false,'Todos'),
('Navidad Pizza Party','Promocion navideña familiar','Monto fijo',30.00,'2024-12-01','2024-12-31',false,'Todos'),
('Fin de Año Hot-N-Ready','Promocion cierre de año','Porcentaje',15.00,'2024-12-26','2024-12-31',false,'Todos');

INSERT INTO Promocion_Producto (id_promo, id_producto, incremento_demanda_pct) VALUES
(1,1,12.50),
(2,9,18.00),
(3,3,15.25),
(4,5,10.75),
(5,7,13.40),
(6,40,20.00),
(7,23,11.20),
(8,2,9.80),
(9,17,8.50),
(10,10,14.00),
(11,24,7.25),
(12,26,9.10),
(13,27,12.00),
(14,28,16.50),
(15,29,10.60),
(16,30,13.90),
(17,31,15.00),
(18,32,8.70),
(19,34,6.40),
(20,36,9.95),
(21,40,21.30),
(22,38,11.75),
(23,11,10.00),
(24,12,14.80),
(25,17,7.60),
(26,3,19.20),
(27,1,8.40),
(28,24,6.90),
(29,39,17.50),
(30,19,13.25),
(31,21,12.85),
(32,1,6.00),
(33,22,15.90),
(34,9,9.30),
(35,20,5.75),
(36,23,7.10),
(37,38,10.50),
(38,40,24.00),
(39,40,18.60),
(40,1,16.20);

INSERT INTO Periodo_Financiero (año, mes, fecha_inicio, fecha_cierre, cerrado) VALUES
(2021,1,'2021-01-01','2021-01-31',true),
(2021,2,'2021-02-01','2021-02-28',true),
(2021,3,'2021-03-01','2021-03-31',true),
(2021,4,'2021-04-01','2021-04-30',true),
(2021,5,'2021-05-01','2021-05-31',true),
(2021,6,'2021-06-01','2021-06-30',true),
(2021,7,'2021-07-01','2021-07-31',true),
(2021,8,'2021-08-01','2021-08-31',true),
(2021,9,'2021-09-01','2021-09-30',true),
(2021,10,'2021-10-01','2021-10-31',true),
(2021,11,'2021-11-01','2021-11-30',true),
(2021,12,'2021-12-01','2021-12-31',true),
(2022,1,'2022-01-01','2022-01-31',true),
(2022,2,'2022-02-01','2022-02-28',true),
(2022,3,'2022-03-01','2022-03-31',true),
(2022,4,'2022-04-01','2022-04-30',true),
(2022,5,'2022-05-01','2022-05-31',true),
(2022,6,'2022-06-01','2022-06-30',true),
(2022,7,'2022-07-01','2022-07-31',true),
(2022,8,'2022-08-01','2022-08-31',true),
(2022,9,'2022-09-01','2022-09-30',true),
(2022,10,'2022-10-01','2022-10-31',true),
(2022,11,'2022-11-01','2022-11-30',true),
(2022,12,'2022-12-01','2022-12-31',true),
(2023,1,'2023-01-01','2023-01-31',true),
(2023,2,'2023-02-01','2023-02-28',true),
(2023,3,'2023-03-01','2023-03-31',true),
(2023,4,'2023-04-01','2023-04-30',true),
(2023,5,'2023-05-01','2023-05-31',true),
(2023,6,'2023-06-01','2023-06-30',true),
(2023,7,'2023-07-01','2023-07-31',true),
(2023,8,'2023-08-01','2023-08-31',true),
(2023,9,'2023-09-01','2023-09-30',true),
(2023,10,'2023-10-01','2023-10-31',true),
(2023,11,'2023-11-01','2023-11-30',true),
(2023,12,'2023-12-01','2023-12-31',true),
(2024,1,'2024-01-01','2024-01-31',true),
(2024,2,'2024-02-01','2024-02-29',true),
(2024,3,'2024-03-01','2024-03-31',true),
(2024,4,'2024-04-01','2024-04-30',false);

INSERT INTO Partida_Costo (nombre_partida, tipo, descripcion) VALUES
('Renta','Fijo','Pago mensual del local comercial'),
('Luz','Variable','Consumo electrico de hornos y sucursal'),
('Agua','Variable','Servicio de agua potable'),
('Nomina','Fijo','Sueldos del personal operativo'),
('CEDIS','Variable','Costo logistico de distribucion'),
('Publicidad','Variable','Campañas locales y digitales'),
('IVA por pagar','Variable','Impuesto trasladado pendiente de pago'),
('Gas','Variable','Consumo de gas para hornos'),
('Internet','Fijo','Servicio de internet de la sucursal'),
('Telefono','Fijo','Linea telefonica de sucursal'),
('Mantenimiento','Variable','Reparaciones menores y mantenimiento'),
('Limpieza','Variable','Productos y servicios de limpieza'),
('Seguridad','Fijo','Servicio de alarma o vigilancia'),
('Comisiones App','Variable','Comisiones por pedidos digitales'),
('Comisiones Tarjeta','Variable','Comisiones bancarias por TPV'),
('Empaques','Variable','Cajas, servilletas y vasos'),
('Uniformes','Fijo','Uniformes del personal'),
('Capacitacion','Fijo','Cursos y entrenamiento operativo'),
('Licencias','Fijo','Permisos y licencias municipales'),
('Seguro','Fijo','Seguro del local y responsabilidad civil'),
('Merma Inventario','Variable','Perdida por caducidad o manejo'),
('Transporte Local','Variable','Rutas de entrega locales'),
('Reparto Terceros','Variable','Servicios de delivery externos'),
('Agua Purificada','Variable','Agua para preparacion y servicio'),
('Fumigacion','Fijo','Servicio periodico de control de plagas'),
('Contabilidad','Fijo','Servicios contables externos'),
('Software POS','Fijo','Sistema punto de venta'),
('Equipo Cocina','Variable','Compra o reposicion de equipo menor'),
('Publicidad Exterior','Fijo','Anuncios y rotulos de sucursal'),
('Material Oficina','Variable','Papeleria y suministros administrativos'),
('Bonos Productividad','Variable','Bonos por cumplimiento de metas'),
('Horas Extra','Variable','Pago de tiempo adicional trabajado'),
('Reclutamiento','Variable','Costos de contratacion'),
('Decoracion Temporada','Variable','Decoracion de campañas especiales'),
('Musica Ambiental','Fijo','Licencia o servicio de musica'),
('Control Calidad','Variable','Auditorias y pruebas de producto'),
('Combustible','Variable','Gasolina de reparto o logistica'),
('Refacciones Vehiculo','Variable','Piezas para vehiculos de entrega'),
('Arrendamiento Equipo','Fijo','Renta de equipo especializado'),
('Fondo Emergencia','Variable','Reserva para incidentes operativos');

INSERT INTO Costo_Sucursal (id_sucursal, id_periodo, id_partida, monto, observaciones) VALUES
(1,40,1,42000.00,'Renta local Centro Monterrey abril 2024'),
(2,40,1,62000.00,'Renta zona San Pedro abril 2024'),
(3,40,1,38000.00,'Renta local Guadalupe abril 2024'),
(4,40,1,35000.00,'Renta local Apodaca abril 2024'),
(5,40,1,37000.00,'Renta local Escobedo abril 2024'),
(6,40,1,34000.00,'Renta local Santa Catarina abril 2024'),
(7,40,1,36000.00,'Renta local Garcia abril 2024'),
(8,40,1,32000.00,'Renta local Juarez abril 2024'),
(9,40,1,41000.00,'Renta local San Nicolas abril 2024'),
(10,40,1,30000.00,'Renta local Santiago abril 2024'),
(11,40,4,86000.00,'Nomina sucursal Saltillo abril 2024'),
(12,40,4,88000.00,'Nomina sucursal Torreon abril 2024'),
(13,40,4,79000.00,'Nomina sucursal Reynosa abril 2024'),
(14,40,4,76000.00,'Nomina sucursal Matamoros abril 2024'),
(15,40,4,77000.00,'Nomina sucursal Nuevo Laredo abril 2024'),
(16,40,4,98000.00,'Nomina sucursal Tijuana abril 2024'),
(17,40,4,92000.00,'Nomina sucursal Mexicali abril 2024'),
(18,40,4,96000.00,'Nomina sucursal Queretaro abril 2024'),
(19,40,4,101000.00,'Nomina sucursal Puebla abril 2024'),
(20,40,4,94000.00,'Nomina sucursal Merida abril 2024'),
(21,40,5,24500.00,'Distribucion CEDIS Cancun abril 2024'),
(22,40,5,19800.00,'Distribucion CEDIS Hermosillo abril 2024'),
(23,40,5,18700.00,'Distribucion CEDIS Chihuahua abril 2024'),
(24,40,5,16000.00,'Distribucion CEDIS Durango abril 2024'),
(25,40,5,14800.00,'Distribucion CEDIS Zacatecas abril 2024'),
(26,40,5,21300.00,'Distribucion CEDIS Leon abril 2024'),
(27,40,5,17600.00,'Distribucion CEDIS Aguascalientes abril 2024'),
(28,40,5,18400.00,'Distribucion CEDIS San Luis abril 2024'),
(29,40,5,26000.00,'Distribucion CEDIS CDMX abril 2024'),
(30,40,5,17100.00,'Distribucion CEDIS Toluca abril 2024'),
(31,40,8,13200.00,'Gas hornos Cuernavaca abril 2024'),
(32,40,8,14800.00,'Gas hornos Veracruz abril 2024'),
(33,40,8,12100.00,'Gas hornos Xalapa abril 2024'),
(34,40,8,11500.00,'Gas hornos Oaxaca abril 2024'),
(35,40,8,11900.00,'Gas hornos Tuxtla abril 2024'),
(36,40,8,13900.00,'Gas hornos Villahermosa abril 2024'),
(37,40,8,11200.00,'Gas hornos Campeche abril 2024'),
(38,40,8,12800.00,'Gas hornos Morelia abril 2024'),
(39,40,8,18500.00,'Gas hornos Guadalajara abril 2024'),
(40,40,8,17400.00,'Gas hornos Cumbres abril 2024');

INSERT INTO Ingreso_Sucursal (id_sucursal, id_periodo, total_ventas, caja_apertura, caja_cierre, nivel_demanda, valor_inventario_inicial, valor_inventario_final) VALUES
(1,40,485000.00,15000.00,19800.00,'Alto',92000.00,87000.00),
(2,40,640000.00,18000.00,24500.00,'Pico',118000.00,109500.00),
(3,40,430000.00,14000.00,17600.00,'Normal',85000.00,81200.00),
(4,40,395000.00,13000.00,16400.00,'Normal',78000.00,74200.00),
(5,40,418000.00,13500.00,17100.00,'Normal',80500.00,76000.00),
(6,40,372000.00,12500.00,15800.00,'Bajo',74000.00,71000.00),
(7,40,402000.00,13000.00,16900.00,'Normal',79000.00,75200.00),
(8,40,356000.00,12000.00,14900.00,'Bajo',70000.00,67200.00),
(9,40,510000.00,15500.00,20500.00,'Alto',96000.00,90200.00),
(10,40,340000.00,11000.00,14500.00,'Bajo',68000.00,64500.00),
(11,40,425000.00,13500.00,17400.00,'Normal',82000.00,78000.00),
(12,40,438000.00,14000.00,17900.00,'Normal',83500.00,79200.00),
(13,40,410000.00,13200.00,16600.00,'Normal',81000.00,77000.00),
(14,40,382000.00,12500.00,15850.00,'Bajo',76000.00,72400.00),
(15,40,390000.00,12800.00,16200.00,'Normal',77000.00,73500.00),
(16,40,575000.00,17000.00,22500.00,'Alto',108000.00,101500.00),
(17,40,530000.00,16000.00,21200.00,'Alto',102000.00,96500.00),
(18,40,560000.00,16500.00,22000.00,'Alto',105000.00,98800.00),
(19,40,590000.00,17500.00,23200.00,'Pico',112000.00,104000.00),
(20,40,545000.00,16000.00,21400.00,'Alto',103500.00,97800.00),
(21,40,610000.00,18000.00,24000.00,'Pico',116000.00,107500.00),
(22,40,465000.00,14500.00,18700.00,'Normal',88000.00,83600.00),
(23,40,440000.00,13800.00,17800.00,'Normal',85000.00,80700.00),
(24,40,375000.00,12200.00,15500.00,'Bajo',73500.00,69800.00),
(25,40,348000.00,11500.00,14600.00,'Bajo',69000.00,66000.00),
(26,40,555000.00,16500.00,21900.00,'Alto',106000.00,99600.00),
(27,40,425000.00,13500.00,17450.00,'Normal',82000.00,78200.00),
(28,40,452000.00,14000.00,18300.00,'Normal',86000.00,81500.00),
(29,40,710000.00,22000.00,29500.00,'Pico',130000.00,120500.00),
(30,40,415000.00,13300.00,17000.00,'Normal',80500.00,76300.00),
(31,40,450000.00,14000.00,18200.00,'Normal',85000.00,80500.00),
(32,40,505000.00,15000.00,20300.00,'Alto',96000.00,90500.00),
(33,40,388000.00,12500.00,16000.00,'Bajo',76000.00,72400.00),
(34,40,360000.00,12000.00,15100.00,'Bajo',72000.00,69000.00),
(35,40,370000.00,12200.00,15400.00,'Bajo',73500.00,70000.00),
(36,40,455000.00,14000.00,18400.00,'Normal',86500.00,82000.00),
(37,40,350000.00,11500.00,14700.00,'Bajo',69500.00,66400.00),
(38,40,428000.00,13500.00,17600.00,'Normal',82500.00,78600.00),
(39,40,625000.00,18500.00,24800.00,'Pico',119000.00,110000.00),
(40,40,585000.00,17500.00,23100.00,'Alto',111000.00,103500.00);

INSERT INTO Balance_Sucursal (id_sucursal, id_periodo, total_ingresos, total_costos_fijos, total_costos_variables, total_costos, utilidad_bruta, punto_equilibrio, margen_operativo_pct) VALUES
(1,40,485000.00,172000.00,146000.00,318000.00,167000.00,318000.00,34.43),
(2,40,640000.00,225000.00,188000.00,413000.00,227000.00,413000.00,35.47),
(3,40,430000.00,158000.00,129000.00,287000.00,143000.00,287000.00,33.26),
(4,40,395000.00,148000.00,121000.00,269000.00,126000.00,269000.00,31.90),
(5,40,418000.00,152000.00,126000.00,278000.00,140000.00,278000.00,33.49),
(6,40,372000.00,139000.00,116000.00,255000.00,117000.00,255000.00,31.45),
(7,40,402000.00,145000.00,123000.00,268000.00,134000.00,268000.00,33.33),
(8,40,356000.00,132000.00,108000.00,240000.00,116000.00,240000.00,32.58),
(9,40,510000.00,178000.00,151000.00,329000.00,181000.00,329000.00,35.49),
(10,40,340000.00,126000.00,102000.00,228000.00,112000.00,228000.00,32.94),
(11,40,425000.00,160000.00,128000.00,288000.00,137000.00,288000.00,32.24),
(12,40,438000.00,164000.00,132000.00,296000.00,142000.00,296000.00,32.42),
(13,40,410000.00,151000.00,125000.00,276000.00,134000.00,276000.00,32.68),
(14,40,382000.00,144000.00,116000.00,260000.00,122000.00,260000.00,31.94),
(15,40,390000.00,146000.00,118000.00,264000.00,126000.00,264000.00,32.31),
(16,40,575000.00,198000.00,168000.00,366000.00,209000.00,366000.00,36.35),
(17,40,530000.00,188000.00,158000.00,346000.00,184000.00,346000.00,34.72),
(18,40,560000.00,195000.00,164000.00,359000.00,201000.00,359000.00,35.89),
(19,40,590000.00,205000.00,174000.00,379000.00,211000.00,379000.00,35.76),
(20,40,545000.00,190000.00,160000.00,350000.00,195000.00,350000.00,35.78),
(21,40,610000.00,210000.00,181000.00,391000.00,219000.00,391000.00,35.90),
(22,40,465000.00,170000.00,139000.00,309000.00,156000.00,309000.00,33.55),
(23,40,440000.00,162000.00,132000.00,294000.00,146000.00,294000.00,33.18),
(24,40,375000.00,141000.00,114000.00,255000.00,120000.00,255000.00,32.00),
(25,40,348000.00,131000.00,105000.00,236000.00,112000.00,236000.00,32.18),
(26,40,555000.00,194000.00,162000.00,356000.00,199000.00,356000.00,35.86),
(27,40,425000.00,158000.00,128000.00,286000.00,139000.00,286000.00,32.71),
(28,40,452000.00,166000.00,136000.00,302000.00,150000.00,302000.00,33.19),
(29,40,710000.00,250000.00,205000.00,455000.00,255000.00,455000.00,35.92),
(30,40,415000.00,154000.00,126000.00,280000.00,135000.00,280000.00,32.53),
(31,40,450000.00,165000.00,135000.00,300000.00,150000.00,300000.00,33.33),
(32,40,505000.00,182000.00,150000.00,332000.00,173000.00,332000.00,34.26),
(33,40,388000.00,145000.00,118000.00,263000.00,125000.00,263000.00,32.22),
(34,40,360000.00,136000.00,109000.00,245000.00,115000.00,245000.00,31.94),
(35,40,370000.00,139000.00,112000.00,251000.00,119000.00,251000.00,32.16),
(36,40,455000.00,167000.00,136000.00,303000.00,152000.00,303000.00,33.41),
(37,40,350000.00,132000.00,106000.00,238000.00,112000.00,238000.00,32.00),
(38,40,428000.00,158000.00,129000.00,287000.00,141000.00,287000.00,32.94),
(39,40,625000.00,218000.00,184000.00,402000.00,223000.00,402000.00,35.68),
(40,40,585000.00,205000.00,171000.00,376000.00,209000.00,376000.00,35.73);

#---------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------

#VISTAS

CREATE VIEW vw_reporte_ventas_sucursal AS
SELECT
  s.nombre_tienda,
  u.estado,
  u.municipio,
  COUNT(t.id_venta) AS total_tickets,
  SUM(t.subtotal) AS subtotal_vendido,
  SUM(t.descuento_aplicado) AS descuentos,
  SUM(t.iva_monto) AS iva_generado,
  SUM(t.total_venta) AS total_vendido,
  AVG(t.total_venta) AS ticket_promedio
FROM Ticket t
JOIN Sucursal s ON t.id_sucursal = s.id_sucursal
JOIN Ubicacion u ON s.id_ubicacion = u.id_ubicacion
WHERE t.estatus_ticket = 'Pagado'
GROUP BY s.nombre_tienda, u.estado, u.municipio;

CREATE VIEW vw_reporte_inventario_critico AS
SELECT
  s.nombre_tienda,
  i.nombre_insumo,
  ci.nombre_categoria,
  inv.cantidad_existencia,
  inv.stock_minimo_alerta,
  inv.fecha_caducidad,
  inv.codigo_lote,
  CASE
    WHEN inv.cantidad_existencia <= inv.stock_minimo_alerta THEN 'Stock bajo'
    WHEN inv.fecha_caducidad <= DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY) THEN 'Proximo a caducar'
    ELSE 'Normal'
  END AS alerta
FROM Inventario_Sucursal inv
JOIN Sucursal s ON inv.id_sucursal = s.id_sucursal
JOIN Insumo i ON inv.id_insumo = i.id_insumo
JOIN Categoria_Insumo ci ON i.id_categoria_insumo = ci.id_categoria_insumo
WHERE inv.cantidad_existencia <= inv.stock_minimo_alerta
   OR inv.fecha_caducidad <= DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY);

CREATE VIEW vw_reporte_promociones_activas AS
SELECT
  p.nombre_campana,
  p.descripcion,
  p.tipo_descuento,
  p.valor_descuento,
  p.fecha_inicio,
  p.fecha_fin,
  p.canal_aplicable,
  pf.nombre_platillo,
  pf.precio_publico,
  pp.incremento_demanda_pct
FROM Promocion p
JOIN Promocion_Producto pp ON p.id_promo = pp.id_promo
JOIN Producto_Final pf ON pp.id_producto = pf.id_producto
WHERE p.activa = true;

CREATE VIEW vw_reporte_financiero_sucursal AS
SELECT
  s.nombre_tienda,
  u.estado,
  u.municipio,
  pf.año,
  pf.mes,
  b.total_ingresos,
  b.total_costos_fijos,
  b.total_costos_variables,
  b.total_costos,
  b.utilidad_bruta,
  b.margen_operativo_pct,
  b.punto_equilibrio
FROM Balance_Sucursal b
JOIN Sucursal s ON b.id_sucursal = s.id_sucursal
JOIN Ubicacion u ON s.id_ubicacion = u.id_ubicacion
JOIN Periodo_Financiero pf ON b.id_periodo = pf.id_periodo;

CREATE VIEW vw_reporte_logistica_envios AS
SELECT
  el.id_envio,
  so.nombre_tienda AS sucursal_origen,
  sd.nombre_tienda AS sucursal_destino,
  ve.placas,
  ve.marca,
  ve.modelo,
  CONCAT(e.nombre, ' ', e.apellido_paterno, ' ', e.apellido_materno) AS chofer,
  i.nombre_insumo,
  ed.cantidad_enviada,
  ed.cantidad_recibida,
  (ed.cantidad_enviada - ed.cantidad_recibida) AS diferencia,
  el.estatus_envio,
  el.fecha_salida,
  el.fecha_llegada_estimada,
  el.fecha_llegada_real,
  el.observaciones
FROM Envio_Logistico el
JOIN Sucursal so ON el.id_sucursal_origen = so.id_sucursal
JOIN Sucursal sd ON el.id_sucursal_destino = sd.id_sucursal
JOIN Vehiculo_Entrega ve ON el.id_vehiculo = ve.id_vehiculo
JOIN Empleado e ON el.id_empleado_chofer = e.id_empleado
JOIN Envio_Detalle ed ON el.id_envio = ed.id_envio
JOIN Insumo i ON ed.id_insumo = i.id_insumo;

CREATE VIEW vw_reporte_empleados_sucursal AS
SELECT
  s.nombre_tienda,
  CONCAT(e.nombre, ' ', e.apellido_paterno, ' ', e.apellido_materno) AS empleado,
  p.nombre_puesto,
  p.departamento,
  p.salario_base_diario,
  e.fecha_ingreso,
  e.fecha_baja,
  e.estatus,
  de.curp,
  de.nss,
  de.fecha_vencimiento_ine
FROM Empleado e
JOIN Sucursal s ON e.id_sucursal = s.id_sucursal
JOIN Puesto p ON e.id_puesto = p.id_puesto
LEFT JOIN Documentacion_Empleado de ON e.id_empleado = de.id_empleado;

CREATE VIEW vw_reporte_productos_recetas AS
SELECT
  pf.nombre_platillo,
  cp.nombre_categoria,
  pf.precio_publico,
  pf.tamano,
  pf.disponible,
  i.nombre_insumo,
  rb.cantidad_exacta_gastada,
  rb.unidad_medida,
  rb.merma_esperada_porcentaje,
  i.costo_unitario_compra,
  (rb.cantidad_exacta_gastada * i.costo_unitario_compra) AS costo_estimado_insumo
FROM Producto_Final pf
JOIN Categoria_Producto cp ON pf.id_categoria_producto = cp.id_categoria_producto
JOIN Receta_BOM rb ON pf.id_producto = rb.id_producto_final
JOIN Insumo i ON rb.id_insumo = i.id_insumo;

CREATE VIEW vw_finanzas_rentabilidad_sucursal AS
SELECT
  s.nombre_tienda,
  u.estado,
  u.municipio,
  pf.año,
  pf.mes,
  b.total_ingresos,
  b.total_costos_fijos,
  b.total_costos_variables,
  b.total_costos,
  b.utilidad_bruta,
  b.punto_equilibrio,
  b.margen_operativo_pct,
  (b.total_costos / b.total_ingresos) * 100 AS costo_sobre_ingreso_pct,
  (b.utilidad_bruta / b.total_ingresos) AS utilidad_por_peso_vendido,
  (b.total_ingresos - b.punto_equilibrio) AS excedente_sobre_equilibrio
FROM Balance_Sucursal b
JOIN Sucursal s ON b.id_sucursal = s.id_sucursal
JOIN Ubicacion u ON s.id_ubicacion = u.id_ubicacion
JOIN Periodo_Financiero pf ON b.id_periodo = pf.id_periodo;

CREATE VIEW vw_finanzas_ranking_sucursales AS
SELECT
  s.nombre_tienda,
  u.estado,
  u.municipio,
  b.total_ingresos,
  b.total_costos,
  b.utilidad_bruta,
  b.margen_operativo_pct,
  RANK() OVER (ORDER BY b.utilidad_bruta DESC) AS ranking_utilidad,
  RANK() OVER (ORDER BY b.margen_operativo_pct DESC) AS ranking_margen
FROM Balance_Sucursal b
JOIN Sucursal s ON b.id_sucursal = s.id_sucursal
JOIN Ubicacion u ON s.id_ubicacion = u.id_ubicacion;

#---------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------

#Users y permisos

CREATE USER IF NOT EXISTS 'Administrador'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'Programador'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'Cliente_Final'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'Auditor'@'localhost' IDENTIFIED BY 'CHANGE_ME';

CREATE USER IF NOT EXISTS 'Gerente_Sucursal'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'Recursos_Humanos'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'Ventas_Marketing'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'Inventario_Compras'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'Logistica_CEDIS'@'localhost' IDENTIFIED BY 'CHANGE_ME';
CREATE USER IF NOT EXISTS 'Finanzas'@'localhost' IDENTIFIED BY 'CHANGE_ME';

GRANT ALL PRIVILEGES ON LittleCeasarsDB.* TO 'Administrador'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, CREATE VIEW, SHOW VIEW ON LittleCeasarsDB.* TO 'Programador'@'localhost';

GRANT SELECT ON LittleCeasarsDB.vw_reporte_ventas_sucursal TO 'Cliente_Final'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_inventario_critico TO 'Cliente_Final'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_promociones_activas TO 'Cliente_Final'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_financiero_sucursal TO 'Cliente_Final'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_logistica_envios TO 'Cliente_Final'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_productos_recetas TO 'Cliente_Final'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_finanzas_rentabilidad_sucursal TO 'Cliente_Final'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_finanzas_ranking_sucursales TO 'Cliente_Final'@'localhost';

GRANT SELECT, SHOW VIEW ON LittleCeasarsDB.* TO 'Auditor'@'localhost';

GRANT SELECT ON LittleCeasarsDB.vw_reporte_ventas_sucursal TO 'Gerente_Sucursal'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_inventario_critico TO 'Gerente_Sucursal'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_empleados_sucursal TO 'Gerente_Sucursal'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_promociones_activas TO 'Gerente_Sucursal'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_logistica_envios TO 'Gerente_Sucursal'@'localhost';

GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Empleado TO 'Recursos_Humanos'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Documentacion_Empleado TO 'Recursos_Humanos'@'localhost';
GRANT SELECT ON LittleCeasarsDB.Puesto TO 'Recursos_Humanos'@'localhost';
GRANT SELECT ON LittleCeasarsDB.Sucursal TO 'Recursos_Humanos'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_empleados_sucursal TO 'Recursos_Humanos'@'localhost';

GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Cliente TO 'Ventas_Marketing'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Direccion_Entrega TO 'Ventas_Marketing'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Ticket TO 'Ventas_Marketing'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Ticket_Detalle TO 'Ventas_Marketing'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Promocion TO 'Ventas_Marketing'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Promocion_Producto TO 'Ventas_Marketing'@'localhost';
GRANT SELECT ON LittleCeasarsDB.Producto_Final TO 'Ventas_Marketing'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_ventas_sucursal TO 'Ventas_Marketing'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_promociones_activas TO 'Ventas_Marketing'@'localhost';

GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Categoria_Insumo TO 'Inventario_Compras'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Insumo TO 'Inventario_Compras'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Proveedor TO 'Inventario_Compras'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Orden_Compra TO 'Inventario_Compras'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Orden_Compra_Detalle TO 'Inventario_Compras'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Inventario_Sucursal TO 'Inventario_Compras'@'localhost';
GRANT SELECT ON LittleCeasarsDB.Sucursal TO 'Inventario_Compras'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_inventario_critico TO 'Inventario_Compras'@'localhost';

GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Vehiculo_Entrega TO 'Logistica_CEDIS'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Envio_Logistico TO 'Logistica_CEDIS'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Envio_Detalle TO 'Logistica_CEDIS'@'localhost';
GRANT SELECT ON LittleCeasarsDB.Sucursal TO 'Logistica_CEDIS'@'localhost';
GRANT SELECT ON LittleCeasarsDB.Empleado TO 'Logistica_CEDIS'@'localhost';
GRANT SELECT ON LittleCeasarsDB.Insumo TO 'Logistica_CEDIS'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_logistica_envios TO 'Logistica_CEDIS'@'localhost';

GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Periodo_Financiero TO 'Finanzas'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Partida_Costo TO 'Finanzas'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Costo_Sucursal TO 'Finanzas'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Ingreso_Sucursal TO 'Finanzas'@'localhost';
GRANT SELECT, INSERT, UPDATE ON LittleCeasarsDB.Balance_Sucursal TO 'Finanzas'@'localhost';
GRANT SELECT ON LittleCeasarsDB.Sucursal TO 'Finanzas'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_reporte_financiero_sucursal TO 'Finanzas'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_finanzas_rentabilidad_sucursal TO 'Finanzas'@'localhost';
GRANT SELECT ON LittleCeasarsDB.vw_finanzas_ranking_sucursales TO 'Finanzas'@'localhost';

FLUSH PRIVILEGES;

SELECT * FROM vw_reporte_ventas_sucursal ORDER BY total_vendido DESC;

SELECT * FROM vw_reporte_inventario_critico ORDER BY alerta, fecha_caducidad;

SELECT * FROM vw_reporte_promociones_activas ORDER BY incremento_demanda_pct DESC;

SELECT * FROM vw_reporte_logistica_envios ORDER BY diferencia DESC;

SELECT * FROM vw_reporte_productos_recetas ORDER BY nombre_platillo;

SELECT * FROM vw_reporte_empleados_sucursal ORDER BY nombre_tienda, empleado;

SELECT * FROM vw_reporte_financiero_sucursal ORDER BY utilidad_bruta DESC;

SELECT * FROM vw_finanzas_rentabilidad_sucursal ORDER BY margen_operativo_pct DESC;

SELECT * FROM vw_finanzas_ranking_sucursales ORDER BY ranking_utilidad;