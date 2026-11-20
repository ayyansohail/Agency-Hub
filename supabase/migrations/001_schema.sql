-- ============================================================
-- AgencyHub — initial schema
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- enums ----------
create type member_role       as enum ('owner','manager','employee','client');
create type project_status    as enum ('planning','in_progress','in_review','blocked','completed','archived');
create type task_status       as enum ('todo','in_progress','in_review','blocked','done');
create type task_priority     as enum ('low','medium','high','urgent');
create type approval_status   as enum ('draft','submitted','changes_requested','approved','superseded');
create type review_decision   as enum ('approved','changes_requested');
create type invitation_status as enum ('pending','accepted','revoked','expired');

-- ---------- profiles ----------
create table profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  full_name          text,
  avatar_url         text,
  timezone           text default 'Asia/Karachi',
  is_platform_admin  boolean not null default false,
  created_at         timestamptz not null default now()
);

-- ---------- organizations (tenants) ----------
create table organizations (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  slug         text not null unique,
  logo_url     text,
  accent_color text default '#1F3864',
  is_active    boolean not null default true,
  created_at   timestamptz not null default now()
);

-- ---------- client companies ----------
create table client_companies (
  id            uuid primary key default gen_random_uuid(),
  org_id        uuid not null references organizations(id) on delete cascade,
  company_name  text not null,
  contact_email text,
  is_archived   boolean not null default false,
  created_at    timestamptz not null default now()
);

