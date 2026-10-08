# SIGELAB — Sistema de Gestión y Control de Laboratorios Universitarios

**Universidad Mariano Gálvez de Guatemala · 017 Programación II · Segundo semestre 2026**  
**Aplicación de escritorio en Java 21 + Swing · SQL Server + JDBC · Maven · Git**

> **Lee antes de comenzar:** este README es la **única guía de instalación y colaboración** que se publicará inicialmente. No requiere `PLAN_EQUIPO.md`, `PROMPT_MAESTRO.md`, `docker-compose.yml` ni un archivo `.ps1`. Los archivos Docker/PowerShell son opcionales y se explican al final. **SIGELAB está en desarrollo:** hoy pueden probarse la creación de la BD, JDBC y la utilidad para crear el administrador. Todavía **no existe una aplicación Swing completa** con todos los módulos, facial y QR funcionando.

## Índice

1. Qué es SIGELAB y qué funciona actualmente
2. Requisitos y programas que debes instalar
3. Cómo descargar el código desde GitHub
4. Abrir SIGELAB en IntelliJ IDEA
5. Iniciar SQL Server con Docker
6. Conectarse mediante SSMS
7. Crear las 11 tablas y cargar datos
8. Para qué sirve cada script SQL, incluido el `04`
9. Configurar JDBC en IntelliJ y probar la conexión
10. Crear el primer administrador sin guardar contraseñas en Git
11. Cómo ejecutar el proyecto hoy y qué falta para el arranque final
12. Cómo hacer una **instalación limpia de prueba sin tocar la BD actual**
13. Cómo colaborar con GitHub: `main`, `develop` y ramas individuales
14. Reparto del trabajo entre 7 integrantes
15. Errores habituales y cómo resolverlos
16. Seguridad, entrega y responsabilidades

---

## 1. ¿Qué hace SIGELAB?

SIGELAB busca controlar el préstamo y mantenimiento de equipos de laboratorios universitarios. Debe incluir:

- Inicio de sesión por **usuario + contraseña + segundo factor facial**.
- Roles y permisos (`ADMIN`, `ENCARGADO`; `DOCENTE` opcional según diseño).
- Catálogos de laboratorios, tipos de equipo y equipos.
- Solicitantes identificados por código institucional.
- Préstamos de **uno o más equipos** con encabezado y detalle.
- Lectura de QR para **identificar** equipos (no cambia estados por sí sola).
- Devoluciones completas o parciales, con condición `BUENO` o `DANADO`.
- Mantenimiento preventivo/correctivo y salida como disponible o baja.
- Auditoría, dashboard y reportes.

**Arquitectura obligatoria:** `View → Controller → Service → Repository → JDBC → SQL Server`. Las consultas SQL van en `Repository` y las reglas de negocio en `Service`, **no** dentro de botones Swing.

**Estado actual del repositorio inicial:** existen las carpetas de Java, conexión JDBC, `TestConexion`, `PasswordUtil`, `InicializarAdmin`, `EstadoEquipo`, los scripts SQL y clases modelo que algunos integrantes deberán completar. El login visual, los servicios de préstamos y las integraciones facial/QR **todavía están pendientes**.

**Datos del proyecto:** paquete raíz `universidad.sigelab`, base de datos `PROYECTO_SIGELAB`, Java 21, Maven con `mssql-jdbc` y `jbcrypt`.

## 2. Programas necesarios (Windows 10/11)

Cada integrante debe tener:

1. **Git** (incluye Git Bash). Prueba en una terminal: `git --version`.
2. **IntelliJ IDEA**. Es el programa donde se abre y ejecuta Java.
3. **JDK 21** (kit de desarrollo Java, no solo Java Runtime). Prueba: `java -version`; si no funciona en PowerShell, revisa que esté instalado en IntelliJ.
4. **Docker Desktop** con contenedores Linux habilitados. Necesita virtualización/WSL 2 en Windows.
5. **SQL Server Management Studio (SSMS)**, para conectarte y ejecutar los archivos `.sql`.
6. Internet durante la primera descarga de las dependencias del `pom.xml`.

