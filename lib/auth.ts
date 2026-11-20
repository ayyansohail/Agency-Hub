import { createServerSupabase } from './supabase'
import { redirect } from 'next/navigation'
import type { MemberRole } from './permissions'

export type CurrentUser = {
  id: string
  email: string
  fullName: string | null
  avatarUrl: string | null
  isPlatformAdmin: boolean
}

export type Membership = {
  id: string
  orgId: string
  orgName: string
  orgSlug: string
  role: MemberRole
  clientId: string | null
}

/** The signed-in user, or null. */
export async function getCurrentUser(): Promise<CurrentUser | null> {
  const supabase = await createServerSupabase()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return null

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name, avatar_url, is_platform_admin')
    .eq('id', user.id)
    .single()

  return {
    id: user.id,
    email: user.email ?? '',
    fullName: profile?.full_name ?? null,
    avatarUrl: profile?.avatar_url ?? null,
    isPlatformAdmin: profile?.is_platform_admin ?? false,
  }
}

/** Every agency the user belongs to. */
export async function getMemberships(): Promise<Membership[]> {
  const supabase = await createServerSupabase()
  const { data } = await supabase
    .from('memberships')
    .select('id, org_id, role, client_id, organizations(name, slug)')
    .eq('is_active', true)

  if (!data) return []

  return data.map((m: any) => ({
    id: m.id,
    orgId: m.org_id,
    orgName: m.organizations?.name ?? '',
    orgSlug: m.organizations?.slug ?? '',
    role: m.role as MemberRole,
    clientId: m.client_id,
  }))
}

/**
 * The membership for the agency the user is currently working in.
 * For now: their first active membership. Multi-agency switching
 * (FR-AUTH-10) can store a selected org in a cookie and read it here
 * without changing any caller.
 */
export async function getActiveMembership(): Promise<Membership | null> {
  const memberships = await getMemberships()
  return memberships[0] ?? null
}

/** Use at the top of any protected page. Redirects to /login if signed out. */
export async function requireUser(): Promise<CurrentUser> {
  const user = await getCurrentUser()
  if (!user) redirect('/login')
  return user
}

/** Requires a signed-in user who belongs to an agency. */
export async function requireMembership(): Promise<{
  user: CurrentUser
  membership: Membership
}> {
  const user = await requireUser()
  const membership = await getActiveMembership()
  if (!membership) redirect('/no-agency')
  return { user, membership }
}

/** Requires agency staff — blocks client accounts. */
export async function requireStaff() {
  const { user, membership } = await requireMembership()
  if (membership.role === 'client') redirect('/portal')
  return { user, membership }
}

/** Requires owner or manager. */
export async function requireAdmin() {
  const { user, membership } = await requireMembership()
  if (membership.role !== 'owner' && membership.role !== 'manager') {
    redirect('/dashboard')
  }
  return { user, membership }
}

/** Requires a platform administrator. */
export async function requirePlatformAdmin(): Promise<CurrentUser> {
  const user = await requireUser()
  if (!user.isPlatformAdmin) redirect('/dashboard')
  return user
}