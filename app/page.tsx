import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function LandingPage() {
  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="flex h-14 items-center justify-between border-b border-border px-6">
        <span className="text-sm font-semibold tracking-tight">AgencyHub</span>
        <div className="flex items-center gap-2">
          <Button asChild variant="ghost" size="sm">
            <Link href="/login">Log in</Link>
          </Button>
          <Button asChild size="sm">
            <Link href="/register">Create an agency</Link>
          </Button>
        </div>
      </header>

      <main className="flex flex-1 items-center justify-center px-6">
        <div className="max-w-xl space-y-6 text-center">
          <h1 className="text-4xl font-semibold tracking-tight">
            One workspace for your team and your clients
          </h1>

          <p className="text-muted-foreground">
            AgencyHub gives your agency a shared view of every project, and
            gives each client a private portal limited to their own work.
            Deliverables are versioned, approvals are recorded, and internal
            discussion stays internal.
          </p>

          <div className="flex items-center justify-center gap-3 pt-2">
            <Button asChild>
              <Link href="/register">Create an agency</Link>
            </Button>
            <Button asChild variant="outline">
              <Link href="/login">Log in</Link>
            </Button>
          </div>
        </div>
      </main>

      <footer className="border-t border-border px-6 py-4 text-center text-xs text-muted-foreground">
        AgencyHub
      </footer>
    </div>
  )
}
