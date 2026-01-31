# Enterprise HRMS Platform

A full-stack Human Resource Management System built for modern organizations to streamline HR operations, from recruitment to payroll processing.

## Project Overview

This is an enterprise-grade HRMS platform I developed for internal organizational use. The system handles the complete employee lifecycle, including recruitment, onboarding, attendance tracking, leave management, payroll processing, and offboarding. Built with scalability and multi-tenancy in mind, it serves multiple departments within an organization while maintaining strict data isolation.

The application follows a modern monorepo structure with clear separation between the frontend and backend, enabling independent deployment and maintenance cycles.

## Problem Statement

Organizations face several challenges when managing their workforce:

- **Manual HR processes** that consume significant administrative time
- **Scattered data** across multiple spreadsheets and legacy systems
- **Lack of visibility** into workforce metrics and organizational health
- **Compliance risks** from inconsistent policy application
- **Poor employee experience** due to cumbersome request processes
- **Complex payroll calculations** prone to human error

This platform addresses these challenges through automated workflows, centralized data management, and role-based access control.

## Core Features

### 1. Multi-Tenant Organization Management

The system supports multiple organizations within a single deployment, with complete data isolation. Each organization maintains its own:

- Employee database with hierarchical relationships
- Department structure with dedicated managers
- Custom job titles and salary structures
- Leave policies and approval workflows
- Payroll configurations and processing schedules

### 2. Role-Based Access Control

Four distinct user roles ensure appropriate access levels:

**Employee**: Self-service portal for personal profile management, leave applications, attendance tracking, payroll viewing, and request submissions.

**Manager**: Team oversight capabilities including approval workflows for team member requests, recruitment participation, and team performance visibility.

**HR Manager**: Comprehensive HR operations including recruitment management, onboarding coordination, employee data administration, leave management, attendance tracking, payroll preparation, and offboarding processes.

**Admin**: Organization-wide authority over departmental structure, financial oversight, approval configuration, policy management, user permissions, and system-wide analytics.

### 3. Recruitment & Applicant Tracking

Complete recruitment lifecycle management from job posting through candidate selection. HR managers can create and publish job posts to a public careers portal, track applications with status updates, and seamlessly transition selected candidates into the onboarding process.

### 4. Onboarding & Offboarding

**Onboarding** is managed through task-based workflows. HR assigns checklists to new hires covering paperwork completion, equipment provisioning, training schedules, and system access setup. Task progress is tracked through completion states and integrated with the overall onboarding timeline.

**Offboarding** follows a structured clearance process. Initiated when an employee's departure is scheduled, the system manages exit interviews, asset returns, knowledge transfer, and clearance sign-offs from multiple departments. This ensures nothing is missed during the transition.

### 5. Leave Management

Comprehensive leave tracking with policy enforcement:

- **Multiple leave types**: Casual, sick, earned, unpaid, and custom types per organization
- **Annual balance tracking**: Automatic calculation and rollover based on policies
- **Cross-year handling**: Smart splitting of leave requests spanning year boundaries
- **Approval workflows**: Manager and HR approval chains based on leave type
- **Calendar integration**: Visual representation of team availability
- **Balance notifications**: Automated alerts for low balances

### 6. Attendance & Shift Management

Time tracking system with shift support:

- **Flexible shift configuration**: Multiple shift types with configurable timings
- **Clock in/out functionality**: Web-based attendance marking
- **Attendance reports**: Daily, weekly, and monthly summaries
- **Late marking and absence tracking**: Automated flagging of attendance issues
- **Integration with leave system**: Automatic synchronization with approved leaves

### 7. Payroll Processing

Multi-stage payroll workflow designed for accuracy and compliance:

**Draft Stage**: HR creates monthly payroll runs, system calculates base pay from salary structures, applies deductions and additions based on attendance and leave, generates line items for each employee.

**Posted Stage**: Payroll is locked for review, summary reports are generated for finance, approvals are required before processing.

