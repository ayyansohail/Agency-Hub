'use server'

import { redirect } from 'next/navigation'
import { createServerSupabase } from '@/lib/supabase'

function slugify(name: string) {
  const base = name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 40)

  // Short random suffix so two agencies with the same name can both register.
  const suffix = Math.random().toString(36).slice(2, 7)
  return base ? `${base}-${suffix}` : `agency-${suffix}`
}

function fail(message: string): never {
  redirect(`/register?error=${encodeURIComponent(message)}`)
}

export async function register(formData: FormData) {
  const agencyName = String(formData.get('agencyName') ?? '').trim()
  const fullName = String(formData.get('fullName') ?? '').trim()
  const email = String(formData.get('email') ?? '').trim()
  const password = String(formData.get('password') ?? '')

  if (!agencyName || !fullName || !email || !password) {
    fail('All fields are required')
  }

  // NFR-SEC-06: passwords are at least ten characters.
  if (password.length < 10) {
    fail('Password must be at least 10 characters')
  }

  const supabase = await createServerSupabase()

  // 1. Create the account.
  const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
    email,
    password,
    options: { data: { full_name: fullName } },
  })

  if (signUpError) {
    fail(signUpError.message)
  }

  if (!signUpData.session) {
    // Email confirmation is switched on in Supabase. For this project it
    // should be off: Authentication → Sign In / Providers → Email.
    fail('Account created. Check your email to confirm before signing in.')
  }

  // 2. Create the agency and the owner membership together.
  //
  // Both inserts run inside one security definer function. Doing them from
  // here does not work: reading the new organization back would go through
  // the SELECT policy, and at that moment the user has no membership yet,
  // so the read is denied even though the insert succeeded.
  const { error: rpcError } = await supabase.rpc('create_agency', {
    agency_name: agencyName,
    agency_slug: slugify(agencyName),
  })

  if (rpcError) {
    fail(rpcError.message)
  }

  redirect('/dashboard')
}