**No confundas:** Docker ejecuta el motor SQL Server; SSMS solo permite administrarlo. IntelliJ ejecuta el programa Java, pero **no crea las tablas automáticamente**.

**¿Es obligatorio instalar Maven por separado?** No. IntelliJ puede sincronizar y compilar proyectos Maven. El repositorio actual **no trae `mvnw.cmd`**, así que no supongas que existe. Si `mvn` no se reconoce, utiliza `Build → Rebuild Project` en IntelliJ.

## 3. Descargar el código de GitHub (para integrantes nuevos)

> Este paso se hace **después** de que el líder publique el repositorio. Si tú eres el líder y todavía estás trabajando localmente, no necesitas clonar otra copia.

1. Solicita el enlace de GitHub y una invitación de colaborador.
2. Abre **Git Bash** en una carpeta donde guardarás tus proyectos.
3. Ejecuta estos comandos, reemplazando la URL por la del equipo:

```bash
git clone URL_REAL_DEL_REPOSITORIO
cd SIGELAB
git branch -a
```

Si la carpeta descargada tiene otro nombre, utiliza ese nombre en `cd`. Si la ruta es `SIGELAB/SIGELAB`, abre **la carpeta interior que contiene `pom.xml`**.

Si GitHub dice *repository not found*, verifica la URL o si aceptaste la invitación. **No crees un proyecto Java nuevo sobre los archivos clonados.**

## 4. Abrir SIGELAB en IntelliJ IDEA

1. Abre IntelliJ IDEA → **File → Open**.
2. Selecciona la carpeta que contiene `pom.xml` → **Open**.
3. Confirma la confianza en el proyecto solo si reconoces el repositorio del grupo.
4. Ve a **File → Project Structure → Project** y establece **SDK = JDK 21**.
5. En el panel izquierdo deben aparecer `database`, `src`, `pom.xml`, `.gitignore` y `README.md`.
6. Abre `pom.xml`. Si IntelliJ muestra **Load Maven Changes** o **Sync Project**, selecciónalo.
7. Despliega **External Libraries** y comprueba que aparezcan `mssql-jdbc:12.8.1.jre11` y `jbcrypt:0.4`.
8. Selecciona **Build → Rebuild Project**. Abre **View → Tool Windows → Build**: el resultado no debe contener errores.

Si la ventana de Maven está vacía: clic derecho en `pom.xml` → **Maven → Sync Project**. Si aparece **Unlink Maven Projects**, significa que ya está vinculado: **no presiones Unlink**.

**Ubicación de conexión:** `src/main/java/universidad/sigelab/config/DatabaseConnection.java`, con primera línea `package universidad.sigelab.config;`. Evita escribir la carpeta como `confing`.

## 5. Iniciar SQL Server con Docker

Elige **SOLO UNA** de estas dos opciones. Docker necesita estar abierto y funcionando antes de ejecutar sus comandos.

### Opción A: ya tienes un contenedor SQL Server

1. Abre Docker Desktop y espera a que diga que está funcionando.
2. Abre PowerShell o la terminal de IntelliJ (**Alt + F12**).
3. Ejecuta:

```powershell
docker ps -a
```

4. Busca una fila con imagen `mcr.microsoft.com/mssql/server` y anota su **NAMES** (por ejemplo `sqlserver`).
5. Si aparece detenido (`Exited`), inicia **ese mismo contenedor**:

```powershell
docker start sqlserver
```

6. Comprueba su estado:

```powershell
docker ps
```

El resultado debe indicar `Up` y un puerto publicado, normalmente `1433->1433/tcp`.

**No crees otro SQL Server si ya tienes uno funcionando en 1433. Nunca borres su contenedor o volumen para arreglar un error de conexión.**

### Opción B: no tienes ningún contenedor (sin Docker Compose)

