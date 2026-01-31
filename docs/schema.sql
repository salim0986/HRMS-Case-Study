-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.activity_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid,
  user_id uuid,
  employee_id uuid,
  action character varying NOT NULL,
  meta jsonb,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT activity_logs_pkey PRIMARY KEY (id),
  CONSTRAINT FK_f2a5695f730cbe9bf16eeb74342 FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT FK_d62c4c4e69d9e997a0189f8d1c1 FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);
CREATE TABLE public.applications (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  applicantName character varying NOT NULL,
  email character varying NOT NULL,
  resumeUrl text,
  status USER-DEFINED NOT NULL DEFAULT 'applied'::applications_status_enum,
  applied_at timestamp without time zone NOT NULL DEFAULT now(),
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  job_post_id uuid NOT NULL,
  CONSTRAINT applications_pkey PRIMARY KEY (id),
  CONSTRAINT FK_24456c013c27621eb6ba693c5f1 FOREIGN KEY (job_post_id) REFERENCES public.job_posts(id)
);
CREATE TABLE public.approval_types (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  is_default boolean NOT NULL DEFAULT false,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  CONSTRAINT approval_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.approvals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  title character varying,
  amount numeric,
  priority character varying NOT NULL DEFAULT 'medium'::character varying,
  status character varying NOT NULL DEFAULT 'pending'::character varying,
  meta jsonb,
  approved_by_id uuid,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  requested_by_id uuid,
  type_id uuid NOT NULL,
  rejected_by_id uuid,
  CONSTRAINT approvals_pkey PRIMARY KEY (id),
  CONSTRAINT FK_98c342794c8e0da4e8a16b0afb8 FOREIGN KEY (type_id) REFERENCES public.approval_types(id),
  CONSTRAINT FK_7056401cd7d854d4288449df707 FOREIGN KEY (requested_by_id) REFERENCES public.employees(id),
  CONSTRAINT FK_c0f8aaf8eee5963c9f128d7a8ca FOREIGN KEY (approved_by_id) REFERENCES public.employees(id),
  CONSTRAINT FK_c2ea17a0fcf7edb6ff3ed92360c FOREIGN KEY (rejected_by_id) REFERENCES public.employees(id)
);
CREATE TABLE public.attendance_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  attendance_id uuid,
  employee_id uuid NOT NULL,
  event_time timestamp without time zone NOT NULL,
  event_type character varying NOT NULL,
  source character varying,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT attendance_logs_pkey PRIMARY KEY (id),
  CONSTRAINT FK_6da479342683627ea2d4b8d353d FOREIGN KEY (attendance_id) REFERENCES public.attendances(id),
  CONSTRAINT FK_c4ca4ff3d403535898ba7ae6ba3 FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);
CREATE TABLE public.attendances (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  employeeId uuid NOT NULL,
  date date NOT NULL,
  checkIn timestamp without time zone,
  checkOut timestamp without time zone,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  employee_id uuid,
  deleted_at timestamp without time zone,
  duration_minutes integer,
  note text,
  source character varying,
  status character varying NOT NULL DEFAULT 'present'::character varying,
  CONSTRAINT attendances_pkey PRIMARY KEY (id),
  CONSTRAINT FK_43dca8b4751d7449a38b583991c FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);
CREATE TABLE public.departments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  name character varying NOT NULL,
  manager_id uuid,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  description text,
  CONSTRAINT departments_pkey PRIMARY KEY (id),
  CONSTRAINT FK_71070628c130f2c9cd3cd5f082f FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT FK_ef8a4fb89ff96bbe98f1798798c FOREIGN KEY (manager_id) REFERENCES public.employees(id)
);
CREATE TABLE public.employee_documents (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  employee_id uuid NOT NULL,
  key character varying NOT NULL,
  name character varying NOT NULL,
  mime character varying NOT NULL,
  size integer,
  url character varying,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT employee_documents_pkey PRIMARY KEY (id),
  CONSTRAINT FK_7fce49bcbfe15a73953b2809944 FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);