**Processing Stage**: Admin initiates payment processing, system tracks payment status per employee, bulk operations for payment confirmation.

**Paid Stage**: Final confirmation of payment completion, automated payslip generation and distribution, historical records for tax and compliance.

The system handles complex calculations including pro-rata for mid-month joiners and leavers, overtime computation, statutory deductions, and custom components defined per employee.

### 8. Approval System

Centralized approval mechanism handling various request types:

- Leave approvals with multi-level chains
- Attendance regularization requests
- Document access requests
- Custom approval types configurable by organization
- Dashboard views for pending approvals
- History tracking of approval decisions

### 9. Notifications & Activity Tracking

Real-time notification system keeps users informed:

- In-app notifications for pending actions
- Activity logs for audit trails
- Automated alerts for policy violations
- Reminder notifications for pending tasks

### 10. Analytics & Reporting

Executive dashboards and operational reports:

**Admin Dashboard**: Organization-wide metrics including headcount trends, departmental distribution, payroll summaries, leave utilization, recruitment pipeline, and financial projections.

**HR Dashboard**: Operational metrics for day-to-day management including pending approvals, upcoming onboardings, recent hires, active recruitment, and attendance summaries.

**Manager Dashboard**: Team-specific insights including team member status, leave calendars, pending approvals, and team performance indicators.

**Employee Dashboard**: Personal information hub with upcoming leaves, attendance summary, recent payslips, and notification feed.

## Technical Architecture

### System Design

The application follows a client-server architecture with clear separation of concerns:

**Frontend Layer**: Next.js application serving the user interface with server-side rendering for public pages and client-side rendering for authenticated views. Redux Toolkit manages application state with RTK Query handling API communication.

**Backend Layer**: NestJS REST API providing business logic and data access. TypeORM manages database interactions with PostgreSQL.

**Authentication Layer**: Supabase handles user authentication with JWT token management. The backend validates tokens and hydrates user sessions with employee context.

**Database Layer**: PostgreSQL with carefully designed schema supporting multi-tenancy through organization ID scoping on every entity.

### Technology Stack

**Frontend**:
- Next.js 15 with App Router for modern React patterns
- TypeScript for type safety across the codebase
- Tailwind CSS v4 for utility-first styling
- Radix UI components for accessible primitives
- Redux Toolkit with RTK Query for state management
- React Hook Form with Zod for form handling
- Recharts for data visualization
- React Flow for org chart and process visualization
- Framer Motion for animations

**Backend**:
- NestJS 10 with TypeScript
- TypeORM for database abstraction
- PostgreSQL for relational data storage
- Supabase for authentication infrastructure
- Class Validator for DTO validation
- Swagger/OpenAPI for API documentation
- PDFKit for document generation
- Puppeteer for advanced PDF rendering

**Infrastructure**:
- Docker for containerization
- CORS configuration for secure cross-origin requests
- Environment-based configuration management

### Data Model

The database schema is structured around these core entities:

**Organization**: Root entity containing all organizational data with soft delete support.

**Employee**: Central entity representing workforce members with relationships to departments, managers, job titles, and salary structures. Includes employment status tracking and comprehensive profile information.

**Department**: Organizational units with hierarchical relationships and assigned managers.

**Job Title**: Position definitions linked to salary structures and used for organizational classification.

**Leave**: Individual leave requests with status tracking, approval chains, and balance adjustments.

**Leave Policy & Type**: Configurable leave rules with annual allocation, carryover settings, and approval requirements.

**Attendance & Shift**: Time tracking records linked to shift definitions for flexible scheduling.

**Payroll & Items**: Monthly payroll runs with itemized calculations per employee, supporting multiple payment stages.

**Onboarding & Tasks**: Structured onboarding workflows with task assignments and completion tracking.

**Offboarding & Clearance**: Exit process management with clearance requirements from multiple stakeholders.

**Approvals**: Generic approval entity supporting various request types with configurable workflows.

**Notifications**: System-generated alerts for user actions and pending items.

