import { requireStaff } from '@/lib/auth'
import { AgencyNav } from '@/components/agency-nav'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { ROLE_LABELS } from '@/lib/permissions'

/**
 * Agency workspace shell.
 *
 * Wraps every page under app/(agency)/. The (agency) folder is a route
 * group — the parentheses keep it out of the URL, so this layout applies
 * to /dashboard, /projects, /team and so on.
 *
 * requireStaff() does two things here, so no page inside needs to repeat
 * them: it redirects signed-out users to /login, and it redirects client
 * accounts to /portal. Pages still call it themselves to get the typed
 * user and membership.
 */
export default async function AgencyLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const { user, membership } = await requireStaff()

  const initials = (user.fullName ?? user.email)
    .split(' ')
    .map((part) => part[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()

  return (
    <div className="flex min-h-screen flex-col bg-background">
      {/* Top bar */}
      <header className="flex h-14 shrink-0 items-center justify-between border-b border-border px-4">
        <span className="text-sm font-semibold tracking-tight">AgencyHub</span>

        <div className="flex items-center gap-4">
          <span className="hidden text-sm text-muted-foreground sm:inline">
            {membership.orgName}
          </span>
          <Avatar className="size-7">
            <AvatarFallback className="text-xs">{initials}</AvatarFallback>
          </Avatar>
        </div>
      </header>

      <div className="flex flex-1">
        {/* Sidebar */}
        <aside className="hidden w-56 shrink-0 border-r border-border md:block">
          <AgencyNav />
          <div className="px-6 pt-2 text-xs text-muted-foreground">
            {ROLE_LABELS[membership.role]}
          </div>
        </aside>

        {/* Main content */}
        <main className="flex-1 p-6 lg:p-8">
          <div className="mx-auto max-w-6xl">{children}</div>
        </main>
      </div>
    </div>
  )
}
