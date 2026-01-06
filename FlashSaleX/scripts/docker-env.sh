#!/bin/bash

# FlashSaleX Docker Environment Management Script
# This script helps manage the Docker environment for development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker Desktop first."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker-compose > /dev/null 2>&1 && ! docker compose version > /dev/null 2>&1; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    print_success "Docker Compose is available"
}

# Function to start services
start_services() {
    print_info "Starting FlashSaleX services..."
    
    # Create necessary directories
    mkdir -p docker/mysql/data
    mkdir -p docker/redis/data
    
    # Start services
    if command -v docker-compose > /dev/null 2>&1; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    print_success "Services started successfully"
    
    # Wait for services to be healthy
    print_info "Waiting for services to be healthy..."
    sleep 10
    
    # Check service status
    check_services_health
}

# Function to start services with tools (phpMyAdmin, Redis Commander)
start_with_tools() {
    print_info "Starting FlashSaleX services with management tools..."
    
    # Create necessary directories
    mkdir -p docker/mysql/data
    mkdir -p docker/redis/data
    
    # Start services with tools profile
    if command -v docker-compose > /dev/null 2>&1; then
        docker-compose --profile tools up -d
    else
        docker compose --profile tools up -d
    fi
    
    print_success "Services and tools started successfully"
    
    # Wait for services to be healthy
    print_info "Waiting for services to be healthy..."
    sleep 15
    
    # Check service status
    check_services_health
    
    print_info "Management tools available at:"
    print_info "  - phpMyAdmin: http://localhost:8080"
    print_info "  - Redis Commander: http://localhost:8081"
}

# Function to stop services
stop_services() {
    print_info "Stopping FlashSaleX services..."
    
    if command -v docker-compose > /dev/null 2>&1; then
        docker-compose down
    else
        docker compose down
    fi
    
    print_success "Services stopped successfully"
}

# Function to restart services
restart_services() {
    print_info "Restarting FlashSaleX services..."
    stop_services
    sleep 2
    start_services
}

# Function to check services health
check_services_health() {
    print_info "Checking services health..."
    
    # Check MySQL
    if docker exec flashsalex-mysql mysqladmin ping -h localhost -u root -ppassword > /dev/null 2>&1; then
        print_success "MySQL is healthy"
    else
        print_warning "MySQL is not ready yet"
    fi
    
    # Check Redis
    if docker exec flashsalex-redis redis-cli ping > /dev/null 2>&1; then
        print_success "Redis is healthy"
    else
        print_warning "Redis is not ready yet"
    fi
}

# Function to show services status
show_status() {
    print_info "FlashSaleX services status:"
    
    if command -v docker-compose > /dev/null 2>&1; then
        docker-compose ps
    else
        docker compose ps
    fi
}

# Function to show logs
show_logs() {
    local service=$1
    
    if [ -z "$service" ]; then
        print_info "Showing logs for all services..."
        if command -v docker-compose > /dev/null 2>&1; then
            docker-compose logs -f
        else
            docker compose logs -f
        fi
    else
        print_info "Showing logs for $service..."
        if command -v docker-compose > /dev/null 2>&1; then
            docker-compose logs -f "$service"
        else
            docker compose logs -f "$service"
        fi
    fi
}

# Function to clean up (remove containers, volumes, networks)
cleanup() {
    print_warning "This will remove all containers, volumes, and networks for FlashSaleX"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cleaning up FlashSaleX environment..."
        
        if command -v docker-compose > /dev/null 2>&1; then
            docker-compose down -v --remove-orphans
        else
            docker compose down -v --remove-orphans
        fi
        
        # Remove custom network if exists
        docker network rm flashsalex-network 2>/dev/null || true
        
        print_success "Cleanup completed"
    else
        print_info "Cleanup cancelled"
    fi
}

# Function to connect to MySQL
connect_mysql() {
    print_info "Connecting to MySQL..."
    docker exec -it flashsalex-mysql mysql -u root -ppassword flashsalex
}

# Function to connect to Redis
connect_redis() {
    print_info "Connecting to Redis..."
    docker exec -it flashsalex-redis redis-cli
}

# Function to backup database
backup_database() {
    local backup_file="backup/flashsalex_$(date +%Y%m%d_%H%M%S).sql"
    
    print_info "Creating database backup..."
    mkdir -p backup
    
    docker exec flashsalex-mysql mysqldump -u root -ppassword flashsalex > "$backup_file"
    
    print_success "Database backup created: $backup_file"
}

# Function to restore database
restore_database() {
    local backup_file=$1
    
    if [ -z "$backup_file" ]; then
        print_error "Please specify backup file path"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    print_warning "This will restore database from: $backup_file"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Restoring database..."
        docker exec -i flashsalex-mysql mysql -u root -ppassword flashsalex < "$backup_file"
        print_success "Database restored successfully"
    else
        print_info "Restore cancelled"
    fi
}

# Function to show help
show_help() {
    echo "FlashSaleX Docker Environment Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start           Start all services"
    echo "  start-tools     Start services with management tools"
    echo "  stop            Stop all services"
    echo "  restart         Restart all services"
    echo "  status          Show services status"
    echo "  logs [SERVICE]  Show logs (all services or specific service)"
    echo "  cleanup         Remove all containers, volumes, and networks"
    echo "  mysql           Connect to MySQL CLI"
    echo "  redis           Connect to Redis CLI"
    echo "  backup          Create database backup"
    echo "  restore FILE    Restore database from backup file"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs mysql"
    echo "  $0 backup"
    echo "  $0 restore backup/flashsalex_20240101_120000.sql"
}

# Main script logic
main() {
    local command=$1
    
    case $command in
        start)
            check_docker
            check_docker_compose
            start_services
            ;;
        start-tools)
            check_docker
            check_docker_compose
            start_with_tools
            ;;
        stop)
            check_docker
            check_docker_compose
            stop_services
            ;;
        restart)
            check_docker
            check_docker_compose
            restart_services
            ;;
        status)
            check_docker
            check_docker_compose
            show_status
            ;;
        logs)
            check_docker
            check_docker_compose
            show_logs $2
            ;;
        cleanup)
            check_docker
            check_docker_compose
            cleanup
            ;;
        mysql)
            check_docker
            connect_mysql
            ;;
        redis)
            check_docker
            connect_redis
            ;;
        backup)
            check_docker
            backup_database
            ;;
        restore)
            check_docker
            restore_database $2
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            print_error "No command specified"
            show_help
            exit 1
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