**Activity Log**: Audit trail for all significant actions within the system.

All entities include organization ID for multi-tenant scoping, ensuring complete data isolation between organizations.

### Authentication & Security

The security model implements multiple layers of protection:

**Token Validation**: Every API request requires a valid Supabase JWT token. The backend validates tokens with Supabase's API and rejects invalid or expired tokens immediately.

**User Hydration**: After token validation, the system loads the employee record associated with the Supabase user ID. This enriches the request context with organizational affiliation and role information.

**Role-Based Guards**: NestJS guards check user roles against endpoint requirements. Controllers declare required roles using decorators, and the guard enforces these restrictions before handler execution.

**Active Employee Verification**: Additional guard ensures only active employees can access most endpoints, preventing former employees from accessing the system.

**Multi-Tenancy Enforcement**: Service layer methods explicitly filter all queries by organization ID extracted from the authenticated user. This ensures users can never access data from other organizations, even with direct API calls.

**Data Isolation**: Database queries always include organization ID in WHERE clauses. Repository methods enforce this at the service layer rather than relying on database constraints.

### Key Design Decisions

**Monorepo Structure**: Frontend and backend are maintained in separate directories within a single repository. This facilitates shared type definitions while allowing independent deployment.

**API-First Design**: Backend exposes a comprehensive REST API documented with Swagger. The frontend consumes this API exclusively, enabling future mobile or third-party integrations.

**State Management Strategy**: Redux Toolkit with RTK Query provides caching, automatic refetching, and optimistic updates. This reduces API calls and improves perceived performance.

**Modular Backend**: Each feature domain is encapsulated in a dedicated NestJS module with its own controllers, services, DTOs, and business logic. This enables parallel development and clear ownership.

**Database Transactions**: Critical operations use QueryRunner for ACID transactions. For example, payroll processing updates multiple entities atomically to prevent inconsistent states.

**Activity Logging**: Most mutations trigger activity log entries. This creates an audit trail for compliance and debugging while providing visibility into system usage.

**Soft Deletes**: Important entities use soft delete patterns to preserve historical data. This supports compliance requirements and enables data recovery.

## Implementation Highlights

### 1. Smart Leave Handling

The leave system implements sophisticated logic for cross-year scenarios. When an employee applies for leave spanning two calendar years, the system automatically splits the request into separate leave records for each year, adjusts balances independently, and creates linked approval chains while presenting a unified view to the user.

### 2. Payroll State Machine

Payroll processing follows a strict state progression: Draft → Posted → Processing → Paid. Each transition has specific guards and side effects. For instance, posting a payroll locks all values and triggers financial report generation, while marking as paid generates individual payslips and sends notifications.

### 3. Dynamic Salary Calculations

The salary structure supports a flexible component system. Each employee can have multiple salary components (basic, HRA, allowances, deductions) with percentage or fixed amounts. The payroll service aggregates these components and applies attendance-based adjustments automatically.

### 4. Hierarchical Approvals

The approval system supports multi-level workflows. For example, leave requests above a threshold might require both manager and HR approval. The system tracks approval state across these levels and sends notifications at each stage.

### 5. Onboarding Task Engine

Onboarding tasks can have dependencies and deadlines. The task engine tracks completion percentages, sends reminder notifications as deadlines approach, and blocks certain progressions until prerequisite tasks are complete.

### 6. Real-Time Dashboard Aggregations

Dashboard metrics aggregate data from multiple sources in real-time. For instance, the departmental KPI view parallelizes queries for headcount, payroll, attrition, and attendance, then combines results efficiently.

### 7. Document Management

The system handles various document types: employee documents, onboarding attachments, and offboarding clearances. These are stored in Supabase storage with access control based on user roles and relationships.

### 8. Attendance Regularization

Employees can request attendance corrections for missed clock-ins or anomalies. These requests flow through the approval system and update attendance records retroactively when approved, maintaining audit trails of changes.

## Challenges & Solutions