1. Abre Docker Desktop.
2. En la carpeta raíz de SIGELAB crea un archivo llamado **`.env`** (el punto inicial forma parte del nombre). Este archivo **NO** se sube a GitHub.
3. Pega estas líneas, sustituyendo la contraseña de ejemplo por una propia y suficientemente fuerte:

```dotenv
ACCEPT_EULA=Y
MSSQL_PID=Developer
MSSQL_SA_PASSWORD=REEMPLAZAR_POR_CLAVE_FUERTE_2026!
```

4. Abre **PowerShell** en la carpeta donde está `.env` y ejecuta:

```powershell
docker run -d --name sigelab-sqlserver --env-file .env -p 127.0.0.1:1433:1433 -v sigelab_sql_data:/var/opt/mssql mcr.microsoft.com/mssql/server:2022-latest
```

5. Espera a que SQL Server termine de arrancar y revisa:

```powershell
docker ps
docker logs --tail 30 sigelab-sqlserver
```

6. Si termina o se detiene con error, no lo borres sin verificar primero el mensaje de `docker logs`.

**Explicación:** `--name` identifica el contenedor, `-p ...1433:1433` conecta el puerto local con SQL Server, `--env-file` entrega configuración a Docker y `-v` guarda los datos en un volumen persistente. Esta es una configuración de **desarrollo local**, no de producción.

**Si dice que 1433 está ocupado:** revisa `docker ps`. Puede existir otro contenedor o servicio SQL Server usando ese puerto. No ejecutes el comando nuevamente hasta resolver el conflicto.

## 6. Conectar SSMS a SQL Server

1. Abre **SQL Server Management Studio**.
2. Selecciona **Database Engine / Motor de base de datos**.
3. En **Server name** escribe `localhost,1433` (si usaste otro puerto, cámbialo).
4. En **Authentication** elige **SQL Server Authentication**.
5. Usuario: `sa`.
6. Contraseña: la configurada **al crear tu contenedor**; no es la del administrador de SIGELAB.
7. Si aparece un error de certificado, en opciones de conexión activa **Trust server certificate** únicamente para desarrollo local.
8. Pulsa **Connect**. Debes ver las bases de datos en **Object Explorer / Explorador de objetos**.

Para abrir un script desde SSMS: **File → Open → File**, elige el archivo `.sql`, confirma la base de destino y pulsa **Execute / Ejecutar** o **F5**. Lee siempre la pestaña **Mensajes** antes de continuar.

## 7. Crear la base de datos por primera vez (11 tablas)

> **Solo para una instancia que todavía no tenga `PROYECTO_SIGELAB`.** Si ya creaste las 11 tablas en tu computadora, NO las borres ni reinicies la BD.

En SSMS conectado al servidor local, abre y ejecuta **EN ESTE ORDEN**:

1. `database/01_create_database.sql` → crea o selecciona `PROYECTO_SIGELAB`.
2. `database/02_create_tables.sql` → crea **11 tablas** y sus claves e índices (versión corregida; debe incluir `Solicitante` antes de `Prestamo`).
3. `database/03_seed_data.sql` → agrega roles, laboratorio, tipos de equipo y `CAM-001` para pruebas.

**NO ejecutes `database/04_agregar_solicitante.sql` durante una instalación nueva.** La tabla y la relación ya se crean en el paso 2.

Comprueba las tablas mediante **New Query**:

```sql
USE PROYECTO_SIGELAB;
GO
SELECT name AS NombreTabla
FROM sys.tables
WHERE schema_id = SCHEMA_ID('dbo')
  AND name <> 'sysdiagrams'
ORDER BY name;
GO
```

Deben aparecer **11 tablas**:

`Auditoria`, `DetallePrestamo`, `Devolucion`, `Equipo`, `Laboratorio`, `Mantenimiento`, `Prestamo`, `Rol`, `Solicitante`, `TipoEquipo`, `Usuario`.

Si aparece `sysdiagrams`, es una tabla auxiliar que crea SSMS para guardar diagramas y **no se cuenta como tabla SIGELAB**.

