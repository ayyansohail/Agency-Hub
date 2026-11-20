-- ============================================================
-- AgencyHub — Row Level Security
-- ============================================================

-- ---------- enable RLS everywhere ----------
alter table profiles                 enable row level security;
alter table organizations            enable row level security;
alter table client_companies         enable row level security;
alter table memberships              enable row level security;
alter table invitations              enable row level security;
alter table projects                 enable row level security;
alter table project_members          enable row level security;
alter table tasks                    enable row level security;
alter table task_comments            enable row level security;
alter table deliverables             enable row level security;
alter table deliverable_versions     enable row level security;
alter table version_files            enable row level security;
alter table approvals                enable row level security;
alter table messages                 enable row level security;
alter table activity_log             enable row level security;
alter table time_entries             enable row level security;
alter table checkins                 enable row level security;
alter table notifications            enable row level security;
alter table notification_preferences enable row level security;
alter table webhook_endpoints        enable row level security;

-- ============================================================
-- helper functions
-- security definer so they bypass RLS internally and
-- don't cause infinite recursion on memberships
-- ============================================================

create or replace function is_platform_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select is_platform_admin from profiles where id = auth.uid()), false);
$$;

-- every org the caller belongs to
create or replace function my_org_ids()
returns setof uuid language sql stable security definer set search_path = public as $$
  select org_id from memberships where user_id = auth.uid() and is_active;
$$;

-- caller's role in a given org
create or replace function my_role(p_org uuid)
returns member_role language sql stable security definer set search_path = public as $$
  select role from memberships
  where user_id = auth.uid() and org_id = p_org and is_active
  limit 1;
$$;

-- is the caller staff (not a client) in this org?
create or replace function is_staff(p_org uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from memberships
    where user_id = auth.uid() and org_id = p_org and is_active
      and role in ('owner','manager','employee')
  );
$$;

-- can the caller administer this org?
create or replace function is_admin_of(p_org uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from memberships
    where user_id = auth.uid() and org_id = p_org and is_active
      and role in ('owner','manager')
  );
$$;

-- projects the caller may see:
-- staff see every project in their orgs; clients only ones they're assigned to
create or replace function my_project_ids()
returns setof uuid language sql stable security definer set search_path = public as $$
  select p.id from projects p
  join memberships m
    on m.org_id = p.org_id and m.user_id = auth.uid() and m.is_active
  where m.role in ('owner','manager','employee')
  union
  select pm.project_id from project_members pm
  join projects p2 on p2.id = pm.project_id
  join memberships m2
    on m2.org_id = p2.org_id and m2.user_id = auth.uid() and m2.is_active
  where pm.user_id = auth.uid() and m2.role = 'client';
$$;

-- is the caller a client on this project?
create or replace function is_client_on(p_project uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from project_members pm
    join projects p  on p.id = pm.project_id
    join memberships m on m.org_id = p.org_id and m.user_id = auth.uid() and m.is_active
    where pm.project_id = p_project and pm.user_id = auth.uid() and m.role = 'client'
  );
$$;

-- ============================================================
-- profiles
-- ============================================================
create policy profiles_select on profiles for select using (
  id = auth.uid()
  or is_platform_admin()
  or exists (
    select 1 from memberships a
    join memberships b on a.org_id = b.org_id
    where a.user_id = auth.uid() and a.is_active
      and b.user_id = profiles.id and b.is_active
  )
);
create policy profiles_update on profiles for update using (id = auth.uid());

-- ============================================================
-- organizations
-- ============================================================
create policy orgs_select on organizations for select using (
  id in (select my_org_ids()) or is_platform_admin()
);
create policy orgs_insert on organizations for insert with check (auth.uid() is not null);
create policy orgs_update on organizations for update using (
  is_admin_of(id) or is_platform_admin()
);

-- ============================================================
-- memberships
-- ============================================================
create policy memberships_select on memberships for select using (
  user_id = auth.uid() or org_id in (select my_org_ids()) or is_platform_admin()
);
create policy memberships_insert on memberships for insert with check (
  user_id = auth.uid() or is_admin_of(org_id)
);
create policy memberships_update on memberships for update using (is_admin_of(org_id));
create policy memberships_delete on memberships for delete using (is_admin_of(org_id));

-- ============================================================
-- client companies  (staff only — clients never list companies)
-- ============================================================
create policy clients_select on client_companies for select using (
  (org_id in (select my_org_ids()) and is_staff(org_id)) or is_platform_admin()
);
create policy clients_write on client_companies for all
  using (is_admin_of(org_id)) with check (is_admin_of(org_id));

-- ============================================================
-- invitations  (BR-03: only owner/manager)
-- ============================================================
create policy invitations_select on invitations for select using (is_admin_of(org_id));
create policy invitations_write  on invitations for all
  using (is_admin_of(org_id)) with check (is_admin_of(org_id));

-- ============================================================
-- projects
-- ============================================================
create policy projects_select on projects for select using (
  id in (select my_project_ids()) or is_platform_admin()
);
create policy projects_write on projects for all
  using (is_admin_of(org_id)) with check (is_admin_of(org_id));

create policy project_members_select on project_members for select using (
  project_id in (select my_project_ids())
);
create policy project_members_write on project_members for all using (
  exists (select 1 from projects p where p.id = project_id and is_admin_of(p.org_id))
) with check (
  exists (select 1 from projects p where p.id = project_id and is_admin_of(p.org_id))
);

