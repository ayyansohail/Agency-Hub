# AgencyHub — Developer Context

Paste this whole file into your AI assistant along with your card description before writing any code. It describes the project's real schema, conventions and components so the code you get back fits.

---

## 1. What the product is

AgencyHub is a multi-tenant web platform for creative agencies. An agency registers, invites its employees and its clients, and runs projects in one place. Staff manage tasks, deadlines and deliverables internally. Each client gets a separate, simplified portal limited strictly to their own projects, where they review submitted work and either approve it or request changes.

**The governing rule: visibility defaults to internal.** Nothing reaches a client unless someone has explicitly marked it visible. Every design decision follows from this.

**Four roles:**

| Role | What they do |
|---|---|
| `owner` | Registers the agency, invites everyone, full access within their agency |
| `manager` | Creates projects and tasks, assigns work, controls what the client sees |
| `employee` | Works on assigned tasks, uploads deliverables, logs time |
| `client` | Sees only their own projects, reviews deliverables, approves or requests changes |

---

## 2. Stack

- **Next.js 16** with App Router, TypeScript, Turbopack
- **Tailwind CSS v4**
- **shadcn/ui** (Radix UI, Nova preset) — components live in `components/ui`
- **Supabase** — Postgres, Auth, Storage, Realtime
- **Vercel** — hosting, auto-deploys from `main`

Note: this project uses `proxy.ts` at the root, not `middleware.ts` (Next.js 16 renamed it). Don't recreate `middleware.ts`.

---

## 3. Folder structure

```
/app
  page.tsx                      landing
  /login                        sign in
  /register                     create agency
  /invite/[token]               accept invitation
  /forgot-password
  /reset-password
  /admin                        platform admin only

  /(agency)                     agency workspace — shared sidebar layout
    /dashboard
    /clients
    /clients/[id]
    /projects
    /projects/[id]
    /tasks
    /deliverables
    /messages
    /activity
    /reports
    /team                       members and invitations
    /settings

  /(client)                     client portal — its own minimal layout
    /portal
    /portal/projects/[id]
    /portal/deliverables/[id]
    /portal/messages

/components
  /ui                           shadcn components — do not hand-edit
/lib
  supabase.ts                   database clients
  auth.ts                       session and role helpers
  permissions.ts                role capability checks
  utils.ts                      shadcn's cn() helper
/supabase/migrations            001_schema.sql, 002_rls.sql, 003_seed.sql
proxy.ts                        session refresh
```

Rules:
- A page is always `page.tsx`; the folder name is the URL.
- `(agency)` and `(client)` are route groups — the parentheses don't appear in the URL, they just apply different layouts.
- **Nobody edits `/lib` except the tech lead.** If you need a new helper, ask.
- **Nobody hand-edits `components/ui`.** Those are generated.

---

## 4. Database schema

Every tenant-owned table carries `org_id`. All ids are `uuid`.

```
profiles              id (= auth user id), full_name, avatar_url, timezone,
                      is_platform_admin, created_at

organizations         id, name, slug, logo_url, accent_color, is_active, created_at

client_companies      id, org_id, company_name, contact_email, is_archived, created_at

memberships           id, org_id, user_id, role, client_id, is_active, created_at
                      role: 'owner' | 'manager' | 'employee' | 'client'
                      client_id is required when role = 'client', null otherwise

invitations           id, org_id, email, role, client_id, token, status,
                      invited_by, expires_at, accepted_at, created_at
                      status: 'pending' | 'accepted' | 'revoked' | 'expired'

projects              id, org_id, client_id, name, description, status,
                      start_date, due_date, included_revision_rounds,
                      show_assignee_to_client, meeting_link, is_archived, created_at
                      status: 'planning' | 'in_progress' | 'in_review' |
                              'blocked' | 'completed' | 'archived'

project_members       id, project_id, user_id, created_at

tasks                 id, org_id, project_id, title, description, status, priority,
                      assignee_id, due_date, position, client_visible,
                      is_archived, created_by, created_at
                      status:   'todo' | 'in_progress' | 'in_review' | 'blocked' | 'done'
                      priority: 'low' | 'medium' | 'high' | 'urgent'

task_comments         id, org_id, task_id, author_id, body, internal_only, created_at

deliverables          id, org_id, project_id, task_id, title, created_at

deliverable_versions  id, org_id, deliverable_id, version_no, submitted_by,
                      submission_note, approval_status, submitted_at, created_at
                      approval_status: 'draft' | 'submitted' | 'changes_requested'
                                     | 'approved' | 'superseded'

version_files         id, org_id, version_id, storage_path, file_name,
                      mime_type, size_bytes, created_at

approvals             id, org_id, version_id, actor_id, decision, note, created_at
                      decision: 'approved' | 'changes_requested'
                      note is REQUIRED when decision = 'changes_requested'

messages              id, org_id, project_id, author_id, body, internal_only, created_at

activity_log          id, org_id, project_id, actor_id, verb, entity_type,
                      entity_id, meta, client_visible, created_at

time_entries          id, org_id, task_id, user_id, entry_date, minutes, note, created_at

checkins              id, org_id, user_id, entry_date, did, doing, blockers, created_at

notifications         id, org_id, user_id, type, payload, is_urgent, read_at, created_at

notification_preferences  user_id, daily_digest

webhook_endpoints     id, org_id, url, events, is_active
```

