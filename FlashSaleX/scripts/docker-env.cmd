@echo off
REM FlashSaleX Docker Environment Management Script for Windows
REM This script helps manage the Docker environment for development

setlocal enabledelayedexpansion

REM Colors for output (Windows doesn't support colors in cmd by default, but we can use echo)
set "INFO_PREFIX=[INFO]"
set "SUCCESS_PREFIX=[SUCCESS]"
set "WARNING_PREFIX=[WARNING]"
set "ERROR_PREFIX=[ERROR]"

REM Function to print messages
:print_info
echo %INFO_PREFIX% %~1
goto :eof

:print_success
echo %SUCCESS_PREFIX% %~1
goto :eof

:print_warning
echo %WARNING_PREFIX% %~1
goto :eof

:print_error
echo %ERROR_PREFIX% %~1
goto :eof

REM Function to check if Docker is running
:check_docker
docker info >nul 2>&1
if errorlevel 1 (
    call :print_error "Docker is not running. Please start Docker Desktop first."
    exit /b 1
)
call :print_success "Docker is running"
goto :eof

REM Function to check if Docker Compose is available
:check_docker_compose
docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose --version >nul 2>&1
    if errorlevel 1 (
        call :print_error "Docker Compose is not available. Please install Docker Compose."
        exit /b 1
    )
)
call :print_success "Docker Compose is available"
goto :eof

REM Function to start services
:start_services
call :print_info "Starting FlashSaleX services..."

REM Create necessary directories
if not exist "docker\mysql\data" mkdir "docker\mysql\data"
if not exist "docker\redis\data" mkdir "docker\redis\data"

REM Start services
docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose up -d
) else (
    docker compose up -d
)

if errorlevel 1 (
    call :print_error "Failed to start services"
    exit /b 1
)

call :print_success "Services started successfully"

REM Wait for services to be healthy
call :print_info "Waiting for services to be healthy..."
timeout /t 10 /nobreak >nul

REM Check service status
call :check_services_health
goto :eof

REM Function to start services with tools
:start_with_tools
call :print_info "Starting FlashSaleX services with management tools..."

REM Create necessary directories
if not exist "docker\mysql\data" mkdir "docker\mysql\data"
if not exist "docker\redis\data" mkdir "docker\redis\data"

REM Start services with tools profile
docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose --profile tools up -d
) else (
    docker compose --profile tools up -d
)

if errorlevel 1 (
    call :print_error "Failed to start services with tools"
    exit /b 1
)

call :print_success "Services and tools started successfully"

REM Wait for services to be healthy
call :print_info "Waiting for services to be healthy..."
timeout /t 15 /nobreak >nul

REM Check service status
call :check_services_health

call :print_info "Management tools available at:"
call :print_info "  - phpMyAdmin: http://localhost:8080"
call :print_info "  - Redis Commander: http://localhost:8081"
goto :eof

REM Function to stop services
:stop_services
call :print_info "Stopping FlashSaleX services..."

docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose down
) else (
    docker compose down
)

call :print_success "Services stopped successfully"
goto :eof

REM Function to restart services
:restart_services
call :print_info "Restarting FlashSaleX services..."
call :stop_services
timeout /t 2 /nobreak >nul
call :start_services
goto :eof

REM Function to check services health
:check_services_health
call :print_info "Checking services health..."

REM Check MySQL
docker exec flashsalex-mysql mysqladmin ping -h localhost -u root -ppassword >nul 2>&1
if errorlevel 1 (
    call :print_warning "MySQL is not ready yet"
) else (
    call :print_success "MySQL is healthy"
)

REM Check Redis
docker exec flashsalex-redis redis-cli ping >nul 2>&1
if errorlevel 1 (
    call :print_warning "Redis is not ready yet"
) else (
    call :print_success "Redis is healthy"
)
goto :eof

REM Function to show services status
:show_status
call :print_info "FlashSaleX services status:"

docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose ps
) else (
    docker compose ps
)
goto :eof

REM Function to show logs
:show_logs
set "service=%~1"

if "%service%"=="" (
    call :print_info "Showing logs for all services..."
    docker compose version >nul 2>&1
    if errorlevel 1 (
        docker-compose logs -f
    ) else (
        docker compose logs -f
    )
) else (
    call :print_info "Showing logs for %service%..."
    docker compose version >nul 2>&1
    if errorlevel 1 (
        docker-compose logs -f "%service%"
    ) else (
        docker compose logs -f "%service%"
    )
)
goto :eof

REM Function to clean up
:cleanup
call :print_warning "This will remove all containers, volumes, and networks for FlashSaleX"
set /p "confirm=Are you sure? (y/N): "