CREATE TABLE public.employee_leave_balances (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  employeeId uuid NOT NULL,
  leavePolicyId uuid NOT NULL,
  year integer NOT NULL,
  allocated integer NOT NULL,
  used integer NOT NULL DEFAULT 0,
  CONSTRAINT employee_leave_balances_pkey PRIMARY KEY (id),
  CONSTRAINT FK_542b10b59b798e2f301be5b9462 FOREIGN KEY (employeeId) REFERENCES public.employees(id),
  CONSTRAINT FK_65e3f7efa9e370ef432d9c912d6 FOREIGN KEY (leavePolicyId) REFERENCES public.leave_policies(id)
);
CREATE TABLE public.employees (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  employee_code character varying NOT NULL,
  first_name character varying,
  email character varying,
  last_name character varying,
  display_name character varying,
  department_id uuid,
  job_title_id uuid,
  manager_id uuid,
  date_of_joining date,
  status USER-DEFINED NOT NULL DEFAULT 'active'::employees_status_enum,
  employment_type character varying,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  shift_id uuid,
  salary_structure_id uuid,
  role character varying NOT NULL DEFAULT 'employee'::character varying,
  personal_email character varying,
  date_of_birth date,
  gender character varying,
  phone character varying,
  address text,
  city character varying,
  state character varying,
  postal_code character varying,
  country character varying,
  emergency_contact_name character varying,
  emergency_contact_relation character varying,
  emergency_contact_phone character varying,
  emergency_contact_address text,
  bank_name character varying,
  bank_account_number character varying,
  ifsc character varying,
  bank_branch character varying,
  profile_picture_key character varying,
  profile_picture_meta jsonb,
  basic_salary numeric DEFAULT '0'::numeric,
  CONSTRAINT employees_pkey PRIMARY KEY (id),
  CONSTRAINT FK_3d3bc4729062b93fb56b084d786 FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT FK_678a3540f843823784b0fe4a4f2 FOREIGN KEY (department_id) REFERENCES public.departments(id),
  CONSTRAINT FK_93b4141fa0e89839bbdc9936467 FOREIGN KEY (job_title_id) REFERENCES public.job_titles(id),
  CONSTRAINT FK_bcdf921072a19dd2758a628c5c0 FOREIGN KEY (manager_id) REFERENCES public.employees(id),
  CONSTRAINT FK_98e5075745ff16aeca79c12311c FOREIGN KEY (shift_id) REFERENCES public.shifts(id),
  CONSTRAINT FK_a0807928ed0a4ef6742eca1f208 FOREIGN KEY (salary_structure_id) REFERENCES public.salary_structures(id)
);
CREATE TABLE public.events (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  title character varying NOT NULL,
  description text,
  start_ts timestamp without time zone NOT NULL,
  end_ts timestamp without time zone,
  all_day boolean NOT NULL DEFAULT false,
  created_by uuid,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT FK_8557ec49101496ab87be666d633 FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT FK_1a259861a2ce114f074b366eed2 FOREIGN KEY (created_by) REFERENCES public.employees(id)
);
CREATE TABLE public.job_posts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  title character varying NOT NULL,
  department_id uuid,
  description text,
  status USER-DEFINED NOT NULL DEFAULT 'open'::job_posts_status_enum,
  posted_by uuid,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  location character varying,
  CONSTRAINT job_posts_pkey PRIMARY KEY (id),
  CONSTRAINT FK_f698758b46504976d070d4f9566 FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT FK_1abd248a296e0dbde4a5b914a5d FOREIGN KEY (department_id) REFERENCES public.departments(id),
  CONSTRAINT FK_6e25e5a77117fb0b2ec5bf09c86 FOREIGN KEY (posted_by) REFERENCES public.employees(id)
);
CREATE TABLE public.job_titles (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  title character varying NOT NULL UNIQUE,
  description text,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  organizationId uuid,
  CONSTRAINT job_titles_pkey PRIMARY KEY (id),
  CONSTRAINT FK_601ec37cea2a65951fcd1c5f557 FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.leave_policies (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  name character varying NOT NULL UNIQUE,
  description text,
  daysPerYear integer NOT NULL,
  carryForward boolean NOT NULL DEFAULT false,
  maxCarryForward integer NOT NULL DEFAULT 0,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  leave_type_id uuid NOT NULL,
  deleted_at timestamp without time zone,
  CONSTRAINT leave_policies_pkey PRIMARY KEY (id),
  CONSTRAINT FK_9ece4a576e86d5d32145d0b400d FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT FK_145159e6d88d26843a8f9a0928b FOREIGN KEY (leave_type_id) REFERENCES public.leave_types(id)
);
CREATE TABLE public.leave_types (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  maxDays integer,
  carryForward boolean NOT NULL DEFAULT false,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  CONSTRAINT leave_types_pkey PRIMARY KEY (id),
  CONSTRAINT FK_3f75219f68593f74fe0e0f93f55 FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.leaves (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  leave_type_id uuid,
  custom_leave_name character varying,
  start_date date NOT NULL,
  end_date date NOT NULL,
  duration_days integer,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::leaves_status_enum,
  approved_by uuid,
  reason text,
  created_by uuid,
  updated_by uuid,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  employee_id uuid NOT NULL,
  organization_id uuid NOT NULL,
  rejected_by uuid,
  cancelled_by uuid,
  approved_at timestamp without time zone,
  rejected_at timestamp without time zone,
  cancelled_at timestamp without time zone,
  meta jsonb,
  leave_policy_id uuid,
  CONSTRAINT leaves_pkey PRIMARY KEY (id),
  CONSTRAINT FK_b6a3c20c15a1d32d09683fd185f FOREIGN KEY (leave_policy_id) REFERENCES public.leave_policies(id),
  CONSTRAINT FK_f434fa2bee32673ad01d59ea810 FOREIGN KEY (leave_type_id) REFERENCES public.leave_types(id),
  CONSTRAINT FK_9b68981ebf771160d0f6f78ad0f FOREIGN KEY (approved_by) REFERENCES public.employees(id),
  CONSTRAINT FK_29d5827b1f3a86dc19288ec69a5 FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT FK_1772e7a11f3ca7ffba8616ddb5e FOREIGN KEY (rejected_by) REFERENCES public.employees(id),
  CONSTRAINT FK_d934a2eca13f79f1dcc2de867a0 FOREIGN KEY (cancelled_by) REFERENCES public.employees(id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  type character varying NOT NULL,
  payload jsonb,
  read boolean NOT NULL DEFAULT false,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT FK_9a8a82462cab47c73d25f49261f FOREIGN KEY (user_id) REFERENCES public.employees(id)
);
CREATE TABLE public.offboarding_attachments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  offboarding_id uuid NOT NULL,
  fileName character varying NOT NULL,
  fileUrl character varying NOT NULL,
  fileType character varying,
  fileSize integer,
  uploaded_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT offboarding_attachments_pkey PRIMARY KEY (id),
  CONSTRAINT FK_2d70babc35fd57136690add15ab FOREIGN KEY (offboarding_id) REFERENCES public.offboardings(id)
);
CREATE TABLE public.offboarding_tasks (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  offboarding_id uuid NOT NULL,
  title character varying NOT NULL,
  description text,
  owner_id uuid,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::offboarding_tasks_status_enum,
  due_date date,
  completed_at timestamp without time zone,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  CONSTRAINT offboarding_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT FK_3bb616fdb44fdc0a9c40ee6c573 FOREIGN KEY (offboarding_id) REFERENCES public.offboardings(id),
  CONSTRAINT FK_1b3a764e68735fad2745206ac11 FOREIGN KEY (owner_id) REFERENCES public.employees(id)
);
CREATE TABLE public.offboardings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  reason text,
  start_date date,
  last_working_date date,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::offboardings_status_enum,
  created_by uuid,
  updated_by uuid,
  completed_at timestamp without time zone,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  CONSTRAINT offboardings_pkey PRIMARY KEY (id),
  CONSTRAINT FK_b6ad2643246c8175803caba029e FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);
CREATE TABLE public.onboarding_attachments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  onboarding_id uuid NOT NULL,
  fileName character varying NOT NULL,
  fileUrl character varying NOT NULL,
  fileType character varying,
  fileSize integer,
  uploadedAt timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT onboarding_attachments_pkey PRIMARY KEY (id),
  CONSTRAINT FK_c315b1d6d8ae898bd80869ec5d3 FOREIGN KEY (onboarding_id) REFERENCES public.onboardings(id)
);
CREATE TABLE public.onboarding_tasks (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  onboarding_id uuid NOT NULL,
  title character varying NOT NULL,
  description text,
  status USER-DEFINED NOT NULL DEFAULT 'todo'::onboarding_tasks_status_enum,
  due_date date,
  completed_at timestamp without time zone,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  owner_id uuid,
  CONSTRAINT onboarding_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT FK_c3e447b137cdbd15d043c0cb37b FOREIGN KEY (onboarding_id) REFERENCES public.onboardings(id),
  CONSTRAINT FK_a7e7a6dde057730ff739f4f5157 FOREIGN KEY (owner_id) REFERENCES public.employees(id)
);
CREATE TABLE public.onboarding_templates (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  defaultTasks jsonb,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT onboarding_templates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.onboardings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  employee_id uuid NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::onboardings_status_enum,
  start_date date,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  due_date date,
  notes text,
  CONSTRAINT onboardings_pkey PRIMARY KEY (id),
  CONSTRAINT FK_7a27b654eaab5c457f21e081819 FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);