Verifica el vínculo nuevo:

```sql
SELECT name FROM sys.foreign_keys
WHERE name = 'FK_Prestamo_Solicitante';
```

Verifica los datos de ejemplo:

```sql
SELECT * FROM dbo.Rol;
SELECT * FROM dbo.Laboratorio;
SELECT * FROM dbo.TipoEquipo;
SELECT * FROM dbo.Equipo;
```

No compartas con el equipo archivos físicos `.mdf` / `.ldf`; comparte los **scripts SQL**, cada compañero construirá su base local.

## 8. ¿Qué hace cada script SQL? (incluido el 04)

| Archivo | Qué hace | ¿Se usa al instalar desde cero? |
|---|---|---|
| `01_create_database.sql` | Crea la base `PROYECTO_SIGELAB` si no existe. | **Sí, primero** |
| `02_create_tables.sql` | Crea las 11 tablas, restricciones e índices. | **Sí, segundo** |
| `03_seed_data.sql` | Inserta registros iniciales sin duplicar códigos únicos. | **Sí, tercero** |
| `04_agregar_solicitante.sql` | Migra una BD **antigua de 10 tablas**; añade Solicitante, FK y fecha de finalización. | **NO** |

El archivo **04 no es un paso cuarto universal**. Su número corresponde al orden en el que evolucionó el proyecto. En tu SQL Server actual, donde ya se comprobó `FK_Prestamo_Solicitante`, **no debes repetir la migración**.

Si un compañero conserva una base antigua, debe respaldarla y ejecutar la migración `04` **solo después de revisar el contenido de `Prestamo`**. La versión corregida se detiene de manera segura si hay préstamos antiguos que requieren migración individual; no los borra automáticamente.

**Regla de mantenimiento:** si cambian el diseño futuro, deben actualizar `02` para nuevas instalaciones y crear una nueva migración independiente para instalaciones existentes. Modificar solo el SQL en IntelliJ **no actualiza la BD que ya está corriendo**.

## 9. Configurar JDBC y comprobar Java → SQL Server

La clase `DatabaseConnection.java` conecta a:

```text
jdbc:sqlserver://localhost:1433;databaseName=PROYECTO_SIGELAB;encrypt=true;trustServerCertificate=true;
```

Actualmente usa dos variables de entorno:

- `SIGELAB_DB_USER`: usuario SQL Server, generalmente `sa`.
- `SIGELAB_DB_PASSWORD`: contraseña de `sa` del SQL Server local.

**No escribas las contraseñas en `DatabaseConnection.java` ni en GitHub.** El archivo `.env` empleado por Docker **NO configura automáticamente** las variables de IntelliJ o Java.

### Configurar las variables al ejecutar TestConexion

1. En IntelliJ abre `src/main/java/universidad/sigelab/TestConexion.java`.
2. Haz clic en el triángulo verde junto a `main()` → **Modify Run Configuration** (o **Run → Edit Configurations**).
3. En **Environment variables**, agrega `SIGELAB_DB_USER=sa` y `SIGELAB_DB_PASSWORD` con tu clave local. Usa el editor de variables de IntelliJ para introducirlas como dos entradas separadas.
4. Guarda con **Apply → OK**.
5. Ejecuta **TestConexion.main()**.

Resultado esperado:

```text
CONEXION EXITOSA A PROYECTO_SIGELAB
Base de datos: PROYECTO_SIGELAB
```

Si la contraseña se rechaza: intenta conectarte a **ese mismo servidor** desde SSMS, verifica las variables y que el puerto sea 1433. Si aparece `No suitable driver found`, sincroniza `pom.xml`, comprueba `External Libraries` y ejecuta desde la configuración de IntelliJ, no con un classpath incompleto.

## 10. Crear el administrador inicial

**Solo si el usuario `admin` todavía no existe** en la base local. `InicializarAdmin.java` crea un hash BCrypt; no debes insertar contraseñas manualmente con `INSERT` en texto plano.

