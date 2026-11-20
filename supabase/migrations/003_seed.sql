-- ============================================================
-- AgencyHub — seed data (test only)
-- Two agencies, so tenant isolation can be verified.
-- ============================================================

do $$
declare
  nl_owner    uuid;
  nl_manager  uuid;
  nl_employee uuid;
  nl_client   uuid;
  bs_owner    uuid;
  bs_client   uuid;

  org_nl      uuid;
  org_bs      uuid;

  cc_northstar uuid;
  cc_urban     uuid;
  cc_meridian  uuid;

  prj_rebrand  uuid;
  prj_campaign uuid;
  prj_bs       uuid;

  dlv_brand    uuid;
begin
  select id into nl_owner    from auth.users where email = 'owner@northline.test';
  select id into nl_manager  from auth.users where email = 'manager@northline.test';
  select id into nl_employee from auth.users where email = 'employee@northline.test';
  select id into nl_client   from auth.users where email = 'client@northline.test';
  select id into bs_owner    from auth.users where email = 'owner@brightside.test';
  select id into bs_client   from auth.users where email = 'client@brightside.test';

  if nl_owner is null or bs_owner is null then
    raise exception 'Test users not found — create all six in Authentication → Users first';
  end if;

  -- names
  update profiles set full_name = 'Nadia Owner'    where id = nl_owner;
  update profiles set full_name = 'Sam Manager'    where id = nl_manager;
  update profiles set full_name = 'Alex Employee'  where id = nl_employee;
  update profiles set full_name = 'Taylor Client'  where id = nl_client;
  update profiles set full_name = 'Riya Owner'     where id = bs_owner;
  update profiles set full_name = 'Jordan Client'  where id = bs_client;

  -- make the Northline owner a platform admin too, for testing /admin
  update profiles set is_platform_admin = true where id = nl_owner;

  -- ---------- organizations ----------
  insert into organizations (name, slug, accent_color)
  values ('Northline Creative Collective', 'northline', '#1F3864')
  returning id into org_nl;

  insert into organizations (name, slug, accent_color)
  values ('Brightside Studio', 'brightside', '#0F766E')
  returning id into org_bs;

  -- ---------- client companies ----------
  insert into client_companies (org_id, company_name, contact_email)
  values (org_nl, 'Northstar Ltd', 'hello@northstar.test')
  returning id into cc_northstar;

  insert into client_companies (org_id, company_name, contact_email)
  values (org_nl, 'Urban Foods', 'hello@urbanfoods.test')
  returning id into cc_urban;

  insert into client_companies (org_id, company_name, contact_email)
  values (org_bs, 'Meridian Health', 'hello@meridian.test')
  returning id into cc_meridian;

  -- ---------- memberships ----------
  insert into memberships (org_id, user_id, role, client_id) values
    (org_nl, nl_owner,    'owner',    null),
    (org_nl, nl_manager,  'manager',  null),
    (org_nl, nl_employee, 'employee', null),
    (org_nl, nl_client,   'client',   cc_northstar),
    (org_bs, bs_owner,    'owner',    null),
    (org_bs, bs_client,   'client',   cc_meridian);

  -- ---------- projects ----------
  insert into projects (org_id, client_id, name, description, status, start_date, due_date, included_revision_rounds)
  values (org_nl, cc_northstar, 'Northstar Rebrand',
          'Brand strategy and visual identity refresh.',
          'in_progress', current_date - 20, current_date + 25, 3)
  returning id into prj_rebrand;

  insert into projects (org_id, client_id, name, description, status, start_date, due_date)
  values (org_nl, cc_urban, 'Urban Foods Campaign',
          'Q1 social campaign and launch assets.',
          'planning', current_date - 5, current_date + 40)
  returning id into prj_campaign;

  insert into projects (org_id, client_id, name, description, status, start_date, due_date)
  values (org_bs, cc_meridian, 'Meridian Website',
          'Marketing site redesign.',
          'in_progress', current_date - 10, current_date + 30)
  returning id into prj_bs;

  -- ---------- project members ----------
  insert into project_members (project_id, user_id) values
    (prj_rebrand,  nl_manager),
    (prj_rebrand,  nl_employee),
    (prj_rebrand,  nl_client),
    (prj_campaign, nl_manager),
    (prj_campaign, nl_employee),
    (prj_bs,       bs_owner),
    (prj_bs,       bs_client);

  -- ---------- tasks ----------
  insert into tasks (org_id, project_id, title, description, status, priority, assignee_id, due_date, client_visible, created_by) values
    (org_nl, prj_rebrand, 'Logo concepts',        'Three directions for review.',  'in_review',   'high',   nl_employee, current_date + 2,  true,  nl_manager),
    (org_nl, prj_rebrand, 'Type scale',           'Define heading and body scale.','in_progress', 'medium', nl_employee, current_date + 5,  true,  nl_manager),
    (org_nl, prj_rebrand, 'Internal budget note', 'Do not expose to client.',      'todo',        'low',    nl_manager,  current_date + 7,  false, nl_manager),
    (org_nl, prj_rebrand, 'Brand guidelines doc', 'Compile final guidelines.',     'todo',        'urgent', nl_employee, current_date + 10, true,  nl_manager),
    (org_nl, prj_campaign,'Campaign moodboard',   'Reference collection.',         'todo',        'medium', nl_employee, current_date + 12, true,  nl_manager),
    (org_bs, prj_bs,      'Homepage wireframe',   'Desktop and mobile.',           'in_progress', 'high',   bs_owner,    current_date + 6,  true,  bs_owner);

  -- ---------- a deliverable with version history ----------
  insert into deliverables (org_id, project_id, title)
  values (org_nl, prj_rebrand, 'Brand Guidelines')
  returning id into dlv_brand;

  insert into deliverable_versions (org_id, deliverable_id, version_no, submitted_by, submission_note, approval_status, submitted_at)
  values
    (org_nl, dlv_brand, 1, nl_employee, 'First pass at the guidelines.',  'changes_requested', now() - interval '9 days'),
    (org_nl, dlv_brand, 2, nl_employee, 'Updated type scale.',            'changes_requested', now() - interval '5 days'),
    (org_nl, dlv_brand, 3, nl_employee, 'Clarified usage rules.',         'submitted',         now() - interval '1 day');

  insert into approvals (org_id, version_id, actor_id, decision, note)
  select org_nl, v.id, nl_client, 'changes_requested', 'Please revisit the type scale.'
  from deliverable_versions v where v.deliverable_id = dlv_brand and v.version_no = 1;

  insert into approvals (org_id, version_id, actor_id, decision, note)
  select org_nl, v.id, nl_client, 'changes_requested', 'Usage rules need more detail.'
  from deliverable_versions v where v.deliverable_id = dlv_brand and v.version_no = 2;

  -- ---------- messages ----------
  insert into messages (org_id, project_id, author_id, body, internal_only) values
    (org_nl, prj_rebrand, nl_employee, 'Internal: hold v4 until the manager reviews.', true),
    (org_nl, prj_rebrand, nl_manager,  'Version 3 is with you for review.',            false),
    (org_nl, prj_rebrand, nl_client,   'Thanks — will look today.',                    false);

  -- ---------- time entries ----------
  insert into time_entries (org_id, task_id, user_id, entry_date, minutes, note)
  select org_nl, t.id, nl_employee, current_date - 1, 90, 'Concept exploration'
  from tasks t where t.project_id = prj_rebrand and t.title = 'Logo concepts';

  insert into time_entries (org_id, task_id, user_id, entry_date, minutes, note)
  select org_nl, t.id, nl_employee, current_date, 120, 'Type scale work'
  from tasks t where t.project_id = prj_rebrand and t.title = 'Type scale';

  raise notice 'Seed complete: Northline (% ) and Brightside (%)', org_nl, org_bs;
end $$;