CREATE TABLE public.organizations (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  domain character varying,
  address text,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  CONSTRAINT organizations_pkey PRIMARY KEY (id)
);
CREATE TABLE public.payroll_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  component_name character varying NOT NULL,
  amount numeric NOT NULL,
  payroll_id uuid NOT NULL,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  component_type character varying NOT NULL,
  CONSTRAINT payroll_items_pkey PRIMARY KEY (id),
  CONSTRAINT FK_569877eb7444c99a715f9cc521e FOREIGN KEY (payroll_id) REFERENCES public.payrolls(id)
);
CREATE TABLE public.payrolls (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  month integer NOT NULL,
  year integer NOT NULL,
  basic_salary numeric NOT NULL,
  allowances numeric NOT NULL DEFAULT '0'::numeric,
  deductions numeric NOT NULL DEFAULT '0'::numeric,
  net_salary numeric,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::payrolls_status_enum,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  employee_id uuid NOT NULL,
  payslip_key character varying,
  organization_id uuid NOT NULL,
  CONSTRAINT payrolls_pkey PRIMARY KEY (id),
  CONSTRAINT FK_5145d894f823722a43ec3e1955e FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);
CREATE TABLE public.performance_reviews (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  employeeId uuid NOT NULL,
  reviewer_id uuid,
  review_period character varying,
  rating integer,
  comments text,
  created_by uuid,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  employee_id uuid,
  CONSTRAINT performance_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT FK_2d1d9e46c9f01ac7c07d59b2756 FOREIGN KEY (employee_id) REFERENCES public.employees(id),
  CONSTRAINT FK_2d11995817c8d382fb313dc46cf FOREIGN KEY (reviewer_id) REFERENCES public.employees(id)
);
CREATE TABLE public.salary_components (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  structureId uuid NOT NULL,
  name character varying NOT NULL,
  type character varying NOT NULL,
  percentage numeric,
  fixedAmount numeric,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  structure_id uuid,
  code character varying NOT NULL,
  CONSTRAINT salary_components_pkey PRIMARY KEY (id),
  CONSTRAINT FK_9fe2b3889e8f08f4e801ff2eb05 FOREIGN KEY (structure_id) REFERENCES public.salary_structures(id)
);
CREATE TABLE public.salary_structures (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  name character varying NOT NULL,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT salary_structures_pkey PRIMARY KEY (id),
  CONSTRAINT FK_ce20447e473894d14b8b6083f20 FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.settings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  key character varying NOT NULL,
  value text,
  created_by uuid,
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  deleted_at timestamp without time zone,
  CONSTRAINT settings_pkey PRIMARY KEY (id),
  CONSTRAINT FK_d5bc871126b26b4fb1b9c743825 FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT FK_27b4d13068dc326981eafbd7869 FOREIGN KEY (created_by) REFERENCES public.employees(id)
);
CREATE TABLE public.shifts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  organization_id uuid NOT NULL,
  name character varying NOT NULL,
  startTime time without time zone NOT NULL,
  endTime time without time zone NOT NULL,
  breakMinutes integer NOT NULL DEFAULT 0,
  gracePeriodMinutes integer NOT NULL DEFAULT 10,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT shifts_pkey PRIMARY KEY (id),
  CONSTRAINT FK_6ff650d103d30e94e1e9ea2163a FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);