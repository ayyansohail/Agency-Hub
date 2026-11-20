-- ============================================================
-- AgencyHub — 004 performance fixes
--
-- Addresses three Supabase database-linter findings:
--   1. auth_rls_initplan          — auth.uid() re-evaluated per row
--   2. multiple_permissive_policies — FOR ALL policies overlapping FOR SELECT
--   3. unindexed_foreign_keys     — FKs without a covering index
--
-- No access rule changes. Every policy below enforces exactly what
-- 002_rls.sql enforced; only the evaluation strategy changes.
-- ============================================================


-- ============================================================
-- 1. auth_rls_initplan
--    auth.uid() wrapped as (select auth.uid()) so Postgres
--    evaluates it once per query instead of once per row.
-- ============================================================

-- ---------- profiles ----------
drop policy if exists profiles_select on profiles;
create policy profiles_select on profiles for select using (
  id = (select auth.uid())
  or is_platform_admin()
  or exists (
    select 1 from memberships a
    join memberships b on a.org_id = b.org_id
    where a.user_id = (select auth.uid()) and a.is_active
      and b.user_id = profiles.id and b.is_active
  )
);

drop policy if exists profiles_update on profiles;
create policy profiles_update on profiles for update
  using (id = (select auth.uid()));

-- ---------- organizations ----------
drop policy if exists orgs_insert on organizations;
create policy orgs_insert on organizations for insert
  with check ((select auth.uid()) is not null);

-- ---------- memberships ----------
drop policy if exists memberships_select on memberships;
create policy memberships_select on memberships for select using (
  user_id = (select auth.uid())
  or org_id in (select my_org_ids())
  or is_platform_admin()
);

drop policy if exists memberships_insert on memberships;
create policy memberships_insert on memberships for insert with check (
  user_id = (select auth.uid()) or is_admin_of(org_id)
);

-- ---------- tasks ----------
drop policy if exists tasks_update on tasks;
create policy tasks_update on tasks for update using (
  is_admin_of(org_id)
  or (is_staff(org_id) and assignee_id = (select auth.uid()))
);

-- ---------- task comments ----------
drop policy if exists task_comments_insert on task_comments;
create policy task_comments_insert on task_comments for insert with check (
  author_id = (select auth.uid())
  and exists (
    select 1 from tasks t
    where t.id = task_id and t.project_id in (select my_project_ids())
  )
);

drop policy if exists task_comments_update on task_comments;
create policy task_comments_update on task_comments for update
  using (author_id = (select auth.uid()));

drop policy if exists task_comments_delete on task_comments;
create policy task_comments_delete on task_comments for delete using (
  author_id = (select auth.uid()) or is_admin_of(org_id)
);

-- ---------- approvals ----------
drop policy if exists approvals_insert on approvals;
create policy approvals_insert on approvals for insert with check (
  actor_id = (select auth.uid())
  and exists (
    select 1 from deliverable_versions v
    join deliverables d on d.id = v.deliverable_id
    where v.id = version_id
      and (is_client_on(d.project_id) or is_admin_of(d.org_id))
  )
);

-- ---------- messages ----------
drop policy if exists messages_insert on messages;
create policy messages_insert on messages for insert with check (
  author_id = (select auth.uid())
  and project_id in (select my_project_ids())
);

drop policy if exists messages_update on messages;
create policy messages_update on messages for update
  using (author_id = (select auth.uid()));

-- ---------- time entries ----------
drop policy if exists time_select on time_entries;
create policy time_select on time_entries for select using (
  is_staff(org_id)
  and (user_id = (select auth.uid()) or is_admin_of(org_id))
);

drop policy if exists time_insert on time_entries;
create policy time_insert on time_entries for insert with check (
  user_id = (select auth.uid()) and is_staff(org_id)
);

drop policy if exists time_update on time_entries;
create policy time_update on time_entries for update
  using (user_id = (select auth.uid()));

drop policy if exists time_delete on time_entries;
create policy time_delete on time_entries for delete using (
  user_id = (select auth.uid()) or is_admin_of(org_id)
);

-- ---------- notifications ----------
drop policy if exists notifications_select on notifications;
create policy notifications_select on notifications for select
  using (user_id = (select auth.uid()));

drop policy if exists notifications_update on notifications;
create policy notifications_update on notifications for update
  using (user_id = (select auth.uid()));

-- ---------- notification preferences ----------
drop policy if exists prefs_all on notification_preferences;
create policy prefs_select on notification_preferences for select
  using (user_id = (select auth.uid()));
create policy prefs_insert on notification_preferences for insert
  with check (user_id = (select auth.uid()));
create policy prefs_update on notification_preferences for update
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));


-- ============================================================
-- 2. multiple_permissive_policies
--    FOR ALL policies also applied to SELECT, duplicating the
--    dedicated SELECT policy. Split into insert/update/delete.
-- ============================================================