1. Primero confirma que el archivo `03_seed_data.sql` se ejecutó y existe el rol `ADMIN`.
2. Compila: en IntelliJ usa **Build → Rebuild Project**.
3. Abre una terminal **PowerShell** desde la carpeta raíz de SIGELAB (`Alt + F12` en IntelliJ).
4. Escribe estos comandos, uno a uno. Cuando pide contraseña de SQL, **no la escribas en el chat ni la agregues al código**:

```powershell
$env:SIGELAB_DB_USER = 'sa'
$claveSQL = Read-Host 'Contraseña de SQL Server (sa)' -AsSecureString
$env:SIGELAB_DB_PASSWORD = [System.Net.NetworkCredential]::new('', $claveSQL).Password
$jdbc = "$env:USERPROFILE\.m2\repository\com\microsoft\sqlserver\mssql-jdbc\12.8.1.jre11\mssql-jdbc-12.8.1.jre11.jar"
$bcrypt = "$env:USERPROFILE\.m2\repository\org\mindrot\jbcrypt\0.4\jbcrypt-0.4.jar"
Test-Path $jdbc
Test-Path $bcrypt
```

Ambos `Test-Path` deben devolver `True`. Si alguno devuelve `False`, primero sincroniza Maven en IntelliJ para descargar dependencias.

5. Ejecuta:

```powershell
$classpath = "target\classes;$jdbc;$bcrypt"
java -cp $classpath universidad.sigelab.util.InicializarAdmin
```

6. Cuando diga `Contraseña del administrador:`, escribe **una contraseña nueva para SIGELAB**, de 8 caracteres o más. No aparecerán letras ni asteriscos al teclear: **es normal**. Pulsa Enter.
7. El mensaje esperado es `Administrador creado correctamente.`. Si aparece `El administrador ya existe`, no necesitas crearlo otra vez.
8. Limpia las variables de la terminal al terminar:

```powershell
Remove-Item Env:SIGELAB_DB_PASSWORD -ErrorAction SilentlyContinue
Remove-Item Env:SIGELAB_DB_USER -ErrorAction SilentlyContinue
```

9. Comprueba en SSMS (sin consultar la contraseña ni el hash):

```sql
USE PROYECTO_SIGELAB;
GO
SELECT u.username, u.estado, r.nombre AS rol
FROM dbo.Usuario AS u
INNER JOIN dbo.Rol AS r ON r.id_rol = u.id_rol
WHERE u.username = 'admin';
```

Debe aparecer `admin`, `ACTIVO`, `ADMIN`. **La existencia del administrador NO significa que el login final ya funcione:** el segundo factor facial será obligatorio al implementarlo.

## 11. Ejecutar SIGELAB hoy y más adelante

**Actualmente puedes ejecutar:**

- `TestConexion.java` para comprobar SQL Server.
- `InicializarAdmin.java` desde una consola interactiva para preparar el administrador.
- Consultas en SSMS para revisar catálogos y equipos.

**Actualmente NO hay una interfaz Swing completa para todo el sistema**. Cuando se integre el programa final, esta sección deberá indicar la clase Java `Main` verdadera y los pasos para arrancar el servidor facial local (dependencias Python, API, URL y cámara). No inventes esos comandos antes de que existan.

El orden final previsto será: **Docker → SQL Server → base de datos → componente facial local → programa Java Swing → login + validación facial → menú según rol**.

## 12. Instalación limpia de prueba (sin tocar la base que ya funciona)

Esta prueba es para el **responsable de base de datos** antes de publicar el proyecto inicial. No borres `PROYECTO_SIGELAB` ni pruebes a destruir el contenedor `sqlserver` actual. Usaremos un **SEGUNDO CONTENEDOR** aislado con puerto **1434** y un volumen nuevo.

### A. Crear contenedor de prueba (una sola vez)