**Relationships:** one organization has many memberships, client companies and projects. One client company has many projects. One project has many tasks and deliverables. One deliverable has many versions. One version has many files and review decisions.

---

## 5. The access model

Access is enforced by Postgres row-level security, not by application code. A query that forgets to filter by agency returns nothing from other tenants — the database refuses it.

What that means for you:

- **You don't need to filter by `org_id` manually in most queries.** RLS does it. Filter anyway where it makes the query clearer, but never rely on it as the only protection.
- **Clients see tasks only when `client_visible = true`.**
- **Clients never see** `task_comments` or `messages` where `internal_only = true`.
- **Clients never see** a `deliverable_versions` row with `approval_status = 'draft'`.
- **Clients never see** `time_entries`, `checkins`, `client_companies` or any other agency's data.
- **Only `owner` and `manager` can invite people** or create projects.
- **Visibility defaults to internal** — `client_visible` defaults to `false`, `internal_only` defaults to `true`.

---

## 6. The lib API

Import these rather than writing your own.

### `lib/supabase.ts`

```ts
import { createClient } from '@/lib/supabase'           // client components
import { createServerSupabase } from '@/lib/supabase'   // server components & actions

const supabase = await createServerSupabase()
```

### `lib/auth.ts`

```ts
import {
  getCurrentUser,       // CurrentUser | null
  getMemberships,       // Membership[]
  getActiveMembership,  // Membership | null
  requireUser,          // redirects to /login if signed out
  requireMembership,    // { user, membership }
  requireStaff,         // { user, membership } — redirects clients to /portal
  requireAdmin,         // { user, membership } — owner or manager only
  requirePlatformAdmin, // CurrentUser — platform admins only
} from '@/lib/auth'
```

Types:

```ts
type CurrentUser = {
  id: string
  email: string
  fullName: string | null
  avatarUrl: string | null
  isPlatformAdmin: boolean
}

type Membership = {
  id: string
  orgId: string
  orgName: string
  orgSlug: string
  role: 'owner' | 'manager' | 'employee' | 'client'
  clientId: string | null
}
```

### `lib/permissions.ts`

```ts
import {
  isStaff, isClient, isAdmin,
  canInviteUsers, canManageMembers, canRevokeInvitation,
  canCreateProject, canEditProject, canArchiveProject,
  canManageClients, canAssignToProject,
  canSetClientVisibility,
  canCreateTask, canAssignTask, canUpdateTaskStatus,
  canUploadDeliverable, canSubmitForReview, canApproveDeliverable,
  canLogTime, canViewTeamWorkload, canViewTimeReports,
  canEditAgencySettings, canManageWebhooks,
  landingPathForRole,
  ROLE_LABELS, INVITABLE_ROLES,
  type MemberRole,
} from '@/lib/permissions'
```

All take a `MemberRole` and return a boolean. Use them to hide or disable UI. They are convenience, not security — RLS is what actually enforces access.

---

## 7. The standard page pattern

Every protected agency page starts the same way:

```tsx
import { requireStaff } from '@/lib/auth'
import { createServerSupabase } from '@/lib/supabase'
import { canCreateProject } from '@/lib/permissions'
import { Button } from '@/components/ui/button'

export default async function ProjectsPage() {
  const { user, membership } = await requireStaff()
  const supabase = await createServerSupabase()

  const { data: projects } = await supabase
    .from('projects')
    .select('id, name, status, due_date, client_companies(company_name)')
    .eq('is_archived', false)
    .order('due_date', { ascending: true })

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Projects</h1>
        {canCreateProject(membership.role) && <Button>New project</Button>}
      </div>

      {/* content */}
    </div>
  )
}
```

Use `requireAdmin()` instead of `requireStaff()` on pages only owners and managers should reach. Use `requireUser()` on the client portal pages.