### Challenge: Multi-Tenant Data Isolation

**Problem**: Ensuring absolute data isolation between organizations in a shared database environment is critical for security and compliance.

**Solution**: Implemented application-level multi-tenancy with organization ID scoping at the service layer. Every service method receives organization ID from the authenticated user context and explicitly includes it in all queries. Guards prevent access to endpoints without proper authentication, and service-level validation ensures organization ID consistency across related entities.

### Challenge: Complex Payroll Calculations

**Problem**: Payroll involves numerous variables including attendance, leaves, pro-rata calculations for mid-month changes, overtime, and custom components.

**Solution**: Designed a component-based salary structure system where each component can be a fixed amount or percentage. The payroll service orchestrates calculation in stages: fetching salary structures, applying attendance adjustments, calculating leave deductions, adding variable components, and finally generating itemized breakdowns. Each stage is independently testable and auditable.

### Challenge: Cross-Year Leave Management

**Problem**: Leave requests spanning calendar year boundaries required special handling for balance tracking and approval workflows.

**Solution**: Implemented automatic leave splitting logic that detects year boundaries, calculates day counts per year, creates separate leave records with maintained relationships, adjusts balances independently per year, and presents a unified view to users while maintaining accurate accounting.

### Challenge: Concurrent Approval Workflows

**Problem**: Multiple users might attempt to approve or reject the same request simultaneously, leading to race conditions.

**Solution**: Used database-level optimistic locking with version fields and transaction isolation. The approval service validates current state before applying changes and returns clear error messages if state has changed since request retrieval.

### Challenge: Performance with Growing Data

**Problem**: Dashboard queries became slower as employee count and historical records grew.

**Solution**: Implemented strategic indexes on frequently queried fields, used parallel query execution for dashboard aggregations where possible, added pagination to list endpoints, and implemented caching strategies in the frontend using RTK Query's automatic cache management.

## Results & Impact

The system successfully manages the complete HR lifecycle for the organization:

- **Reduced administrative overhead** by automating routine HR tasks and approvals
- **Improved data accuracy** through centralized storage and validation
- **Enhanced employee experience** with self-service capabilities and transparent processes
- **Better compliance** through consistent policy application and audit trails
- **Increased visibility** into workforce metrics for strategic decision-making
- **Faster payroll processing** with automated calculations and reduced manual errors

## Future Enhancements

While the current system is production-ready and actively used, several enhancements are planned:

- **Performance reviews module** for structured feedback cycles
- **Training management** for skills development tracking
- **Asset management** for equipment allocation and tracking
- **Mobile applications** for on-the-go access
- **Advanced analytics** with predictive insights
- **Integration APIs** for third-party HR tools
- **Automated report scheduling** and distribution
- **Employee self-service kiosk mode** for field workers

## Architecture Diagram

See [assets/system-architecture.png](assets/system-architecture.png) for a visual representation of the system architecture including frontend-backend separation, authentication flow, database relationships, and external service integrations.

## Database Schema

See [assets/database-schema.png](assets/database-schema.png) for the complete entity-relationship diagram showing all tables, relationships, and key constraints.

## API Design

See [docs/api-design.md](docs/api-design.md) for detailed documentation of API endpoints, request/response formats, and integration patterns.

## Closing Notes

This project demonstrates enterprise application development with careful attention to security, scalability, and user experience. The clean separation of concerns, comprehensive testing coverage, and modular architecture make it maintainable and extensible. While I cannot share the actual code publicly due to organizational policies, this case study provides insight into the technical decisions and implementation details that went into building a production-grade HRMS platform.

The choice of technologies reflects modern best practices: TypeScript for type safety across the stack, NestJS for structured backend development, Next.js for optimal frontend performance, and PostgreSQL for reliable data storage. The result is a robust system that handles complex business logic while remaining intuitive for end users.

---

**Note**: All code and implementation details in this case study are based on a private, production system. Actual implementation may include additional features and optimizations not documented here.
