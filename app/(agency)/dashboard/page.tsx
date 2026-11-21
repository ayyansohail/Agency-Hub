import Link from 'next/link'
import { requireStaff } from '@/lib/auth'
import { createServerSupabase } from '@/lib/supabase'
import { ROLE_LABELS, isAdmin } from '@/lib/permissions'
import { logout } from '@/app/login/actions'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

/**
 * Agency dashboard (FR-DSH-01, FR-DSH-06).
 *
 * requireStaff() in the (agency) layout already sent client accounts to
 * /portal, so anyone reaching this page is owner, manager or employee.
 */

function Stat({ label, value }: { label: string; value: number | string }) {
  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">
          {label}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-2xl font-semibold">{value}</p>
      </CardContent>
    </Card>
  )
}

export default async function DashboardPage() {
  const { user, membership } = await requireStaff()
  const supabase = await createServerSupabase()

  const today = new Date()
  const inSevenDays = new Date(today)
  inSevenDays.setDate(today.getDate() + 7)

  const iso = (d: Date) => d.toISOString().slice(0, 10)

  // RLS scopes all of these to this agency automatically.
  const [{ count: projectCount }, { count: dueCount }, { count: overdueCount }] =
    await Promise.all([
      supabase
        .from('projects')
        .select('id', { count: 'exact', head: true })
        .eq('is_archived', false),
      supabase
        .from('tasks')
        .select('id', { count: 'exact', head: true })
        .neq('status', 'done')
        .gte('due_date', iso(today))
        .lte('due_date', iso(inSevenDays)),
      supabase
        .from('tasks')
        .select('id', { count: 'exact', head: true })
        .neq('status', 'done')
        .lt('due_date', iso(today)),
    ])

  // The signed-in person's own open work (FR-DSH-06).
  const { data: myTasks } = await supabase
    .from('tasks')
    .select('id, title, status, due_date, projects(name)')
    .eq('assignee_id', user.id)
    .neq('status', 'done')
    .order('due_date', { ascending: true })
    .limit(8)

  const firstName = (user.fullName ?? '').split(' ')[0] || 'there'

  return (
    <div className="space-y-8">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">
            Hello, {firstName}
          </h1>
          <p className="text-sm text-muted-foreground">
            {ROLE_LABELS[membership.role]} at {membership.orgName}
          </p>
        </div>

        <form action={logout}>
          <Button type="submit" variant="outline" size="sm">
            Sign out
          </Button>
        </form>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Stat label="Active projects" value={projectCount ?? 0} />
        <Stat label="Due this week" value={dueCount ?? 0} />
        <Stat label="Overdue" value={overdueCount ?? 0} />
      </div>

      <section className="space-y-3">
        <h2 className="text-sm font-medium text-muted-foreground">
          Your open tasks
        </h2>

        {!myTasks || myTasks.length === 0 ? (
          <div className="rounded-lg border border-border p-10 text-center">
            <p className="text-sm font-medium">Nothing assigned to you</p>
            <p className="text-sm text-muted-foreground">
              Tasks assigned to you will appear here.
            </p>
          </div>
        ) : (
          <div className="divide-y divide-border rounded-lg border border-border">
            {myTasks.map((task: any) => (
              <div
                key={task.id}
                className="flex items-center justify-between gap-4 p-4"
              >
                <div>
                  <p className="text-sm font-medium">{task.title}</p>
                  <p className="text-sm text-muted-foreground">
                    {task.projects?.name ?? 'No project'}
                  </p>
                </div>
                <p className="text-sm text-muted-foreground">
                  {task.due_date
                    ? new Intl.DateTimeFormat('en-GB', {
                        day: 'numeric',
                        month: 'short',
                      }).format(new Date(task.due_date))
                    : '—'}
                </p>
              </div>
            ))}
          </div>
        )}
      </section>

      {isAdmin(membership.role) && (
        <section className="space-y-3">
          <h2 className="text-sm font-medium text-muted-foreground">
            Quick links
          </h2>
          <div className="flex flex-wrap gap-2">
            <Button asChild variant="outline" size="sm">
              <Link href="/team">Team</Link>
            </Button>
            <Button asChild variant="outline" size="sm">
              <Link href="/clients">Clients</Link>
            </Button>
            <Button asChild variant="outline" size="sm">
              <Link href="/projects">Projects</Link>
            </Button>
          </div>
        </section>
      )}
    </div>
  )
}