if /i "%confirm%"=="y" (
    call :print_info "Cleaning up FlashSaleX environment..."
    
    docker compose version >nul 2>&1
    if errorlevel 1 (
        docker-compose down -v --remove-orphans
    ) else (
        docker compose down -v --remove-orphans
    )
    
    REM Remove custom network if exists
    docker network rm flashsalex-network >nul 2>&1
    
    call :print_success "Cleanup completed"
) else (
    call :print_info "Cleanup cancelled"
)
goto :eof

REM Function to connect to MySQL
:connect_mysql
call :print_info "Connecting to MySQL..."
docker exec -it flashsalex-mysql mysql -u root -ppassword flashsalex
goto :eof

REM Function to connect to Redis
:connect_redis
call :print_info "Connecting to Redis..."
docker exec -it flashsalex-redis redis-cli
goto :eof

REM Function to backup database
:backup_database
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do set "backup_date=%%c%%a%%b"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "backup_time=%%a%%b"
set "backup_file=backup\flashsalex_%backup_date%_%backup_time%.sql"

call :print_info "Creating database backup..."
if not exist "backup" mkdir "backup"

docker exec flashsalex-mysql mysqldump -u root -ppassword flashsalex > "%backup_file%"

if errorlevel 1 (
    call :print_error "Failed to create backup"
    exit /b 1
)

call :print_success "Database backup created: %backup_file%"
goto :eof

REM Function to restore database
:restore_database
set "backup_file=%~1"

if "%backup_file%"=="" (
    call :print_error "Please specify backup file path"
    exit /b 1
)

if not exist "%backup_file%" (
    call :print_error "Backup file not found: %backup_file%"
    exit /b 1
)

call :print_warning "This will restore database from: %backup_file%"
set /p "confirm=Are you sure? (y/N): "

if /i "%confirm%"=="y" (
    call :print_info "Restoring database..."
    docker exec -i flashsalex-mysql mysql -u root -ppassword flashsalex < "%backup_file%"
    
    if errorlevel 1 (
        call :print_error "Failed to restore database"
        exit /b 1
    )
    
    call :print_success "Database restored successfully"
) else (
    call :print_info "Restore cancelled"
)
goto :eof

REM Function to show help
:show_help
echo FlashSaleX Docker Environment Management Script for Windows
echo.
echo Usage: %~nx0 [COMMAND]
echo.
echo Commands:
echo   start           Start all services
echo   start-tools     Start services with management tools
echo   stop            Stop all services
echo   restart         Restart all services
echo   status          Show services status
echo   logs [SERVICE]  Show logs (all services or specific service)
echo   cleanup         Remove all containers, volumes, and networks
echo   mysql           Connect to MySQL CLI
echo   redis           Connect to Redis CLI
echo   backup          Create database backup
echo   restore FILE    Restore database from backup file
echo   help            Show this help message
echo.
echo Examples:
echo   %~nx0 start
echo   %~nx0 logs mysql
echo   %~nx0 backup
echo   %~nx0 restore backup\flashsalex_20240101_120000.sql
goto :eof

REM Main script logic
set "command=%~1"

if "%command%"=="start" (
    call :check_docker
    call :check_docker_compose
    call :start_services
) else if "%command%"=="start-tools" (
    call :check_docker
    call :check_docker_compose
    call :start_with_tools
) else if "%command%"=="stop" (
    call :check_docker
    call :check_docker_compose
    call :stop_services
) else if "%command%"=="restart" (
    call :check_docker
    call :check_docker_compose
    call :restart_services
) else if "%command%"=="status" (
    call :check_docker
    call :check_docker_compose
    call :show_status
) else if "%command%"=="logs" (
    call :check_docker
    call :check_docker_compose
    call :show_logs "%~2"
) else if "%command%"=="cleanup" (
    call :check_docker
    call :check_docker_compose
    call :cleanup
) else if "%command%"=="mysql" (
    call :check_docker
    call :connect_mysql
) else if "%command%"=="redis" (
    call :check_docker
    call :connect_redis
) else if "%command%"=="backup" (
    call :check_docker
    call :backup_database
) else if "%command%"=="restore" (
    call :check_docker
    call :restore_database "%~2"
) else if "%command%"=="help" (
    call :show_help
) else if "%command%"=="--help" (
    call :show_help
) else if "%command%"=="-h" (
    call :show_help
) else if "%command%"=="" (
    call :print_error "No command specified"
    call :show_help
    exit /b 1
) else (
    call :print_error "Unknown command: %command%"
    call :show_help
    exit /b 1
)

endlocal
