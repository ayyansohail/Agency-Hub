'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'

/**
 * Agency workspace sidebar navigation.
 *
 * Client component because it needs usePathname() to mark the active
 * item. Everything else in the layout stays on the server.
 */

const NAV_ITEMS = [
  { href: '/dashboard', label: 'Dashboard' },
  { href: '/clients', label: 'Clients' },
  { href: '/projects', label: 'Projects' },
  { href: '/tasks', label: 'Tasks' },
  { href: '/deliverables', label: 'Deliverables' },
  { href: '/messages', label: 'Messages' },
  { href: '/activity', label: 'Activity' },
  { href: '/reports', label: 'Reports' },
  { href: '/team', label: 'Team' },
  { href: '/settings', label: 'Settings' },
]

export function AgencyNav() {
  const pathname = usePathname()

  return (
    <nav className="flex flex-col gap-0.5 p-3">
      {NAV_ITEMS.map((item) => {
        const isActive =
          pathname === item.href || pathname.startsWith(`${item.href}/`)

        return (
          <Link
            key={item.href}
            href={item.href}
            className={cn(
              'rounded-md px-3 py-2 text-sm transition-colors',
              isActive
                ? 'bg-muted font-medium text-foreground'
                : 'text-muted-foreground hover:bg-muted/50 hover:text-foreground'
            )}
          >
            {item.label}
          </Link>
        )
      })}
    </nav>
  )
}