-- ---------- client_companies ----------
drop policy if exists clients_write on client_companies;
create policy clients_insert on client_companies for insert
  with check (is_admin_of(org_id));
create policy clients_update on client_companies for update
  using (is_admin_of(org_id)) with check (is_admin_of(org_id));
create policy clients_delete on client_companies for delete
  using (is_admin_of(org_id));

-- ---------- invitations ----------
drop policy if exists invitations_write on invitations;
create policy invitations_insert on invitations for insert
  with check (is_admin_of(org_id));
create policy invitations_update on invitations for update
  using (is_admin_of(org_id)) with check (is_admin_of(org_id));
create policy invitations_delete on invitations for delete
  using (is_admin_of(org_id));

-- ---------- projects ----------
drop policy if exists projects_write on projects;
create policy projects_insert on projects for insert
  with check (is_admin_of(org_id));
create policy projects_update on projects for update
  using (is_admin_of(org_id)) with check (is_admin_of(org_id));
create policy projects_delete on projects for delete
  using (is_admin_of(org_id));

-- ---------- project_members ----------
drop policy if exists project_members_write on project_members;
create policy project_members_insert on project_members for insert with check (
  exists (select 1 from projects p where p.id = project_id and is_admin_of(p.org_id))
);
create policy project_members_update on project_members for update using (
  exists (select 1 from projects p where p.id = project_id and is_admin_of(p.org_id))
) with check (
  exists (select 1 from projects p where p.id = project_id and is_admin_of(p.org_id))
);
create policy project_members_delete on project_members for delete using (
  exists (select 1 from projects p where p.id = project_id and is_admin_of(p.org_id))
);

-- ---------- deliverables ----------
drop policy if exists deliverables_write on deliverables;
create policy deliverables_insert on deliverables for insert
  with check (is_staff(org_id));
create policy deliverables_update on deliverables for update
  using (is_staff(org_id)) with check (is_staff(org_id));
create policy deliverables_delete on deliverables for delete
  using (is_staff(org_id));

-- ---------- version_files ----------
drop policy if exists version_files_write on version_files;
create policy version_files_insert on version_files for insert
  with check (is_staff(org_id));
create policy version_files_update on version_files for update
  using (is_staff(org_id)) with check (is_staff(org_id));
create policy version_files_delete on version_files for delete
  using (is_staff(org_id));

-- ---------- checkins (also fixes auth_rls_initplan) ----------
drop policy if exists checkins_select on checkins;
create policy checkins_select on checkins for select using (
  is_staff(org_id)
  and (user_id = (select auth.uid()) or is_admin_of(org_id))
);

drop policy if exists checkins_write on checkins;
create policy checkins_insert on checkins for insert with check (
  user_id = (select auth.uid()) and is_staff(org_id)
);
create policy checkins_update on checkins for update
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and is_staff(org_id));
create policy checkins_delete on checkins for delete
  using (user_id = (select auth.uid()));


-- ============================================================
-- 3. unindexed_foreign_keys
-- ============================================================

create index if not exists activity_log_actor_id_idx           on activity_log (actor_id);
create index if not exists activity_log_org_id_idx             on activity_log (org_id);
create index if not exists approvals_actor_id_idx              on approvals (actor_id);
create index if not exists approvals_org_id_idx                on approvals (org_id);
create index if not exists checkins_user_id_idx                on checkins (user_id);
create index if not exists deliverable_versions_org_id_idx     on deliverable_versions (org_id);
create index if not exists deliverable_versions_submitted_by_idx on deliverable_versions (submitted_by);
create index if not exists deliverables_org_id_idx             on deliverables (org_id);
create index if not exists deliverables_task_id_idx            on deliverables (task_id);
create index if not exists invitations_client_id_idx           on invitations (client_id);
create index if not exists invitations_invited_by_idx          on invitations (invited_by);
create index if not exists memberships_client_id_idx           on memberships (client_id);
create index if not exists messages_author_id_idx              on messages (author_id);
create index if not exists messages_org_id_idx                 on messages (org_id);
create index if not exists notifications_org_id_idx            on notifications (org_id);
create index if not exists task_comments_author_id_idx         on task_comments (author_id);
create index if not exists task_comments_org_id_idx            on task_comments (org_id);
create index if not exists tasks_created_by_idx                on tasks (created_by);
create index if not exists time_entries_org_id_idx             on time_entries (org_id);
create index if not exists version_files_org_id_idx            on version_files (org_id);
create index if not exists webhook_endpoints_org_id_idx        on webhook_endpoints (org_id);


-- ============================================================
-- Note on "unused_index" INFO findings
--
-- Those indexes are reported unused because the database has had
-- no application traffic yet — only the seed script has run.
-- They cover the queries the app will actually make. Do NOT drop
-- them; re-check the linter after a few weeks of real use.
-- ============================================================