1. Inicia Docker Desktop.
2. En la raíz del proyecto crea el archivo **`.env.prueba`** (Git lo ignora) con lo siguiente, utilizando una **contraseña nueva de prueba**:

```dotenv
ACCEPT_EULA=Y
MSSQL_PID=Developer
MSSQL_SA_PASSWORD=REEMPLAZAR_POR_CLAVE_PRUEBA_FUERTE_2026!
```

3. Abre PowerShell en esa carpeta y ejecuta:

```powershell
docker run -d --name sigelab-sql-prueba --env-file .env.prueba -p 127.0.0.1:1434:1433 -v sigelab_sql_prueba_data:/var/opt/mssql mcr.microsoft.com/mssql/server:2022-latest
```

4. Comprueba si está funcionando:

```powershell
docker ps
docker logs --tail 30 sigelab-sql-prueba
```

Si el contenedor ya existe de una prueba anterior, no repitas `docker run`: usa `docker start sigelab-sql-prueba`. Para que sea una **prueba realmente limpia**, debe tratarse de un contenedor/volumen sin una instalación anterior de SIGELAB.

### B. Conectarse a la instancia de prueba

1. Abre **una conexión NUEVA en SSMS**.
2. Servidor: **`localhost,1434`** (NO `localhost,1433`).
3. Autenticación SQL Server, usuario `sa` y la contraseña de `.env.prueba`.
4. Antes de ejecutar cualquier script, verifica qué servidor estás usando:

```sql
SELECT @@SERVERNAME AS Servidor,
       DB_NAME() AS BaseActual;
```

**Revisa en la barra de conexión de SSMS que dice `localhost,1434`.** Ese paso evita modificar tu SQL Server habitual por error.

### C. Instalar desde cero

En esa conexión de prueba abre y ejecuta exactamente:

1. `database/01_create_database.sql`.
2. `database/02_create_tables.sql` (**archivo corregido, sin el IF duplicado**).
3. `database/03_seed_data.sql`.

**No ejecutes `04_agregar_solicitante.sql` en la prueba limpia.**

### D. Comprobar el resultado

En SSMS, conectado a **1434**, ejecuta:

```sql
USE PROYECTO_SIGELAB;
GO
SELECT COUNT(*) AS TablasSIGELAB
FROM sys.tables
WHERE schema_id = SCHEMA_ID('dbo') AND name <> 'sysdiagrams';
GO
SELECT COUNT(*) AS Relaciones
FROM sys.foreign_keys
WHERE parent_object_id IN (
    SELECT object_id FROM sys.tables
    WHERE schema_id = SCHEMA_ID('dbo') AND name <> 'sysdiagrams'
);
GO
SELECT name AS NombreIndice
FROM sys.indexes
WHERE name IN ('UX_Detalle_Equipo_Pendiente',
               'UX_Mantenimiento_Equipo_Activo');
GO
SELECT codigo_inventario, estado FROM dbo.Equipo;
```

Resultados esperados: **11 tablas**, **11 claves foráneas** en el esquema propuesto, los **2 índices** y el equipo de ejemplo **`CAM-001` en estado `DISPONIBLE`**. Si falla algún script, **detente, guarda el error y corrige el archivo**, no intentes completarlo manualmente sin reflejarlo en Git.

### E. Terminar la prueba

Puedes detener el contenedor de prueba sin afectar tu SQL Server habitual:

```powershell
docker stop sigelab-sql-prueba
```

No uses `docker compose down -v` ni `docker volume rm` sobre los datos reales. El contenedor/volumen de prueba se conserva para investigar resultados si algo falló. Esta prueba **no modifica la URL JDBC**, que sigue apuntando a `localhost:1433`; aquí estamos validando los scripts desde SSMS.

## 13. GitHub: trabajar sin conflictos

**Una sola persona (líder) prepara las ramas comunes; los demás no renombrarán la rama principal.**

