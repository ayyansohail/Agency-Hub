export type MemberRole = 'owner' | 'manager' | 'employee' | 'client'

export const ROLE_LABELS: Record<MemberRole, string> = {
  owner: 'Agency Owner',
  manager: 'Project Manager',
  employee: 'Employee',
  client: 'Client',
}

/** Roles an owner or manager may issue an invitation for. */
export const INVITABLE_ROLES: MemberRole[] = ['manager', 'employee', 'client']

export const isStaff = (role: MemberRole) => role !== 'client'
export const isClient = (role: MemberRole) => role === 'client'
export const isAdmin = (role: MemberRole) => role === 'owner' || role === 'manager'

// BR-03: only owners and managers bring people in
export const canInviteUsers      = (role: MemberRole) => isAdmin(role)
export const canManageMembers    = (role: MemberRole) => role === 'owner'
export const canRevokeInvitation = (role: MemberRole) => isAdmin(role)

// projects and clients
export const canCreateProject   = (role: MemberRole) => isAdmin(role)
export const canEditProject     = (role: MemberRole) => isAdmin(role)
export const canArchiveProject  = (role: MemberRole) => isAdmin(role)
export const canManageClients   = (role: MemberRole) => isAdmin(role)
export const canAssignToProject = (role: MemberRole) => isAdmin(role)

// BR-07: only owners and managers expose anything to a client
export const canSetClientVisibility = (role: MemberRole) => isAdmin(role)

// tasks
export const canCreateTask = (role: MemberRole) => isStaff(role)
export const canAssignTask = (role: MemberRole) => isAdmin(role)
export const canUpdateTaskStatus = (role: MemberRole, isAssignee: boolean) =>
  isAdmin(role) || (isStaff(role) && isAssignee)

// deliverables
export const canUploadDeliverable  = (role: MemberRole) => isStaff(role)
export const canSubmitForReview    = (role: MemberRole) => isStaff(role)
export const canApproveDeliverable = (role: MemberRole) => isClient(role) || isAdmin(role)

// time and workload
export const canLogTime          = (role: MemberRole) => isStaff(role)
export const canViewTeamWorkload = (role: MemberRole) => isAdmin(role)
export const canViewTimeReports  = (role: MemberRole) => isAdmin(role)

// agency settings
export const canEditAgencySettings = (role: MemberRole) => role === 'owner'
export const canManageWebhooks     = (role: MemberRole) => isAdmin(role)

/** Where a user lands after signing in (FR-AUTH-08). */
export function landingPathForRole(role: MemberRole): string {
  return role === 'client' ? '/portal' : '/dashboard'
}