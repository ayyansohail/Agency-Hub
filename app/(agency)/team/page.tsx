import { requireStaff } from '@/lib/auth'
import { createServerSupabase } from '@/lib/supabase'
import { canInviteUsers, isAdmin, ROLE_LABELS, type MemberRole } from '@/lib/permissions'

import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'

/**
 * REFERENCE PAGE — Team (FR-AUTH-03, 04, 07)
 *
 * This is the pattern every agency page follows. Copy its structure:
 *
 *   1. requireStaff() / requireAdmin() first — auth and role gate
 *   2. createServerSupabase() and fetch — RLS scopes the rows, you don't
 *   3. Guard privileged queries with a permission check
 *   4. Page header: h1 on the left, primary action on the right
 *   5. Section heading, then content
 *   6. Empty state inside a bordered card when there is nothing to show
 *
 * Note on emails: a member's email lives in auth.users, which RLS does
 * not expose to the browser. We show the name and role instead. Pending
 * invitations DO carry an email, because we stored it ourselves.
 */

function formatDate(value: string | null) {
  if (!value) return '—'
  return new Intl.DateTimeFormat('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(value))
}

function RoleBadge({ role }: { role: MemberRole }) {
  return (
    <Badge variant={role === 'client' ? 'outline' : 'secondary'}>
      {ROLE_LABELS[role]}
    </Badge>
  )
}

function EmptyState({
  title,
  description,
  action,
}: {
  title: string
  description: string
  action?: React.ReactNode
}) {
  return (
    <div className="flex flex-col items-center gap-2 rounded-lg border border-border p-10 text-center">
      <p className="text-sm font-medium">{title}</p>
      <p className="text-sm text-muted-foreground">{description}</p>
      {action ? <div className="pt-2">{action}</div> : null}
    </div>
  )
}

export default async function TeamPage() {
  const { membership } = await requireStaff()
  const supabase = await createServerSupabase()

  // RLS already limits memberships to this user's agencies, but filtering
  // explicitly keeps the query honest and readable.
  const { data: members } = await supabase
    .from('memberships')
    .select(
      'id, role, is_active, created_at, profiles(full_name), client_companies(company_name)'
    )
    .eq('org_id', membership.orgId)
    .order('created_at', { ascending: true })

  // Only owners and managers may read invitations (BR-03), so don't even
  // ask unless this user qualifies — an employee would get an empty list
  // and a pointless round trip.
  const canSeeInvitations = isAdmin(membership.role)

  const { data: invitations } = canSeeInvitations
    ? await supabase
        .from('invitations')
        .select('id, email, role, status, expires_at, created_at')
        .eq('org_id', membership.orgId)
        .eq('status', 'pending')
        .order('created_at', { ascending: false })
    : { data: null }

  return (
    <div className="space-y-8">
      {/* Page header */}
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Team</h1>
          <p className="text-sm text-muted-foreground">
            People with access to {membership.orgName}
          </p>
        </div>

        {canInviteUsers(membership.role) && <Button>Invite member</Button>}
      </div>

      {/* Members */}
      <section className="space-y-3">
        <h2 className="text-sm font-medium text-muted-foreground">Members</h2>

        {!members || members.length === 0 ? (
          <EmptyState
            title="No members yet"
            description="Invite your first team member to get started."
            action={
              canInviteUsers(membership.role) ? (
                <Button>Invite member</Button>
              ) : null
            }
          />
        ) : (
          <div className="rounded-lg border border-border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Client company</TableHead>
                  <TableHead>Joined</TableHead>
                  <TableHead className="text-right">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {members.map((member: any) => {
                  const name = member.profiles?.full_name || 'Unnamed user'
                  const initials = name
                    .split(' ')
                    .map((part: string) => part[0])
                    .join('')
                    .slice(0, 2)
                    .toUpperCase()

                  return (
                    <TableRow key={member.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <Avatar className="size-7">
                            <AvatarFallback className="text-xs">
                              {initials}
                            </AvatarFallback>
                          </Avatar>
                          <span className="font-medium">{name}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <RoleBadge role={member.role} />
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {member.client_companies?.company_name ?? '—'}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {formatDate(member.created_at)}
                      </TableCell>
                      <TableCell className="text-right">
                        {member.is_active ? (
                          <span className="text-sm text-muted-foreground">
                            Active
                          </span>
                        ) : (
                          <Badge variant="outline">Inactive</Badge>
                        )}
                      </TableCell>
                    </TableRow>
                  )
                })}
              </TableBody>
            </Table>
          </div>
        )}
      </section>

      {/* Pending invitations — admins only */}
      {canSeeInvitations && (
        <section className="space-y-3">
          <h2 className="text-sm font-medium text-muted-foreground">
            Pending invitations
          </h2>

          {!invitations || invitations.length === 0 ? (
            <EmptyState
              title="No pending invitations"
              description="Invitations you send will appear here until they are accepted."
            />
          ) : (
            <div className="rounded-lg border border-border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Email</TableHead>
                    <TableHead>Role</TableHead>
                    <TableHead>Sent</TableHead>
                    <TableHead>Expires</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {invitations.map((invite: any) => (
                    <TableRow key={invite.id}>
                      <TableCell className="font-medium">
                        {invite.email}
                      </TableCell>
                      <TableCell>
                        <RoleBadge role={invite.role} />
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {formatDate(invite.created_at)}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {formatDate(invite.expires_at)}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </section>
      )}
    </div>
  )
}