### Reference implementation

`app/(agency)/team/page.tsx` is the worked example. Open it and follow its structure rather than inventing your own — page header, section headings, empty states, permission guards and table layout are all there.

Paste that file into your AI along with this document and your card description. A real example from the codebase produces far more consistent output than instructions alone.

Also read `app/(agency)/layout.tsx` to see how the workspace shell wraps every page, and `app/(agency)/team/loading.tsx` for the skeleton pattern every list page should have.

---

## 8. Layout structure

### Agency workspace — `app/(agency)/layout.tsx`

- **Top bar:** "AgencyHub" on the left; Search, Help, Profile on the right
- **Left sidebar, fixed:** Dashboard · Clients · Projects · Tasks · Deliverables · Messages · Activity · Reports · Team · Settings
- Active item is highlighted
- **Main content** to the right of the sidebar

### Client portal — `app/(client)/layout.tsx`

Deliberately different, and this matters:

- **Top bar shows the AGENCY'S NAME**, not "AgencyHub"
- **No sidebar.** Horizontal tabs only: Home · Projects · Messages
- No internal terminology, no agency navigation
- Must be fully usable at 360px width

### Auth pages

- **No navigation at all.** Centred card on an empty background
- Card contains: "AgencyHub" wordmark, a heading, the fields, one primary button, and secondary links below

---

## 9. Visual direction

Plain, quiet, functional. Think Supabase or Linear — not a marketing site.

- **Neutral backgrounds**, subtle borders, generous whitespace
- **One accent colour**, used only for primary actions and active nav
- **Plain readable type.** The Geist font is already configured — don't add fonts
- **No gradients, no shadows beyond a hairline border, no decorative icons**
- Cards are a 1px border and a small radius, not a drop shadow

**Use the semantic Tailwind tokens, never raw colours:**

```
bg-background      page background
bg-card            card surfaces
text-foreground    primary text
text-muted-foreground   secondary text
border-border      all borders
bg-primary         primary buttons
bg-muted           subtle fills, table headers
```

Never write `bg-slate-50` or `bg-[#1F3864]`. The tokens handle light and dark mode automatically; raw colours break it.

**Standard spacing:** `space-y-6` between page sections, `p-6` inside cards, `gap-4` in grids.

---

## 10. Available components

In `components/ui`, import as `@/components/ui/<name>`:

`button` · `input` · `label` · `card` · `table` · `dialog` · `dropdown-menu` · `select` · `textarea` · `badge` · `avatar` · `separator` · `sonner`

**Never write a raw `<button>`, `<input>`, `<select>` or `<table>`.** Use these. If you need a component that isn't listed, ask the tech lead to add it rather than building your own.

Use `sonner` for toasts: `import { toast } from 'sonner'`.

---

## 11. Required states

Every list page needs all three. They get forgotten otherwise.

**Loading** — a `loading.tsx` beside `page.tsx`, with skeleton rows matching the real layout.

**Empty** — centred in a bordered card: one line saying what's missing, one line saying what to do, and the primary action button. Example: "No projects yet." / "Create your first project to get started." / `[New project]`

**Error** — plain language, what happened and what to do. Never expose a raw database error.

---

## 12. Conventions

- **Dates:** store as `date` or `timestamptz`; display as "12 Nov 2026"
- **Buttons:** verb first — "New project", "Invite member", "Submit for review"
- **Headings:** sentence case, not Title Case
- **Destructive actions** always open a confirmation dialog stating what will happen
- **Forms:** use server actions, validate on the server, show errors inline under the field
- **Never trust the client** — re-check permissions on the server even if the UI hides the button

---

## 13. Git workflow

```
git checkout main
git pull
git checkout -b your-card-name
# ... work ...
git add .
git commit -m "What you did"
git push -u origin your-card-name
```

Then open a pull request on GitHub and post the link in the group chat. **Never push to `main`. Never merge your own PR.**

---

## 14. Test accounts

Seeded in the database. Password for all six: `123456`

| Email | Role | Agency |
|---|---|---|
| owner@northline.test | owner (also platform admin) | Northline |
| manager@northline.test | manager | Northline |
| employee@northline.test | employee | Northline |
| client@northline.test | client (Northstar Ltd) | Northline |
| owner@brightside.test | owner | Brightside |
| client@brightside.test | client (Meridian Health) | Brightside |

Two agencies exist deliberately. Always test that a Northline user cannot see any Brightside data, and that `client@northline.test` cannot see the Urban Foods project or the task named "Internal budget note".