-- ============================================================
-- tasks  (clients see only client_visible rows)
-- ============================================================
create policy tasks_select on tasks for select using (
  project_id in (select my_project_ids())
  and (is_staff(org_id) or client_visible)
);
create policy tasks_insert on tasks for insert with check (is_staff(org_id));
create policy tasks_update on tasks for update using (
  is_admin_of(org_id) or (is_staff(org_id) and assignee_id = auth.uid())
);
create policy tasks_delete on tasks for delete using (is_admin_of(org_id));

-- ============================================================
-- task comments  (internal_only never reaches a client)
-- ============================================================
create policy task_comments_select on task_comments for select using (
  exists (
    select 1 from tasks t
    where t.id = task_id
      and t.project_id in (select my_project_ids())
      and (is_staff(t.org_id) or (t.client_visible and not internal_only))
  )
);
create policy task_comments_insert on task_comments for insert with check (
  author_id = auth.uid()
  and exists (select 1 from tasks t where t.id = task_id and t.project_id in (select my_project_ids()))
);
create policy task_comments_update on task_comments for update using (author_id = auth.uid());
create policy task_comments_delete on task_comments for delete using (
  author_id = auth.uid() or is_admin_of(org_id)
);

-- ============================================================
-- deliverables
-- ============================================================
create policy deliverables_select on deliverables for select using (
  project_id in (select my_project_ids())
);
create policy deliverables_write on deliverables for all
  using (is_staff(org_id)) with check (is_staff(org_id));

-- FR-DEL-06: a client never sees a draft
create policy versions_select on deliverable_versions for select using (
  exists (
    select 1 from deliverables d
    where d.id = deliverable_id
      and d.project_id in (select my_project_ids())
      and (is_staff(d.org_id) or deliverable_versions.approval_status <> 'draft')
  )
);
create policy versions_insert on deliverable_versions for insert with check (is_staff(org_id));
create policy versions_update on deliverable_versions for update using (
  is_staff(org_id)
  or exists (select 1 from deliverables d where d.id = deliverable_id and is_client_on(d.project_id))
);

create policy version_files_select on version_files for select using (
  exists (
    select 1 from deliverable_versions v
    join deliverables d on d.id = v.deliverable_id
    where v.id = version_id
      and d.project_id in (select my_project_ids())
      and (is_staff(d.org_id) or v.approval_status <> 'draft')
  )
);
create policy version_files_write on version_files for all
  using (is_staff(org_id)) with check (is_staff(org_id));

-- ============================================================
-- approvals  (FR-DEL-07/08 — clients decide, staff can read)
-- ============================================================
create policy approvals_select on approvals for select using (
  exists (
    select 1 from deliverable_versions v
    join deliverables d on d.id = v.deliverable_id
    where v.id = version_id and d.project_id in (select my_project_ids())
  )
);
create policy approvals_insert on approvals for insert with check (
  actor_id = auth.uid()
  and exists (
    select 1 from deliverable_versions v
    join deliverables d on d.id = v.deliverable_id
    where v.id = version_id
      and (is_client_on(d.project_id) or is_admin_of(d.org_id))
  )
);

-- ============================================================
-- messages  (internal_only never reaches a client)
-- ============================================================
create policy messages_select on messages for select using (
  project_id in (select my_project_ids())
  and (is_staff(org_id) or not internal_only)
);
create policy messages_insert on messages for insert with check (
  author_id = auth.uid() and project_id in (select my_project_ids())
);
create policy messages_update on messages for update using (author_id = auth.uid());

-- ============================================================
-- activity log  (insert-only from the app; clients see visible events)
-- ============================================================
create policy activity_select on activity_log for select using (
  (project_id in (select my_project_ids()) and (is_staff(org_id) or client_visible))
  or (project_id is null and org_id in (select my_org_ids()) and is_staff(org_id))
);
create policy activity_insert on activity_log for insert with check (
  org_id in (select my_org_ids())
);

-- ============================================================
-- time entries  (staff only — never a client)
-- ============================================================
create policy time_select on time_entries for select using (
  is_staff(org_id) and (user_id = auth.uid() or is_admin_of(org_id))
);
create policy time_insert on time_entries for insert with check (
  user_id = auth.uid() and is_staff(org_id)
);
create policy time_update on time_entries for update using (user_id = auth.uid());
create policy time_delete on time_entries for delete using (
  user_id = auth.uid() or is_admin_of(org_id)
);

-- ============================================================
-- check-ins
-- ============================================================
create policy checkins_select on checkins for select using (
  is_staff(org_id) and (user_id = auth.uid() or is_admin_of(org_id))
);
create policy checkins_write on checkins for all
  using (user_id = auth.uid()) with check (user_id = auth.uid() and is_staff(org_id));

-- ============================================================
-- notifications & preferences
-- ============================================================
create policy notifications_select on notifications for select using (user_id = auth.uid());
create policy notifications_update on notifications for update using (user_id = auth.uid());
create policy notifications_insert on notifications for insert with check (
  org_id in (select my_org_ids())
);

create policy prefs_all on notification_preferences for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ============================================================
-- webhooks  (owner/manager only)
-- ============================================================
create policy webhooks_all on webhook_endpoints for all
  using (is_admin_of(org_id)) with check (is_admin_of(org_id));