- `main`: versión estable. Si el proyecto local comenzó en `master`, el líder la renombrará cuando haga el primer commit.
- `develop`: integra los Pull Requests revisados.
- `feature/base-datos`, `feature/usuarios-login`, `feature/catalogos-equipos`, `feature/prestamos-qr`, `feature/devoluciones-mantenimiento`, `feature/reportes-auditoria`, `feature/interfaz-pruebas`: trabajo de cada persona.

### Primera publicación (solo líder)

Antes de subir: revisa que `.gitignore` excluya `.idea/`, `target/`, `.env`, `.env.prueba`, contraseñas, claves y datos faciales.

En Git Bash, desde la raíz con `pom.xml`:

```bash
git status
git remote -v
git add .
git status
```

Revisa la lista antes de confirmar. Si Git ya seguía archivos de `.idea` o `target`, retíralos **solo del seguimiento**:

```bash
git rm -r --cached .idea
# Si target estaba rastreado:
git rm -r --cached target
```

Si alguna carpeta no estaba rastreada, Git puede indicar que no encontró archivos; no es un problema. **No borres la carpeta `.git` ni hagas `git push --force`.**

Después de revisar los archivos:

```bash
git commit -m "chore: preparar estructura inicial de SIGELAB"
git branch -M main
```

Si ya configuraste `origin`, verifica su URL con `git remote -v`. Si todavía no existe, crea un repositorio vacío de SIGELAB en GitHub, copia su URL real y ejecuta:

```bash
git remote add origin URL_REAL_DEL_REPOSITORIO
git push -u origin main
git switch -c develop
git push -u origin develop
```

Si el repositorio remoto ya tiene commits o el push es rechazado, **no fuerces nada**: consulta al líder antes de fusionar historiales. Configura en GitHub la rama principal **`main`** y protege `main`/`develop` cuando sea posible.

### Trabajo diario (cada integrante)

Primero descarga actualizaciones:

```bash
git fetch origin
git switch develop
git pull origin develop
```

Luego crea **solo su rama asignada**; ejemplo:

```bash
git switch -c feature/prestamos-qr
git push -u origin feature/prestamos-qr
```

Para registrar avances:

```bash
git add .
git commit -m "feat: iniciar modulo de prestamos"
git push
```

Desde GitHub abre un **Pull Request hacia `develop`**, solicita revisión y no fusiones sin validar dependencias. **Nunca trabajes directamente en `main`.**

## 14. Reparto resumido para los 7 integrantes

Este README incluye las responsabilidades principales; **no existe ni se requiere un archivo separado de plan de equipo**.

| Persona | Rama | Responsabilidad y primera entrega |
|---|---|---|
| 1 | `feature/base-datos` | SQL, tablas/índices, relaciones, conexión JDBC y prueba limpia. Entregar esquema verificable. |
| 2 | `feature/usuarios-login` | `Usuario`, `Rol`, repositorios, servicios, Swing login, BCrypt, permisos y segunda validación facial (RN-01/02, CP-01/02). |
| 3 | `feature/catalogos-equipos` | CRUD de laboratorios, tipos y equipos, validaciones y estados (RN-03/04, CP-03). |
| 4 | `feature/prestamos-qr` | `Solicitante`, `Prestamo`, `DetallePrestamo`, QR, múltiples equipos y transacciones (RN-05–09/19, CP-04–10). |
| 5 | `feature/devoluciones-mantenimiento` | Devolución parcial, buena/dañada, mantenimiento y estados (RN-10–16, CP-11–17). |
| 6 | `feature/reportes-auditoria` | Auditoría, dashboard, fechas, vencidos, JOIN y reportes (RN-17/18, CP-18). |
| 7 | `feature/interfaz-pruebas` | `MainView` y navegación por roles, coordinación de pruebas CP-01–18, integración, manuales. |

**Acuerdos de comunicación:** P1 coordina cambios de tablas; P2+P7 coordinan login/menús; P3+P4 coordinan disponibilidad; P4+P5 coordinan detalle, devolución y transacciones; P2+P6 coordinan auditoría; P6 consulta contratos de P4/P5 para reportes; P7 revisa integración con todos.