-- ---------- memberships ----------
create table memberships (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organizations(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  role       member_role not null,
  client_id  uuid references client_companies(id) on delete cascade,
  is_active  boolean not null default true,
  created_at timestamptz not null default now(),
  unique (org_id, user_id),
  constraint client_role_requires_company check (
    (role = 'client'  and client_id is not null) or
    (role <> 'client' and client_id is null)
  )
);

-- ---------- invitations ----------
create table invitations (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references organizations(id) on delete cascade,
  email       text not null,
  role        member_role not null,
  client_id   uuid references client_companies(id) on delete cascade,
  token       text not null unique,
  status      invitation_status not null default 'pending',
  invited_by  uuid references profiles(id),
  expires_at  timestamptz not null default (now() + interval '7 days'),
  accepted_at timestamptz,
  created_at  timestamptz not null default now()
);

-- ---------- projects ----------
create table projects (
  id                       uuid primary key default gen_random_uuid(),
  org_id                   uuid not null references organizations(id) on delete cascade,
  client_id                uuid not null references client_companies(id) on delete cascade,
  name                     text not null,
  description              text,
  status                   project_status not null default 'planning',
  start_date               date,
  due_date                 date,
  included_revision_rounds int not null default 3,
  show_assignee_to_client  boolean not null default false,
  meeting_link             text,
  is_archived              boolean not null default false,
  created_at               timestamptz not null default now()
);

create table project_members (
  id         uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (project_id, user_id)
);

-- ---------- tasks ----------
create table tasks (
  id             uuid primary key default gen_random_uuid(),
  org_id         uuid not null references organizations(id) on delete cascade,
  project_id     uuid not null references projects(id) on delete cascade,
  title          text not null,
  description    text,
  status         task_status not null default 'todo',
  priority       task_priority not null default 'medium',
  assignee_id    uuid references profiles(id) on delete set null,
  due_date       date,
  position       int not null default 0,
  client_visible boolean not null default false,
  is_archived    boolean not null default false,
  created_by     uuid references profiles(id),
  created_at     timestamptz not null default now()
);

create table task_comments (
  id            uuid primary key default gen_random_uuid(),
  org_id        uuid not null references organizations(id) on delete cascade,
  task_id       uuid not null references tasks(id) on delete cascade,
  author_id     uuid not null references profiles(id) on delete cascade,
  body          text not null,
  internal_only boolean not null default true,
  created_at    timestamptz not null default now()
);

-- ---------- deliverables ----------
create table deliverables (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organizations(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  task_id    uuid references tasks(id) on delete set null,
  title      text not null,
  created_at timestamptz not null default now()
);

create table deliverable_versions (
  id              uuid primary key default gen_random_uuid(),
  org_id          uuid not null references organizations(id) on delete cascade,
  deliverable_id  uuid not null references deliverables(id) on delete cascade,
  version_no      int not null,
  submitted_by    uuid references profiles(id),
  submission_note text,
  approval_status approval_status not null default 'draft',
  submitted_at    timestamptz,
  created_at      timestamptz not null default now(),
  unique (deliverable_id, version_no)
);

create table version_files (
  id           uuid primary key default gen_random_uuid(),
  org_id       uuid not null references organizations(id) on delete cascade,
  version_id   uuid not null references deliverable_versions(id) on delete cascade,
  storage_path text not null,
  file_name    text not null,
  mime_type    text,
  size_bytes   bigint,
  created_at   timestamptz not null default now()
);

create table approvals (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organizations(id) on delete cascade,
  version_id uuid not null references deliverable_versions(id) on delete cascade,
  actor_id   uuid not null references profiles(id),
  decision   review_decision not null,
  note       text,
  created_at timestamptz not null default now(),
  constraint changes_require_note check (
    decision = 'approved' or (note is not null and length(trim(note)) > 0)
  )
);

-- ---------- collaboration ----------
create table messages (
  id            uuid primary key default gen_random_uuid(),
  org_id        uuid not null references organizations(id) on delete cascade,
  project_id    uuid not null references projects(id) on delete cascade,
  author_id     uuid not null references profiles(id) on delete cascade,
  body          text not null,
  internal_only boolean not null default true,
  created_at    timestamptz not null default now()
);

create table activity_log (
  id             uuid primary key default gen_random_uuid(),
  org_id         uuid not null references organizations(id) on delete cascade,
  project_id     uuid references projects(id) on delete cascade,
  actor_id       uuid references profiles(id) on delete set null,
  verb           text not null,
  entity_type    text not null,
  entity_id      uuid,
  meta           jsonb,
  client_visible boolean not null default false,
  created_at     timestamptz not null default now()
);

-- ---------- time & workload ----------
create table time_entries (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organizations(id) on delete cascade,
  task_id    uuid not null references tasks(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  entry_date date not null default current_date,
  minutes    int not null check (minutes > 0),
  note       text,
  created_at timestamptz not null default now()
);

create table checkins (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organizations(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  entry_date date not null default current_date,
  did        text,
  doing      text,
  blockers   text,
  created_at timestamptz not null default now(),
  unique (org_id, user_id, entry_date)
);

-- ---------- notifications ----------
create table notifications (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references organizations(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  type        text not null,
  payload     jsonb,
  is_urgent   boolean not null default false,
  read_at     timestamptz,
  created_at  timestamptz not null default now()
);

create table notification_preferences (
  user_id      uuid primary key references profiles(id) on delete cascade,
  daily_digest boolean not null default true
);

create table webhook_endpoints (
  id        uuid primary key default gen_random_uuid(),
  org_id    uuid not null references organizations(id) on delete cascade,
  url       text not null,
  events    text[] not null default '{}',
  is_active boolean not null default true
);

-- ---------- indexes ----------
create index on memberships (user_id);
create index on memberships (org_id, role);
create index on client_companies (org_id);
create index on invitations (token);
create index on invitations (org_id, status);
create index on projects (org_id);
create index on projects (client_id);
create index on project_members (user_id);
create index on tasks (project_id, status);
create index on tasks (assignee_id);
create index on tasks (org_id, due_date);
create index on task_comments (task_id);
create index on deliverables (project_id);
create index on deliverable_versions (deliverable_id);
create index on version_files (version_id);
create index on approvals (version_id);
create index on messages (project_id, created_at desc);
create index on activity_log (project_id, created_at desc);
create index on time_entries (user_id, entry_date);
create index on time_entries (task_id);
create index on notifications (user_id, read_at);

-- ---------- auto-create profile on signup ----------
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''));
  insert into notification_preferences (user_id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();