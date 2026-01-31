# Database Schema Diagram

## Core Entity Relationships

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ EMPLOYEES : contains
    ORGANIZATIONS ||--o{ DEPARTMENTS : contains
    ORGANIZATIONS ||--o{ JOB_TITLES : defines
    ORGANIZATIONS ||--o{ LEAVE_TYPES : configures
    ORGANIZATIONS ||--o{ SHIFTS : defines
    ORGANIZATIONS ||--o{ SALARY_STRUCTURES : configures
    ORGANIZATIONS ||--o{ PAYROLLS : manages
    
    EMPLOYEES ||--o| DEPARTMENTS : "belongs to"
    EMPLOYEES ||--o| JOB_TITLES : "has"
    EMPLOYEES ||--o| EMPLOYEES : "reports to"
    EMPLOYEES ||--o| SHIFTS : "assigned to"
    EMPLOYEES ||--o| SALARY_STRUCTURES : "has"
    EMPLOYEES ||--o{ LEAVES : "applies"
    EMPLOYEES ||--o{ ATTENDANCE : "records"
    EMPLOYEES ||--o{ EMPLOYEE_LEAVE_BALANCES : "has"
    EMPLOYEES ||--o{ ONBOARDING : "undergoes"
    EMPLOYEES ||--o{ OFFBOARDING : "undergoes"
    EMPLOYEES ||--o{ NOTIFICATIONS : "receives"
    
    DEPARTMENTS ||--o| EMPLOYEES : "managed by"
    DEPARTMENTS ||--o| DEPARTMENTS : "parent of"
    
    LEAVE_TYPES ||--o{ LEAVES : categorizes
    LEAVE_TYPES ||--o{ EMPLOYEE_LEAVE_BALANCES : tracks
    LEAVE_TYPES ||--o{ LEAVE_POLICIES : governed
    
    PAYROLLS ||--o{ PAYROLL_ITEMS : contains
    PAYROLL_ITEMS ||--|| EMPLOYEES : "for employee"
    
    SALARY_STRUCTURES ||--o{ SALARY_COMPONENTS : defines
    
    ONBOARDING ||--o{ ONBOARDING_TASKS : includes
    OFFBOARDING ||--o{ OFFBOARDING_CLEARANCES : requires
    
    JOB_POSTS ||--o{ APPLICATIONS : receives
    JOB_POSTS ||--o| DEPARTMENTS : "for"
    
    APPROVALS ||--|| EMPLOYEES : "requested by"
    APPROVALS ||--|| EMPLOYEES : "approved by"
    APPROVALS ||--|| APPROVAL_TYPES : "of type"
    
    ORGANIZATIONS {
        uuid id PK
        varchar name
        varchar domain UK
        text address
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }
    
    EMPLOYEES {
        uuid id PK
        uuid organization_id FK
        varchar employee_code UK
        varchar first_name
        varchar last_name
        varchar email
        enum role
        enum status
        uuid department_id FK
        uuid job_title_id FK
        uuid manager_id FK
        date date_of_joining
        uuid shift_id FK
        uuid salary_structure_id FK
    }
    
    DEPARTMENTS {
        uuid id PK
        uuid organization_id FK
        varchar name
        varchar code
        uuid manager_id FK
        uuid parent_department_id FK
    }
    
    LEAVES {
        uuid id PK
        uuid employee_id FK
        uuid leave_type_id FK
        date start_date
        date end_date
        decimal total_days
        enum status
        text reason
        uuid approved_by FK
    }
    
    PAYROLLS {
        uuid id PK
        uuid organization_id FK
        varchar month
        varchar title
        enum status
        date payment_date
    }
    
    PAYROLL_ITEMS {
        uuid id PK
        uuid payroll_id FK
        uuid employee_id FK
        decimal gross_salary
        decimal deductions
        decimal net_salary
        enum status
    }
```

## Leave Management Schema

```mermaid
erDiagram
    LEAVE_TYPES ||--o{ LEAVE_POLICIES : "governed by"
    LEAVE_TYPES ||--o{ EMPLOYEE_LEAVE_BALANCES : "tracks"
    LEAVE_TYPES ||--o{ LEAVES : "categorizes"
    EMPLOYEES ||--o{ EMPLOYEE_LEAVE_BALANCES : "has"
    EMPLOYEES ||--o{ LEAVES : "applies"
    ORGANIZATIONS ||--o{ LEAVE_TYPES : "defines"
    
    LEAVE_TYPES {
        uuid id PK
        uuid organization_id FK
        varchar name
        varchar code
        int annual_allocation
        boolean carry_forward_allowed
        boolean requires_approval
        int max_consecutive_days
        boolean allow_half_day
    }
    
    LEAVE_POLICIES {
        uuid id PK
        uuid organization_id FK
        uuid leave_type_id FK
        int year
        decimal annual_allocation
        decimal max_carryforward
        text rules_json
        timestamp created_at
    }
    
    EMPLOYEE_LEAVE_BALANCES {
        uuid id PK
        uuid employee_id FK
        uuid leave_type_id FK
        int year
        decimal allocated
        decimal used
        decimal pending
        decimal available
        decimal carried_forward
    }
    
    LEAVES {
        uuid id PK
        uuid employee_id FK
        uuid leave_type_id FK
        date start_date
        date end_date
        decimal total_days
        enum status
        text reason
        boolean half_day
        uuid approved_by FK
        timestamp approved_at
        text rejection_reason
        timestamp created_at
    }
```

## Payroll Schema

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ SALARY_STRUCTURES : configures
    ORGANIZATIONS ||--o{ PAYROLLS : manages
    SALARY_STRUCTURES ||--o{ SALARY_COMPONENTS : contains
    SALARY_STRUCTURES ||--o{ EMPLOYEES : "assigned to"
    PAYROLLS ||--o{ PAYROLL_ITEMS : contains
    PAYROLL_ITEMS }o--|| EMPLOYEES : "for"
    
    SALARY_STRUCTURES {
        uuid id PK
        uuid organization_id FK
        varchar name
        text description
        boolean is_active
        timestamp created_at
    }
    
    SALARY_COMPONENTS {
        uuid id PK
        uuid salary_structure_id FK
        varchar name
        enum type
        enum calculation_type
        decimal amount
        decimal percentage
        int display_order
        boolean is_taxable
    }
    
    PAYROLLS {
        uuid id PK
        uuid organization_id FK
        varchar month
        varchar title
        enum status
        date payment_date
        decimal total_gross
        decimal total_deductions
        decimal total_net
        text notes
        timestamp created_at
        uuid created_by FK
    }
    
    PAYROLL_ITEMS {
        uuid id PK
        uuid payroll_id FK
        uuid employee_id FK
        decimal base_salary
        decimal gross_salary
        decimal total_earnings
        decimal total_deductions
        decimal net_salary
        enum status
        int working_days
        int present_days
        text breakdown_json
        timestamp processed_at
    }
```

## Attendance & Shift Schema

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ SHIFTS : defines
    SHIFTS ||--o{ EMPLOYEES : "assigned to"
    EMPLOYEES ||--o{ ATTENDANCE : records
    ATTENDANCE ||--o{ ATTENDANCE_LOGS : "has logs"
    
    SHIFTS {
        uuid id PK
        uuid organization_id FK
        varchar name
        time start_time
        time end_time
        int grace_period_minutes
        int total_hours
        boolean is_active
        varchar days_applicable
    }
    
    ATTENDANCE {
        uuid id PK
        uuid employee_id FK
        uuid shift_id FK
        date date
        timestamp clock_in
        timestamp clock_out
        enum status
        int total_minutes
        boolean is_late
        text notes
        timestamp created_at
    }
    
    ATTENDANCE_LOGS {
        uuid id PK
        uuid attendance_id FK
        enum action
        timestamp timestamp
        varchar location
        uuid recorded_by FK
        text remarks
    }
```

## Onboarding & Offboarding Schema

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ ONBOARDING : manages
    EMPLOYEES ||--|| ONBOARDING : undergoes
    ONBOARDING ||--o{ ONBOARDING_TASKS : includes
    ONBOARDING ||--o{ ONBOARDING_ATTACHMENTS : contains
    
    ORGANIZATIONS ||--o{ OFFBOARDING : manages
    EMPLOYEES ||--|| OFFBOARDING : undergoes
    OFFBOARDING ||--o{ OFFBOARDING_CLEARANCES : requires
    OFFBOARDING ||--o{ OFFBOARDING_ATTACHMENTS : contains
    
    ONBOARDING {
        uuid id PK
        uuid organization_id FK
        uuid employee_id FK
        date start_date
        enum status
        uuid mentor_id FK
        date completion_date
        text notes
        timestamp created_at
    }
    
    ONBOARDING_TASKS {
        uuid id PK
        uuid onboarding_id FK
        varchar title
        text description
        enum status
        enum priority
        date due_date
        timestamp completed_at
        uuid assigned_to FK
        int display_order
    }
    
    OFFBOARDING {
        uuid id PK
        uuid organization_id FK
        uuid employee_id FK
        date last_working_day
        enum reason
        enum status
        text exit_interview_notes
        date exit_interview_date
        uuid initiated_by FK
        timestamp created_at
    }
    
    OFFBOARDING_CLEARANCES {
        uuid id PK
        uuid offboarding_id FK
        varchar department
        varchar item
        enum status
        uuid assigned_to FK
        timestamp cleared_at
        text notes
    }
```

## Recruitment Schema

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ JOB_POSTS : creates
    DEPARTMENTS ||--o{ JOB_POSTS : "for"
    JOB_TITLES ||--o{ JOB_POSTS : "for position"
    JOB_POSTS ||--o{ APPLICATIONS : receives
    
    JOB_POSTS {
        uuid id PK
        uuid organization_id FK
        varchar title
        uuid department_id FK
        uuid job_title_id FK
        text description
        text requirements
        varchar location
        enum employment_type
        enum status
        date posted_date
        date closing_date
        int positions_available
        timestamp created_at
    }
    
    APPLICATIONS {
        uuid id PK
        uuid job_post_id FK
        varchar first_name
        varchar last_name
        varchar email
        varchar phone
        varchar resume_url
        varchar cover_letter_url
        varchar linkedin_url
        enum status
        date applied_date
        text notes
        uuid reviewed_by FK
        timestamp reviewed_at
    }
```

## Approvals & Notifications Schema

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ APPROVAL_TYPES : configures
    APPROVAL_TYPES ||--o{ APPROVALS : categorizes
    EMPLOYEES ||--o{ APPROVALS : requests
    EMPLOYEES ||--o{ APPROVALS : approves
    EMPLOYEES ||--o{ NOTIFICATIONS : receives
    
    APPROVAL_TYPES {
        uuid id PK
        uuid organization_id FK
        varchar name
        varchar code
        text description
        json workflow_config
        boolean is_active
    }
    
    APPROVALS {
        uuid id PK
        uuid organization_id FK
        uuid approval_type_id FK
        uuid requester_id FK
        uuid approver_id FK
        varchar related_entity_type
        uuid related_entity_id
        enum status
        text request_details
        text comments
        text rejection_reason
        timestamp decision_date
        timestamp created_at
    }
    
    NOTIFICATIONS {
        uuid id PK
        uuid employee_id FK
        varchar title
        text message
        varchar type
        varchar related_entity_type
        uuid related_entity_id
        boolean is_read
        timestamp read_at
        timestamp created_at
    }
    
    ACTIVITY_LOG {
        uuid id PK
        uuid organization_id FK
        uuid actor_id FK
        varchar action
        varchar entity_type
        uuid entity_id
        json details
        varchar ip_address
        timestamp timestamp
    }
```

## Core Entity Details

### Organization Entity (Root)
```
organizations
├─ id (PK, UUID)
├─ name (VARCHAR)
├─ domain (VARCHAR, UNIQUE)
├─ address (TEXT)
├─ created_at (TIMESTAMP)
├─ updated_at (TIMESTAMP)
└─ deleted_at (TIMESTAMP, nullable)
```

### Employee Entity (Central)
```
employees
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ employee_code (VARCHAR, UNIQUE)
├─ first_name (VARCHAR)
├─ last_name (VARCHAR)
├─ email (VARCHAR)
├─ display_name (VARCHAR)
├─ role (ENUM: employee, manager, hr_manager, admin)
├─ status (ENUM: active, inactive, on_leave, terminated)
├─ department_id (FK → departments)
├─ job_title_id (FK → job_titles)
├─ manager_id (FK → employees, self-reference)
├─ date_of_joining (DATE)
├─ date_of_birth (DATE)
├─ employment_type (ENUM: full_time, part_time, contract)
├─ phone (VARCHAR)
├─ address (TEXT)
├─ shift_id (FK → shifts)
├─ salary_structure_id (FK → salary_structures)
└─ ... (more profile fields)
```

### Department Entity
```
departments
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ name (VARCHAR)
├─ code (VARCHAR)
├─ manager_id (FK → employees)
└─ parent_department_id (FK → departments, for hierarchy)
```

### Leave Management
```
leave_types
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ name (VARCHAR)
├─ code (VARCHAR)
├─ annual_allocation (INT)
├─ carry_forward_allowed (BOOLEAN)
└─ requires_approval (BOOLEAN)

leave_policies
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ leave_type_id (FK → leave_types)
└─ ... (policy rules)

employee_leave_balances
├─ id (PK, UUID)
├─ employee_id (FK → employees)
├─ leave_type_id (FK → leave_types)
├─ year (INT)
├─ allocated (DECIMAL)
├─ used (DECIMAL)
├─ pending (DECIMAL)
└─ available (DECIMAL)

leaves
├─ id (PK, UUID)
├─ employee_id (FK → employees)
├─ leave_type_id (FK → leave_types)
├─ start_date (DATE)
├─ end_date (DATE)
├─ total_days (DECIMAL)
├─ status (ENUM: pending, approved, rejected, cancelled)
├─ reason (TEXT)
└─ approved_by (FK → employees)
```

### Attendance
```
shifts
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ name (VARCHAR)
├─ start_time (TIME)
├─ end_time (TIME)
└─ grace_period_minutes (INT)

attendance
├─ id (PK, UUID)
├─ employee_id (FK → employees)
├─ shift_id (FK → shifts)
├─ date (DATE)
├─ clock_in (TIMESTAMP)
├─ clock_out (TIMESTAMP)
├─ status (ENUM: present, absent, late, half_day)
└─ ... (additional fields)

attendance_logs
├─ id (PK, UUID)
├─ attendance_id (FK → attendance)
├─ action (ENUM: clock_in, clock_out, edit)
├─ timestamp (TIMESTAMP)
└─ location (VARCHAR)
```

### Payroll
```
salary_structures
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ name (VARCHAR)
└─ ... (structure details)

salary_components
├─ id (PK, UUID)
├─ salary_structure_id (FK → salary_structures)
├─ name (VARCHAR)
├─ type (ENUM: earning, deduction)
├─ calculation_type (ENUM: fixed, percentage)
└─ amount (DECIMAL)

payrolls
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ month (VARCHAR) // YYYY-MM format
├─ title (VARCHAR)
├─ status (ENUM: draft, posted, processing, paid)
├─ payment_date (DATE)
└─ ... (metadata)

payroll_items
├─ id (PK, UUID)
├─ payroll_id (FK → payrolls)
├─ employee_id (FK → employees)
├─ gross_salary (DECIMAL)
├─ deductions (DECIMAL)
├─ net_salary (DECIMAL)
├─ status (ENUM: pending, paid, on_hold)
└─ ... (itemized breakdown)
```

### Onboarding & Offboarding
```
onboarding
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ employee_id (FK → employees)
├─ start_date (DATE)
├─ status (ENUM: pending, in_progress, completed, cancelled)
├─ mentor_id (FK → employees)
└─ completion_date (DATE)

onboarding_tasks
├─ id (PK, UUID)
├─ onboarding_id (FK → onboarding)
├─ title (VARCHAR)
├─ description (TEXT)
├─ status (ENUM: pending, in_progress, completed)
├─ due_date (DATE)
└─ completed_at (TIMESTAMP)

offboarding
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ employee_id (FK → employees)
├─ last_working_day (DATE)
├─ reason (ENUM: resignation, termination, retirement)
└─ status (ENUM: initiated, in_progress, completed)

offboarding_clearances
├─ id (PK, UUID)
├─ offboarding_id (FK → offboarding)
├─ department (VARCHAR)
├─ item (VARCHAR)
├─ assigned_to (FK → employees)
└─ status (ENUM: pending, cleared)
```

### Recruitment
```
job_posts
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ title (VARCHAR)
├─ department_id (FK → departments)
├─ job_title_id (FK → job_titles)
├─ description (TEXT)
├─ requirements (TEXT)
├─ location (VARCHAR)
├─ type (ENUM: full_time, part_time, contract)
├─ status (ENUM: draft, published, closed)
└─ posted_date (DATE)

applications
├─ id (PK, UUID)
├─ job_post_id (FK → job_posts)
├─ first_name (VARCHAR)
├─ last_name (VARCHAR)
├─ email (VARCHAR)
├─ phone (VARCHAR)
├─ resume_url (VARCHAR)
├─ status (ENUM: received, screening, interview, offered, rejected)
└─ applied_date (DATE)
```

### Approvals & Notifications
```
approval_types
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ name (VARCHAR)
└─ workflow_config (JSON)

approvals
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ approval_type_id (FK → approval_types)
├─ requester_id (FK → employees)
├─ approver_id (FK → employees)
├─ related_entity_type (VARCHAR)
├─ related_entity_id (UUID)
├─ status (ENUM: pending, approved, rejected)
└─ decision_date (TIMESTAMP)

notifications
├─ id (PK, UUID)
├─ employee_id (FK → employees)
├─ title (VARCHAR)
├─ message (TEXT)
├─ type (VARCHAR)
├─ is_read (BOOLEAN)
└─ created_at (TIMESTAMP)

activity_log
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ actor_id (FK → employees)
├─ action (VARCHAR)
├─ entity_type (VARCHAR)
├─ entity_id (UUID)
├─ details (JSON)
└─ timestamp (TIMESTAMP)
```

### Job Titles
```
job_titles
├─ id (PK, UUID)
├─ organization_id (FK → organizations)
├─ title (VARCHAR)
├─ level (INT)
└─ description (TEXT)
```

### Documents
```
employee_documents
├─ id (PK, UUID)
├─ employee_id (FK → employees)
├─ document_type (VARCHAR)
├─ file_url (VARCHAR)
├─ uploaded_at (TIMESTAMP)
└─ uploaded_by (FK → employees)
```

## Relationship Types:

- **One-to-Many**: Organization → Employees, Department → Employees
- **Many-to-One**: Employee → Department, Employee → Manager
- **Self-Referencing**: Employee → Manager (both are employees)
- **Optional Relationships**: Employee → Shift (nullable)

## Key Indexes:

- `employees.employee_code` (UNIQUE)
- `employees.organization_id` (for multi-tenant queries)
- `leaves.employee_id, leaves.start_date`
- `attendance.employee_id, attendance.date`
- `payroll_items.payroll_id, payroll_items.employee_id`
- `organizations.domain` (UNIQUE)

## Design Notes:

1. All entities have `organization_id` for multi-tenancy (except Organization itself)
2. Most entities include `created_at`, `updated_at` timestamps
3. Some entities support soft deletes with `deleted_at`
4. Foreign key constraints enforce referential integrity
5. Indexes are critical for query performance at scale
6. UUID primary keys provide globally unique identifiers
7. ENUM types ensure data consistency for status fields