No se cambia el nombre de una tabla, columna, enum o método compartido sin avisar y revisar el impacto. Cada integrante debe saber explicar su código en la defensa. Las 20 reglas RN y las 18 pruebas CP se encuentran en el PDF oficial del curso.

## 15. Errores frecuentes

| Mensaje o síntoma | Qué revisar |
|---|---|
| `mvn no se reconoce` | No necesariamente debes instalar Maven; utiliza **Build → Rebuild Project** en IntelliJ. |
| Maven no muestra `Lifecycle` | `pom.xml` → **Maven → Sync Project**; si no hay error, continúa con Build. |
| `No suitable driver found` | La ejecución Java no incluye el JAR JDBC. Usa IntelliJ o el classpath completo de la sección 10. |
| `Login failed for user sa` | Password local, servidor, puerto y variables `SIGELAB_DB_*`. |
| `There is already an object named ...` | No ejecutes `CREATE TABLE` antiguo sobre tablas existentes; usa el `02` corregido en una instalación nueva. |
| `FK_Prestamo_Solicitante references invalid table` | Falta crear Solicitante antes que Prestamo o estás en otra base. |
| `Contraseña del administrador:` y no ves letras | **Es normal:** se ocultan al escribir. Debe tener al menos 8 caracteres. |
| `04` detecta préstamos antiguos y se detiene | **Es intencional**: primero se necesitan identificar/migrar registros sin perder historial. |
| Aparecen 12 tablas | `sysdiagrams` es auxiliar; hay 11 propias de SIGELAB. |
| `port is already allocated` | Ya hay un SQL Server usando el puerto. Revisa `docker ps`; no borres datos. |
| No existe la carpeta `config` | Revisa ruta `universidad/sigelab/config`, no `confing`. |
| `git push` rechazado | Verifica la URL/credenciales y si existe historial en remoto. **No uses `--force`.** |

Si no funciona un paso: copia **el mensaje exacto del error**, indicando si ocurrió en SSMS, Docker, Git o IntelliJ. Oculta contraseñas, tokens y datos biométricos.

## 16. Seguridad, entregables y archivos opcionales

- No subas `.env`, `.env.prueba`, contraseñas, hashes de usuarios reales, tokens ni rostros a GitHub. El archivo `.gitignore` debe excluirlos.
- SQL Server se usa localmente con JDBC; la publicación remota de la BD **no es un requisito**.
- `main` debe contener versiones estables; cada módulo debe compilar, cumplir sus reglas y tener evidencia de las pruebas antes del merge.
- La evaluación también exige diagrama ER, diccionario de datos, manual técnico, manual de usuario, auditoría, reportes y matriz de CP. Se elaborarán durante el desarrollo y antes de la entrega final.

### ¿Para qué servirían archivos adicionales si el equipo los agrega después?

- **`docker-compose.yml` (opcional):** automatiza `docker run` y el volumen usando `docker compose up -d`. No lo uses si tu contenedor existente ya publica el mismo puerto 1433.
- **`.env.example` (opcional y publicable):** modelo de nombres de variables. Cada compañero lo copia a `.env` y coloca sus contraseñas propias. El archivo `.env` **no es publicable** y **no carga automáticamente** las variables en Java.
- **`scripts/inicializar-admin.ps1` (opcional):** automatiza el paso 10 para PowerShell y evita escribir las rutas de los dos JAR; no reemplaza `InicializarAdmin.java`.
- **`04_agregar_solicitante.sql` (incluido):** se conserva solo por compatibilidad con bases anteriores; **no** se ejecuta sobre instalaciones nuevas con 11 tablas.

Este README **funciona sin crear ninguno de los tres archivos opcionales**.

---

**Antes de marcar el repositorio como listo:** la persona responsable de BD debe verificar con capturas la prueba de instalación limpia del paso 12; la persona de integración debe comprobar que un equipo nuevo puede abrir y compilar el proyecto siguiendo esta guía.
