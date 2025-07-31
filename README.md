# Allo Health - Clinic Management System

A comprehensive front desk management system for clinics to efficiently handle patient queues, appointments, and doctor schedules.

## 🌐 Live Demo

- **Frontend**: [https://clinic-frontend-mocha.vercel.app](https://clinic-frontend-mocha.vercel.app)
- **Backend API**: Deployed on Railway
- **Database**: MySQL hosted on Railway ([mysql-production-10a3.up.railway.app](https://mysql-production-10a3.up.railway.app))

## 🚀 Getting Started

### First Time Setup

1. **Register a new account**:
   - Visit the live demo link above
   - Click "Sign up" from the login page
   - Create an account with your email and password (minimum 6 characters)

2. **Login**:
   - Use your registered credentials to access the dashboard
   - Default test account: `staff@clinic.com` / `password123`

3. **Seed the database** (Optional):
   - The system comes pre-loaded with sample data
   - You can add your own doctors, appointments, and patients

## ✨ Key Features

### 🏥 Dashboard Overview
- **Live Patient Queue**: Real-time queue management with priority handling
- **Doctor Status Board**: View all doctors with their current availability
- **Quick Actions**: Add patients to queue, assign doctors, manage appointments

### 📋 Queue Management
- **Smart Patient Addition**: Add walk-in patients or scheduled appointment patients
- **Priority System**: Normal and Urgent priority levels
- **Real-time Status Updates**: Waiting → With Doctor → Completed
- **Doctor Assignment**: Automatically updates doctor status to "Busy" when assigned
- **Auto Status Sync**: Doctor becomes "Available" when patient is completed/removed

### 👨‍⚕️ Doctor Management
- **Complete Doctor Profiles**: Name, specialization, gender, location, status
- **Status Tracking**: Available, Busy, Off Duty
- **Next Available Time**: Automatic calculation based on upcoming appointments
- **Schedule Viewing**: See individual doctor's appointment schedule
- **Filter & Search**: Filter by specialization, location, or status

### 📅 Appointment System
- **Interactive Calendar**: Visual date picker for scheduling
- **Smart Scheduling**: Prevents conflicts and shows doctor availability
- **Search & Filter**: Find appointments by patient or doctor name
- **Status Management**: Booked → Completed/Canceled
- **Queue Integration**: One-click add appointments to live queue
- **Reschedule Support**: Edit existing appointments with validation

### 🔄 Smart Automation
- **Status Synchronization**: Queue actions automatically update doctor availability
- **Appointment Completion**: Completing queue patients marks appointments as done
- **Next Available Calculation**: Automatically calculates doctor's next free slot
- **Priority Queue Sorting**: Urgent patients automatically moved to front

## 🛠️ Tech Stack

### Frontend - Next.js 14
**Why Next.js?**
- **Server-Side Rendering**: Better SEO and faster initial page loads
- **App Router**: Modern routing with layouts and loading states
- **TypeScript Support**: Built-in TypeScript for better development experience
- **Optimized Performance**: Automatic code splitting and image optimization

**Key Libraries:**
- **Tailwind CSS**: Utility-first CSS framework for rapid UI development
- **Lucide React**: Beautiful, customizable SVG icons
- **React Day Picker**: Interactive calendar component for date selection
- **Date-fns**: Modern date utility library for formatting and manipulation
- **Axios**: HTTP client with interceptors for API communication

### Backend - NestJS
**Why NestJS?**
- **TypeScript First**: Built with TypeScript for better code quality
- **Decorator-based**: Clean, readable code with decorators
- **Modular Architecture**: Organized code structure with modules
- **Built-in Validation**: Class-validator for request validation
- **JWT Authentication**: Secure authentication with Passport.js

**Key Features:**
- **TypeORM**: Object-Relational Mapping for database operations
- **JWT Authentication**: Secure token-based authentication
- **Class Validation**: Automatic request validation with decorators
- **CORS Support**: Cross-origin resource sharing for frontend communication
- **Environment Configuration**: Secure configuration management

### Database - MySQL
**Why MySQL?**
- **ACID Compliance**: Reliable transactions for critical healthcare data
- **Mature Technology**: Proven stability and performance
- **Rich Ecosystem**: Extensive tooling and community support
- **Scalability**: Handles growing clinic data efficiently

**Database Schema:**
- **Users**: Authentication and user management
- **Doctors**: Complete doctor profiles and status
- **Appointments**: Scheduled patient visits
- **Queue**: Live patient queue with priority system

### Deployment & Infrastructure

#### Frontend - Vercel
**Why Vercel?**
- **Next.js Optimized**: Built specifically for Next.js applications
- **Global CDN**: Fast content delivery worldwide
- **Automatic Deployments**: Git integration with automatic builds
- **Environment Variables**: Secure configuration management

#### Backend & Database - Railway
**Why Railway?**
- **Full-Stack Platform**: Deploy both backend and database together
- **Automatic Scaling**: Handles traffic spikes automatically
- **Environment Management**: Easy configuration and secrets management
- **MySQL Integration**: Managed MySQL with automatic backups

## 🏗️ System Architecture

### Authentication Flow
1. User registers/logs in through frontend
2. Backend validates credentials and returns JWT token
3. Frontend stores token and includes in all API requests
4. Backend validates token on protected routes

### Queue Management Flow
1. **Add Patient**: Patient added to queue (walk-in or appointment)
2. **Assign Doctor**: Doctor status changes to "Busy"
3. **Complete Visit**: Patient marked complete, doctor becomes "Available"
4. **Auto-Update**: Next available time calculated from upcoming appointments

### Data Flow
```
Frontend (Next.js) ↔ API (NestJS) ↔ Database (MySQL)
       ↓                    ↓              ↓
   User Actions    →    Business Logic  →  Data Storage
   Real-time UI    ←    Status Updates  ←  State Changes
```

## 🔧 Local Development Setup

### Prerequisites
- Node.js 18+ and npm
- MySQL 8.0+
- Git

### Backend Setup
```bash
# Clone and setup backend
git clone <repository>
cd clinic-backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your MySQL credentials

# Start development server
npm run start:dev
```

### Frontend Setup
```bash
# Setup frontend
cd clinic-frontend

# Install dependencies
npm install

# Configure environment
echo "NEXT_PUBLIC_API_URL=http://localhost:3000" > .env.local

# Start development server
npm run dev
```

### Database Setup
```sql
CREATE DATABASE clinic_db;
CREATE USER 'clinic_admin'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON clinic_db.* TO 'clinic_admin'@'localhost';
```

## 📊 Database Schema

### Users Table
- `id`: Primary key
- `email`: Unique user email
- `password`: Hashed password

### Doctors Table
- `id`: Primary key
- `name`: Doctor's full name
- `specialization`: Medical specialty
- `gender`: Gender identity
- `location`: Office/room location
- `status`: Available/Busy/Off Duty
- `nextAvailable`: Next available time slot

### Appointments Table
- `id`: Primary key
- `patientName`: Patient's full name
- `doctorId`: Foreign key to doctors
- `doctorName`: Cached doctor name
- `date`: Appointment date
- `time`: Appointment time
- `status`: Booked/Completed/Canceled

### Queue Table
- `id`: Primary key
- `patientName`: Patient's full name
- `arrival`: Arrival time
- `estWait`: Estimated wait time
- `status`: Waiting/With Doctor/Completed
- `priority`: Normal/Urgent
- `doctorId`: Assigned doctor (nullable)
- `appointmentId`: Linked appointment (nullable)
- `createdAt`: Queue entry timestamp

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: BCrypt for secure password storage
- **Input Validation**: Class-validator for request sanitization
- **CORS Protection**: Configured for specific frontend origin
- **Environment Variables**: Sensitive data stored securely

## 🎯 Business Logic Highlights

### Smart Status Management
- Doctor status automatically updates based on queue assignments
- "Available" doctors show real-time next available slots
- Completing patients automatically frees up doctors

### Priority Queue System
- Urgent patients automatically sorted to front of queue
- Visual indicators for priority levels
- Flexible priority assignment for both walk-ins and appointments

### Appointment Integration
- Seamless transition from scheduled appointments to live queue
- Automatic status synchronization between systems
- One-click queue addition for today's appointments

## 🚀 Future Enhancements

- **Real-time Notifications**: WebSocket integration for live updates
- **Mobile App**: React Native companion app
- **Analytics Dashboard**: Reporting and insights
- **Patient History**: Comprehensive patient records
- **Billing Integration**: Payment processing capabilities
- **Multi-clinic Support**: Support for clinic chains

## 📞 Support

For issues or questions about the system, please check the live demo or contact the development team.

---

**Built with ❤️ for efficient healthcare management**
