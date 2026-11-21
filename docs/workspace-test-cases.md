# AgencyHub test cases for US-01 through US-07

Each row is an independently runnable manual acceptance case with a case ID, actor, steps and expected result. The AgencyHub Product Backlog and SRS v1 define the expected behavior. The Handwritten Notebook Wireframes supply the screen references.

## Test setup

- Use a disposable environment, an email capture inbox and a test clock or fixture timestamps. Use independent browser sessions for each actor. Reset the relevant data between cases.
- Seed Northline with an ordinary Owner, a Project Manager, an assigned Employee, a second Employee and Client accounts for Northstar and Urban Foods. Add a second Northstar Client. For unassigned task tests, the second Employee belongs to the project but is not assigned the target task.
- Seed Brightside with its own Owner, Employee, Client, company, project and content. Use tenant-scoped accounts without platform-admin access. Include an account with active memberships in both agencies.
- Prepare an assigned Northstar project, a Northstar project unassigned to the target Client, an Urban Foods project and a Brightside project. Seed Internal and Client-visible tasks, files and messages. Record fixture IDs using an authorized staff session.
- Prepare pending, accepted, revoked and expired invitations. Confirm clock-based cases relative to the recorded server issue or last-activity timestamp. Use separate records for password resets and link redemptions.
- For authorization checks, use the specified actor’s ordinary session and supported operation. Check the response as well as the page. After a refused write, inspect the saved fixture to confirm its state.
- Start every transition case with a fresh task in the stated status. Use a non-manager Employee for Assignee cases. The transitions are derived from the Project Manager and Assignee rules in SRS section 7.3.

## Coverage

| Story | Cases |
| --- | ---: |
| US-01 | 43 |
| US-02 | 38 |
| US-03 | 43 |
| US-04 | 33 |
| US-05 | 49 |
| US-06 | 86 |
| US-07 | 97 |
| **Total** | **389** |

## US-01 Register a private agency and manage sign-in

FR-AUTH-01–02, AC-01. Password boundaries and inactivity from NFR-SEC-06. Wireframes 3–4.

### Agency registration

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-01.001 | New visitor registers with valid agency and owner details | Open the new workspace and inspect the fixture records. | Exactly one agency is created with the supplied name and one active Owner membership for the submitting account. |
| US-01.002 | New owner checks workspace initialization | Open the new workspace immediately after registration. | Agency context is correct and no projects or client records from existing agencies appear. |
| US-01.003 | New visitor makes a second independent registration | Register with a different owner email and agency name. | A distinct tenant and Owner membership are created. The first tenant's records are unaffected. |
| US-01.004 | New visitor uses a multiword agency name | Register with an agency name such as North Line Studio and reload. | The saved name retains its words and displays in the workspace. |
| US-01.005 | New visitor uses an agency name with accented characters | Register with a name such as Élan Créatif and reload. | The submitted name displays correctly in the new agency. |
| US-01.006 | New visitor omits the agency name | Submit otherwise valid registration details. | The agency-name requirement is shown and no tenant or membership is created. |
| US-01.007 | New visitor enters only spaces as the agency name | Submit otherwise valid registration details. | The blank name is rejected and no tenant or membership is created. |
| US-01.008 | New visitor omits the owner name shown in the registration wireframe | Submit otherwise valid registration details. | The form requests the missing owner name and leaves tenant and membership data unchanged. |
| US-01.009 | New visitor omits the owner email | Submit otherwise valid registration details. | The email requirement is shown and no tenant or membership is created. |
| US-01.010 | New visitor enters a malformed owner email | Use agency-owner.example.test in the email field and submit. | The email is rejected and no tenant or membership is created. |
| US-01.011 | New visitor omits the password | Submit otherwise valid registration details with the password blank. | The password requirement is shown and no tenant or membership is created. |
| US-01.012 | New visitor submits a password rejected by the configured password policy | Enter a password below the configured minimum and submit. | The password policy is explained and no partial agency is created. |
| US-01.013 | Signed-out visitor submits an already registered owner email | Enter an existing account email without authenticating that account. | The submission does not grant access, create a duplicate account, or attach an Owner membership to the previously registered user. |
| US-01.014 | New visitor submits identical registration twice in quick succession | Use two submissions for the same email and agency details before either response returns. | At most one tenant and one Owner membership are created for the successful registration. |
| US-01.015 | New visitor retries after failed validation | Correct the field flagged by the registration form and submit again. | The valid retry creates one tenant and Owner membership without carrying over partial records. |
| US-01.016 | New visitor encounters a controlled failure during tenant setup | Use an approved test fault after account creation and before membership creation, then retry after recovery. | No unusable tenant or membership is exposed. Recovery allows the account to complete setup without duplicate tenant data. |
| US-01.017 | New owner revisits the workspace in a new session | Sign out after registration and sign in with the registered credentials in a fresh browser session. | The new Owner can enter their own workspace again. |
| US-01.018 | Ordinary owner checks separation from another agency | With a non-platform-admin owner session, open the new agency’s list and request a known project seeded in the other agency through the app. | The owner sees their agency data only. The other agency’s project is unavailable. |
| US-01.019 | New visitor uses a nine-character otherwise valid password | Complete registration with a unique email and a password that falls one character below the SRS minimum. | Registration is rejected before a usable account or agency is created. |
| US-01.020 | New visitor uses a ten-character password that meets all other configured rules | Complete registration with a unique email. | The password meets the length requirement and the registration can complete. |

### Sign-in and sign-out

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-01.021 | Registered owner signs in with valid credentials | Enter their registered email and correct password. | Authentication succeeds and an active owner reaches the agency workspace. |
| US-01.022 | Registered owner enters the wrong password | Enter their actual email and an incorrect password. | Authentication fails. The session cannot open protected workspace content. |
| US-01.023 | Visitor enters an unregistered email | Submit an otherwise valid-looking sign-in form. | Authentication fails and no session is established. |
| US-01.024 | Visitor submits without an email | Fill in the password only and submit. | The form requests an email and does not start a session. |
| US-01.025 | Visitor submits without a password | Fill in the email only and submit. | The form requests a password and does not start a session. |
| US-01.026 | Visitor corrects an invalid sign-in attempt | After an incorrect password is rejected, submit the correct one. | The corrected sign-in succeeds and reaches the correct workspace. |
| US-01.027 | Signed-in owner signs out | Choose Sign out, then reopen a protected workspace route in the same browser. | The original session no longer grants workspace access. |
| US-01.028 | Signed-in owner signs out of a protected page | After signing out, use browser Back and refresh the previous protected page. | The application requires a valid session before it can serve protected workspace data. |
| US-01.029 | Signed-in owner returns just before seven days of inactivity | Advance a session fixture with no intermediate activity to one second before expiry, then open the workspace. | Inactivity alone has not yet expired the session. |
| US-01.030 | Signed-in owner returns at seven days of inactivity | Open a protected page at the inactivity cutoff. | The expired session cannot access the workspace until the owner signs in again. |

### Password recovery

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-01.031 | Registered user requests a password reset | Enter a registered email and inspect the captured message. | A password-reset email reaches the registered inbox and contains a usable link. |
| US-01.032 | Visitor submits a malformed email for password recovery | Use an invalid email format. | The form rejects the invalid email and does not send a reset message. |
| US-01.033 | Visitor requests recovery for an unregistered email | Use an address absent from the disposable test environment. | No account, reset message, or authenticated session is created for the address. |
| US-01.034 | Registered user opens their reset link well before expiry | Open the captured link 30 minutes after issue and submit a valid new password. | The password changes for the intended user. |
| US-01.035 | Registered user uses an unredeemed link at 59 minutes 59 seconds | Advance the test clock to one second before expiry and redeem the link. | The still-valid link is accepted once. |
| US-01.036 | Registered user opens an unused link at 60 minutes | Advance the test clock to the expiry instant. | The expired link does not change the password. |
| US-01.037 | Registered user opens an unused link after one hour | Open the link at 61 minutes. | The password is unchanged and the expired link is rejected. |
| US-01.038 | Registered user reuses a reset link after changing the password | Open the same link again and attempt a second change. | The used link cannot change the password a second time. |
| US-01.039 | Registered user tries an invalid reset link | Use a fixture link that contains no valid reset token. | The link cannot be used to change a password or establish a session. |
| US-01.040 | Registered user submits an invalid replacement password through a valid link | Enter a value rejected by the configured password policy. | The replacement is rejected and the current password still works. |
| US-01.041 | Registered user signs in with the old password after a successful reset | Use the old password in a fresh session. | Authentication fails. |
| US-01.042 | Registered user signs in with the new password after a successful reset | Use the new password in a fresh session. | Authentication succeeds for the same account and existing agency membership. |
| US-01.043 | Two registered users verify account isolation of a reset | Reset account A, then sign in to account B with B’s original credentials. | Only account A’s password changes. |

## US-02 Send role-based invitations

FR-AUTH-03, FR-AUTH-04, FR-AUTH-06, BR-03, AC-01. Wireframes 5 and 26.

### Recipients, roles, and company

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-02.001 | Owner opens the invitation form | Go to member management and start an invitation. | Email and role can be entered and the client company can be selected for Client. |
| US-02.002 | Manager opens the invitation form | Go to member management and start an invitation. | The Manager can start an invitation for an eligible recipient and role. |
| US-02.003 | Owner or Manager inspects available invitation roles | Open the role selector in each authorized session. | Project Manager, Employee and Client are available. Owner is not an invitation role. |
| US-02.004 | Owner prepares a Client invitation | Select the Client role. | The client company can be selected and is required for submission. |
| US-02.005 | Owner prepares an Employee invitation after choosing a Client company | Select Client and select Northstar. Change the role to Employee and send. | The Employee invitation has no client company association. |
| US-02.006 | Manager chooses between same-agency companies | Invite a Client while both Northstar and Urban Foods are available. Select Urban Foods. | The invitation associates Urban Foods, the company actually selected. |
| US-02.007 | Owner omits the recipient email | Attempt to send an otherwise valid invitation. | The email requirement is shown. No invitation is created and no email is sent. |
| US-02.008 | Owner enters an invalid recipient email | Attempt to send using recipient.example.test. | The malformed email is rejected. No invitation or email is produced. |
| US-02.009 | Manager leaves the role unspecified | Submit with a valid email and no role if the form allows an empty selection. | No invitation is sent without an effective supported role. |
| US-02.010 | Manager submits an unsupported invitation role using the test request fixture | Submit an otherwise valid invitation request with a role outside the supported set. | The server rejects the request. No invitation row or email is created. |
| US-02.011 | Manager tries to invite a new Owner using the test request fixture | Submit the Owner role on an otherwise valid invitation request. | The invitation is rejected and grants no Owner membership. |
| US-02.012 | Owner omits the company for a Client invitation | Submit with a valid email and the Client role. | The company requirement is shown. No invitation or email is created. |
| US-02.013 | Manager tries to associate a company from another agency | Use a Brightside company fixture when inviting a Northline Client. | The invitation is refused. No email or cross-tenant association is created. |
| US-02.014 | Owner tries to associate an unknown company | Reference a nonexistent company fixture on a Client invitation. | The invitation is refused. No email or association is created. |

### Email delivery and lifecycle

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-02.015 | Owner sends an Employee invitation with access to email capture | Compare the recipient address in the pending record and captured email. | Both use the address submitted and the email includes an invitation link. |
| US-02.016 | Manager sends invitations to two different addresses | Capture the two messages and compare the links. | Each intended recipient receives their own invitation link. Opening one selects only its matching invitation. |
| US-02.017 | Owner inspects a just-sent invitation | Compare the sent timestamp and expiration timestamp in the test fixture. | The invitation expires seven days after it was sent. |
| US-02.018 | Invited user opens an unused link one second before expiry | Advance the test clock to seven days minus one second and open the link. | The unused link is still eligible for acceptance. |
| US-02.019 | Invited user opens an unused link at the seven-day cutoff | Advance the test clock to the expiry instant and attempt acceptance. | The link is rejected as expired. The screen offers a path to request another invitation and creates no membership. |
| US-02.020 | Invited user opens a link after seven days | Open the unredeemed link after the expiry cutoff. | The screen explains the expiry and offers a way to request a new invitation. |
| US-02.021 | Invited user reopens a link already redeemed by that user | Use the same link after successful acceptance. | The screen explains that the invitation has been used. It offers a way to request a new invitation and creates no second membership. |
| US-02.022 | Visitor opens a link with a missing token | Open the invitation entry point without a token using the test fixture. | The application shows a usable invalid-link state and creates no membership. |
| US-02.023 | Visitor opens an unrecognized invitation link | Open a fixture link that refers to no stored invitation. | The invitation cannot be accepted and no membership is created. |
| US-02.024 | Owner checks that sending an email does not grant workspace access | Send an invitation and sign in as its recipient before accepting it. | The pending invitation alone does not create membership or grant agency access. |
| US-02.025 | Owner sends invitations for each agency independently | Use separate authorized Owner sessions to send a Northline invitation and a Brightside invitation, then inspect their records. | Each record and email link belongs to the agency that created it. |

### Invitation authorization

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-02.026 | Employee attempts to start an invitation | Open the member management screen as Employee. | The Employee cannot initiate an invitation through the interface. |
| US-02.027 | Employee submits an invitation through the supported server operation | Use the Employee session to make an otherwise valid Employee invitation request. | The server denies it. No invitation or email is produced. |
| US-02.028 | Client attempts to reach the agency invitation screen | Open the invitation management entry point as a Client. | The Client cannot access the agency invitation form or pending invitation data. |
| US-02.029 | Client submits an otherwise valid invitation request | Use the Client session in the authorized test harness. | The server denies it. No invitation or email is produced. |
| US-02.030 | Signed-out visitor submits an otherwise valid invitation request | Run the request without a session. | The server requires authentication and creates no invitation. |
| US-02.031 | Northline Manager targets a Brightside invitation operation | Use the Brightside tenant as the target in the test harness. | Manager rights in Northline do not grant the right to create invitations in Brightside. |
| US-02.032 | Owner retries after a rejected invitation form submission | Correct the invalid address or missing company and submit with the same authorized session. | One valid pending invitation is created and sent to the intended address. |

### Sending by inviter and recipient role

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-02.033 | Owner invites a Project Manager | Send to a fresh mailbox as Owner. Inspect the record and captured email. | The recipient receives a link for a pending Project Manager invitation in the inviter’s agency. |
| US-02.034 | Owner invites a Employee | Send to a fresh mailbox as Owner. Inspect the record and captured email. | The recipient receives a link for a pending Employee invitation in the inviter’s agency. |
| US-02.035 | Owner invites a Client | Send to a fresh mailbox as Owner and select Northstar. Inspect the record and captured email. | The recipient receives a link for a pending Client invitation in the inviter’s agency and Northstar company. |
| US-02.036 | Project Manager invites a Project Manager | Send to a fresh mailbox as Project Manager. Inspect the record and captured email. | The recipient receives a link for a pending Project Manager invitation in the inviter’s agency. |
| US-02.037 | Project Manager invites a Employee | Send to a fresh mailbox as Project Manager. Inspect the record and captured email. | The recipient receives a link for a pending Employee invitation in the inviter’s agency. |
| US-02.038 | Project Manager invites a Client | Send to a fresh mailbox as Project Manager and select Northstar. Inspect the record and captured email. | The recipient receives a link for a pending Client invitation in the inviter’s agency and Northstar company. |

## US-03 Accept an invitation and enter the correct experience

FR-AUTH-05, FR-AUTH-08–09, AC-01. Portal identity and 360 px coverage from EIR-UI-01–03. Wireframes 3, 7, 17, 24 and 26.

### Acceptance and membership integrity

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-03.001 | Invited user opens a valid, unused invitation without completing acceptance | Observe the acceptance page and close it before submitting. | Viewing the link alone creates no membership and does not consume the invitation. |
| US-03.002 | Existing user accepts an invitation to a second agency | Sign in as the email recipient already active in Brightside and accept a Northline invitation. | One identity now has the new Northline membership with the invited role. The Brightside membership and its role are preserved. |
| US-03.003 | Existing user is signed in under a different email | Open a valid invitation addressed to another test account and try to accept it in the current session. | No membership is attached to the wrong account. Acceptance requires the invited account. |
| US-03.004 | Invited user supplies a different email during new-account acceptance | Start from a valid invitation and enter an email that does not match the recipient. | The invitation cannot be used to grant membership to the different address. |
| US-03.005 | Recipient of an Employee invitation attempts to select Manager | During acceptance, try to submit a different role with the test fixture. | The app creates no Manager membership. Any membership created by valid acceptance has the exact invited Employee role. |
| US-03.006 | Recipient of a Northstar invitation attempts to change the company | During acceptance, try to substitute Urban Foods with the test fixture. | No association with Urban Foods is created. Valid acceptance associates the company saved on the invitation. |
| US-03.007 | Existing invited user already has a membership in the inviting agency | Attempt acceptance after a membership with another role is present for that identity. | There is at most one membership for the identity and agency. An invitation cannot silently create an additional membership or elevate access outside authorized role administration. |
| US-03.008 | Same recipient submits acceptance from two open tabs at once | Open one unused invitation in two independent sessions for the same eligible identity and submit both before either finishes. | Exactly one acceptance takes effect and at most one membership is created. |
| US-03.009 | Invited user submits invalid new-account details | Start from a valid link, leave a required account field blank, and submit. | No membership is created and the invitation remains available for a corrected submission. |
| US-03.010 | Invited user corrects invalid account details | Use the same invitation and submit valid values before it expires. | Exactly one membership is created with the original invited role. |
| US-03.011 | Invited user receives a controlled failure during membership creation | Use an approved test fault before membership is saved, then reload after recovery. | An incomplete attempt grants no access and does not permanently consume the invitation without creating the membership. |
| US-03.012 | Signed-in user who was never invited attempts to join an existing agency | Open the supported join entry point without an invitation. | Agency membership requires an invitation. No access is granted. |
| US-03.013 | Uninvited user submits a normal membership request without an invitation | Use the authorized server test harness with a fresh identity. | The server refuses the join, and a session-scoped database check confirms no membership was created. |
| US-03.014 | Existing user with a pending invitation signs in before accepting it | Open the inviting agency’s protected page in a fresh session. | Pending status alone grants no access to the inviting agency. |

### Routes, session boundaries, and client portal

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-03.015 | Signed-out visitor opens a protected staff page | Navigate directly to Team in a fresh browser session. | The sign-in experience appears and staff content is unavailable. |
| US-03.016 | Signed-out visitor opens a protected client page | Navigate directly to the client portal in a fresh browser session. | Authentication is required before any client project or agency content is returned. |
| US-03.017 | Signed-in user has no active agency membership | Visit a protected staff page using a valid account with no membership. | The application shows an access-denial or no-agency state and returns no staff data. |
| US-03.018 | Signed-in user with no membership tries a client route | Open the portal with a valid account that has no active membership. | The account is not treated as a Client and receives no portal records. |
| US-03.019 | Client opens the portal for an agency with an uploaded logo | Sign in as its Client and inspect the header. | The portal shows the current agency's name and uploaded logo. |
| US-03.020 | Client opens the portal for an agency with no uploaded logo | Inspect the portal header using the separate no-logo fixture. | The correct agency name remains visible and the header stays usable. |
| US-03.021 | Client navigates the portal at 360 px | Open the landing page and move through the available client navigation. | The client experience is usable at 360 px and exposes no staff sidebar or agency-internal navigation. |
| US-03.022 | Client inspects portal labels and links at desktop width | Open the portal home and inspect the navigation and headings. | Platform-internal terminology and staff workspace links are absent. |
| US-03.023 | Client opens a staff-only link shared by an Owner | Open the copied Team link using a Client session. | Agency data and the staff sidebar remain unavailable to the client. |
| US-03.024 | Client tries retrieving the invitation list through the supported data path | Query the invitation list using the Client session under ordinary database access controls. | Staff invitation records are not returned. |
| US-03.025 | Owner completes the AC-01 onboarding journey | Register a new agency, invite one Employee and one Client, accept each invitation in an independent session, then open each experience's protected entry point as the other role. | Owner and Employee land in the workspace and the Client lands in the portal. Each experience rejects the other experience’s users. |

### Acceptance by role and account type

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-03.026 | New account accepts the Project Manager role | Complete account creation as the recipient and accept the Project Manager invitation. | One active Project Manager membership belongs to the correct identity and agency. The user lands in the agency workspace. |
| US-03.027 | New account accepts the Employee role | Complete account creation as the recipient and accept the Employee invitation. | One active Employee membership belongs to the correct identity and agency. The user lands in the agency workspace. |
| US-03.028 | New account accepts the Client role | Complete account creation as the recipient and accept the Client invitation. | One active Client membership belongs to the correct identity and agency and matches the invited company. The user lands in the client portal. |
| US-03.029 | Existing account accepts the Project Manager role | Authenticate the existing account as the recipient and accept the Project Manager invitation. | One active Project Manager membership belongs to the correct identity and agency. The user lands in the agency workspace. |
| US-03.030 | Existing account accepts the Employee role | Authenticate the existing account as the recipient and accept the Employee invitation. | One active Employee membership belongs to the correct identity and agency. The user lands in the agency workspace. |
| US-03.031 | Existing account accepts the Client role | Authenticate the existing account as the recipient and accept the Client invitation. | One active Client membership belongs to the correct identity and agency and matches the invited company. The user lands in the client portal. |

### Landing and protected routes across all roles

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-03.032 | Owner signs in with an active membership | Sign in as Owner in a fresh session. | Sign-in lands in the agency workspace for that membership. |
| US-03.033 | Owner opens the other experience | Open the portal home directly with the Owner session. | Protected data for the other experience is unavailable. The user stays in or is returned to the agency workspace. |
| US-03.034 | Owner reloads their authorized experience | Open the agency workspace with an active session, then refresh. | The correct agency and role are maintained between requests. |
| US-03.035 | Project Manager signs in with an active membership | Sign in as Project Manager in a fresh session. | Sign-in lands in the agency workspace for that membership. |
| US-03.036 | Project Manager opens the other experience | Open the portal home directly with the Project Manager session. | Protected data for the other experience is unavailable. The user stays in or is returned to the agency workspace. |
| US-03.037 | Project Manager reloads their authorized experience | Open the agency workspace with an active session, then refresh. | The correct agency and role are maintained between requests. |
| US-03.038 | Employee signs in with an active membership | Sign in as Employee in a fresh session. | Sign-in lands in the agency workspace for that membership. |
| US-03.039 | Employee opens the other experience | Open the portal home directly with the Employee session. | Protected data for the other experience is unavailable. The user stays in or is returned to the agency workspace. |
| US-03.040 | Employee reloads their authorized experience | Open the agency workspace with an active session, then refresh. | The correct agency and role are maintained between requests. |
| US-03.041 | Client signs in with an active membership | Sign in as Client in a fresh session. | Sign-in lands in the client portal for that membership. |
| US-03.042 | Client opens the other experience | Open Team directly with the Client session. | Protected data for the other experience is unavailable. The user stays in or is returned to the client portal. |
| US-03.043 | Client reloads their authorized experience | Open the client portal with an active session, then refresh. | The correct agency and role are maintained between requests. |

## US-04 Manage and remove access

FR-AUTH-07, FR-AUTH-09. Wireframes 5–6.

### Role changes

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-04.001 | Owner changes an active Employee to Manager | Save the change and reload member management. | The existing membership now has the Manager role. User identity, tenant and membership history are preserved. |
| US-04.002 | Promoted Employee refreshes their active session | Reload after the Owner grants the Manager role and try the authorized invitation form. | The member’s effective role updates and Manager capabilities become available. |
| US-04.003 | Owner changes an active Manager to Employee | Save the change while the Manager has an active session. | The membership remains active and now carries the Employee role. |
| US-04.004 | Demoted Manager retries an invitation after the role change | Submit an invitation using the existing Employee session. | Manager permissions are gone. No invitation or email is created. |
| US-04.005 | Owner inspects the member’s previous work after a role change | Compare tasks and historical records created under the old role before and after the change. | The records still exist and refer to the same user. |
| US-04.006 | Owner attempts an unsupported role change | Choose an invalid role value using the authorized test harness. | The request is rejected and the existing role is retained. |
| US-04.007 | Northline Owner tries to change a Brightside member's role | Use the other tenant’s membership fixture under the Northline Owner session. | The role remains unchanged. Northline Owner rights do not apply to Brightside. |

### Invitation revocation

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-04.008 | Owner revokes a pending invitation | Select the pending invitation and confirm revocation. Reload the list. | The recorded invitation is revoked and can no longer be used. |
| US-04.009 | Invited user opens the revoked invitation | Use the original email link after the Owner revokes it. | Acceptance is refused and no account membership is granted. |
| US-04.010 | Owner checks that revocation is limited to one invitation | Revoke one of two pending invitations and redeem the other as its own recipient. | Only the selected invitation is disabled. The other remains usable. |
| US-04.011 | Owner tries to revoke an invitation already accepted | Attempt the pending-invitation operation on the accepted record. | The accepted membership remains intact and revocation does not retroactively remove access. |
| US-04.012 | Owner tries to revoke an expired invitation | Attempt the operation on an already expired record. | The link remains unusable and no active pending invitation or membership is created. |
| US-04.013 | Owner repeats revocation for the same invitation | Submit the action twice in quick succession. | The selected invitation ends up revoked once and other invitations stay unchanged. |
| US-04.014 | Northline Owner tries to revoke Brightside's pending invitation | Use the Brightside fixture in the authorized test harness. | The request is denied and the Brightside invitation remains pending. |

### Member deactivation

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-04.015 | Owner deactivates an Employee who has an active session | Confirm deactivation and reload the member list. | The membership is inactive and its historical record remains available to authorized staff. |
| US-04.016 | Deactivated Employee reloads a protected page in an existing session | Keep the previous browser session and reload immediately after the Owner deactivates the membership. | The old session cannot load the agency workspace. |
| US-04.017 | Deactivated Employee tries an outstanding write | Leave a permitted task-status form open before deactivation and submit after deactivation. | The server denies the write and the task stays unchanged. |
| US-04.018 | Deactivated Employee starts an entirely new sign-in session | Sign in again with the correct credentials. | Authentication alone cannot restore the deactivated agency membership. |
| US-04.019 | Owner deactivates a Client with an active portal session | Refresh the client portal and request its project in the existing session. | Access to that agency portal and its client records ends immediately. |
| US-04.020 | Owner deactivates a member who also belongs to another agency | Deactivate the Northline membership and use the other agency’s ordinary entry point. | Access is removed only in Northline. The other active membership is unaffected. |
| US-04.021 | Owner checks historical tasks after deactivating their assignee | Open the original task and inspect the retained user association. | Task history and its original actor or assignee references remain intact. |
| US-04.022 | Owner checks historical messages after deactivating their author | Open the project messages originally created by the inactive member. | The historical messages and author references remain intact. |
| US-04.023 | Owner checks membership-scoped deactivation against a second user | Deactivate one Employee. Sign in as another Employee in the same agency. | The other Employee’s membership and access stay active. |
| US-04.024 | Northline Owner tries deactivating a Brightside member | Use the Brightside fixture in the authorized test harness. | The request is denied and the other tenant’s member retains access. |

### Member administration by role

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-04.025 | Project Manager attempts a member role change | Submit the normal role-change operation for another member with the Project Manager session. | The operation is denied and the target’s role is unchanged. |
| US-04.026 | Project Manager attempts member deactivation | Use the normal deactivate operation for another active member with the Project Manager session. | The operation is denied and the target remains active. |
| US-04.027 | Employee attempts a member role change | Submit the normal role-change operation for another member with the Employee session. | The operation is denied and the target’s role is unchanged. |
| US-04.028 | Employee attempts member deactivation | Use the normal deactivate operation for another active member with the Employee session. | The operation is denied and the target remains active. |
| US-04.029 | Client attempts a member role change | Submit the normal role-change operation for another member with the Client session. | The operation is denied and the target’s role is unchanged. |
| US-04.030 | Client attempts member deactivation | Use the normal deactivate operation for another active member with the Client session. | The operation is denied and the target remains active. |

### Revocation authorization

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-04.031 | Employee attempts to revoke a pending invitation | Request revocation on the Northline fixture with the specified session state. | Revocation is denied and the invitation stays pending. |
| US-04.032 | Client attempts to revoke a pending invitation | Request revocation on the Northline fixture with the specified session state. | Revocation is denied and the invitation stays pending. |
| US-04.033 | Signed-out visitor attempts to revoke a pending invitation | Request revocation on the Northline fixture with the specified session state. | Revocation is denied and the invitation stays pending. |

## US-05 Create client companies and projects and assign users

FR-PRJ-01–03, BR-08. Tenant checks use NFR-SEC-01 and BR-04. Wireframes 8–9 and 28.

### Client companies

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-05.001 | Owner creates a client company | Enter a distinct company name in Northline and save. Reload the list and detail. | Exactly one company is saved under Northline and its data remains visible to the Owner. |
| US-05.002 | Manager creates a client company | Enter valid company data in Northline and save. | The company persists and is available when selecting a company for a Northline project. |
| US-05.003 | Owner edits a client company | Change a fixture company’s name and reload its detail. | The update persists on the same record and remains in the same agency. |
| US-05.004 | Manager edits a client company | Update valid company details and reopen its record. | The updated details persist and related projects remain associated with the original company record. |
| US-05.005 | Manager omits the company name | Submit a new client company with the name blank. | Validation is shown and no company is created. |
| US-05.006 | Manager uses whitespace as the company name | Submit a company name made entirely of spaces. | The blank name is rejected and no company is created. |
| US-05.007 | Manager edits a nonexistent company fixture | Open or submit an edit against a company that no longer exists. | The app reports the company as unavailable and does not create a substitute record. |
| US-05.008 | Northline Owner lists client companies | Seed companies in both agencies and load the client company list. | The list uses the current agency. Brightside companies are absent. |
| US-05.009 | Northline Manager tries editing a Brightside company | Open the app’s editing operation for a known company fixture from Brightside using a Northline Manager session. | The target is unavailable and the Brightside record is unchanged. |
| US-05.010 | Northline Client opens the staff company detail | Use a Client session and open the staff company record for their agency. | The internal management page is unavailable. Portal access continues through assigned projects. |

### Project data

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-05.011 | Manager creates a project for Northstar | Enter a unique name, description, start date, target end date and valid status. Choose Northstar and save. | The project contains all entered fields and belongs to Northstar in Northline. |
| US-05.012 | Owner creates a project for Urban Foods | Submit valid fields and save the project for Urban Foods. | Project creation succeeds in the Owner’s agency. The saved client company is Urban Foods. |
| US-05.013 | Manager creates two projects for the same company | Save two projects with distinct names and valid dates for Northstar. | Each gets a separate identity and both are linked to the same company. |
| US-05.014 | Manager creates projects for different companies | Save one project for Northstar and another for Urban Foods. | Each project retains its own company association. |
| US-05.015 | Manager saves a multiline project description | Enter line breaks in the description and reopen the saved project. | The stored description retains the text and line breaks. |
| US-05.016 | Manager omits the project name | Choose a company and fill the remaining valid fields, then submit. | The name requirement is shown and no project is created. |
| US-05.017 | Manager omits the client company | Submit otherwise valid project fields without a company. | Validation requires the company, and no unassociated project is created. |
| US-05.018 | Manager submits an invalid start date | Enter a malformed start date in the test request fixture. | The date is rejected and no invalid project is created. |
| US-05.019 | Manager submits an invalid target end date | Enter a non-calendar target date in the test request fixture. | The date is rejected and no invalid project is created. |
| US-05.020 | Manager submits an unsupported project status | Submit a value outside the project's supported status set. | The server rejects the value and does not create an invalid project. |
| US-05.021 | Manager chooses a company outside the current tenant | Use a known Brightside company fixture while creating a Northline project. | No project is saved with the cross-tenant company. |
| US-05.022 | Manager chooses a company that no longer exists | Open a stale project form and submit the removed company fixture. | Validation rejects the company and no project is created. |
| US-05.023 | Manager opens a freshly saved project from the list | Find the project in its own agency, open the detail, and refresh. | The correct project opens and its name, description, dates, status and company remain intact. |
| US-05.024 | Northline Manager loads the project list and tries an ordinary direct link to a Brightside fixture | Use their Northline session for both reads. | The Brightside project is absent from the list and unavailable by direct link. |

### Assignments

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-05.025 | Manager assigns an active Northline Employee to a Northline project | Add the Employee and reload the project members. | The Employee remains assigned and the association points to the selected project. |
| US-05.026 | Owner assigns an Employee to a Northline project | Save the assignment and inspect the member list. | The existing Employee is associated with the project in the Owner's agency. |
| US-05.027 | Manager assigns a Northstar Client to a Northstar project | Save the assignment and open the project list using that Client’s session. | The client project appears after assignment. |
| US-05.028 | Owner assigns a matching Client to a project | Choose a client belonging to the project's company and save. | The assigned Client can access that specific project. |
| US-05.029 | Manager assigns two Clients from the same company to one project | Assign two separate Northstar client accounts. | Each assignment is retained, and both assigned accounts can access the project. |
| US-05.030 | Manager assigns one Client to two projects for their company | Assign the same Northstar client account to two distinct Northstar projects. | The Client can open both explicitly assigned projects. |
| US-05.031 | Manager leaves a second project for the same company unassigned | Assign the Client to the first Northstar project only, then inspect the client project list. | The second project does not appear merely because its company matches. |
| US-05.032 | Northstar Client opens an unassigned project for their own company directly | Use the known project link from the fixture while signed in as that Client. | The project is unavailable and no project fields or related records are returned. |
| US-05.033 | Manager tries assigning a Northstar Client to an Urban Foods project | Use eligible records in the same agency but different companies. | The mismatched company assignment is rejected and creates no access. |
| US-05.034 | Manager tries assigning a Brightside Client to Northline | Use the known client fixture from the other agency. | No assignment is saved and the client gains no Northline access. |
| US-05.035 | Manager tries assigning a Brightside Employee to Northline | Use the employee fixture from the other agency. | The assignment is rejected and the project member list is unchanged. |
| US-05.036 | Manager uses a nonexistent project for assignment | Submit an otherwise eligible user with a removed project fixture. | No dangling project assignment is created. |
| US-05.037 | Manager uses a nonexistent user for assignment | Submit an otherwise eligible project with an unknown user fixture. | No dangling project assignment is created. |
| US-05.038 | Manager submits an existing assignment twice | Select an Employee or Client who is already assigned and save again. | The project retains a single effective assignment for that account. |
| US-05.039 | Manager adds an Employee and a Client to the same project | Save both assignments and compare internal and client project views. | Both assignments persist. Only each account’s role-appropriate experience is granted. |

### Project and company operations by role

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-05.040 | Employee attempts company creation | Submit otherwise valid company fields as Employee. | The company is not created. |
| US-05.041 | Employee attempts a company edit | Submit a valid change to an existing company as Employee. | The original company record remains unchanged. |
| US-05.042 | Employee attempts project creation | Submit valid project fields for a matching company as Employee. | The project is not created. |
| US-05.043 | Employee attempts assigning an Employee | Submit an otherwise valid Employee assignment as Employee. | The Employee is not assigned. |
| US-05.044 | Employee attempts assigning a Client | Submit an otherwise valid Client assignment as Employee. | The assignment is not created and no client access is gained. |
| US-05.045 | Client attempts company creation | Submit otherwise valid company fields as Client. | The company is not created. |
| US-05.046 | Client attempts a company edit | Submit a valid change to an existing company as Client. | The original company record remains unchanged. |
| US-05.047 | Client attempts project creation | Submit valid project fields for a matching company as Client. | The project is not created. |
| US-05.048 | Client attempts assigning an Employee | Submit an otherwise valid Employee assignment as Client. | The Employee is not assigned. |
| US-05.049 | Client attempts assigning a Client | Submit an otherwise valid Client assignment as Client. | The assignment is not created and no client access is gained. |

## US-06 Control client visibility

FR-PRJ-04–05, BR-01, BR-02, BR-07, AC-02, AC-03. Database and files use NFR-SEC-02–03 and FR-DEL-12. Wireframes 9, 13, 24–25 and 28.

### Assignee disclosure and client experience

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-06.001 | Manager shares an assigned task with project disclosure left at default | View the task as the assigned Client. | Task status is visible and the Employee’s name is absent. |
| US-06.002 | Manager enables assignee disclosure for one project | Reopen the shared assigned task as the Client. | The Employee’s name appears with the task status. |
| US-06.003 | Manager disables previously enabled assignee disclosure | Refresh the same task as the Client. | The Employee name is hidden again and task status stays available. |
| US-06.004 | Manager enables disclosure on project A only | Use two explicitly assigned projects for the same Client and compare their shared tasks. | Assignee names show in A only. Project B retains the default. |
| US-06.005 | Manager enables disclosure while a task stays Internal | Open the project as the assigned Client. | Disclosure does not publish the Internal task or reveal its assignee. |
| US-06.006 | Manager shares a task that currently has no assignee | Open the task as Client with disclosure enabled. | The task status appears without a fabricated employee name. |
| US-06.007 | Manager reassigns a visible task with disclosure enabled | Change from one eligible account to another and refresh the Client view. | The display shows the current assignee and status. |
| US-06.008 | Manager reassigns a visible task with disclosure disabled | Compare list, detail, and the normal portal response before and after reassignment. | The employee name is absent from each client-facing response. |
| US-06.009 | Assigned Client inspects the response for a visible task with disclosure disabled | Read the normal portal response using the authorized test harness. | The name is excluded from the response and is not merely hidden by the browser interface. |
| US-06.010 | Client opens the staff task board | Use the client session and open the board for an assigned project. | The internal staff board and its internal comments are unavailable. |
| US-06.011 | Client reads a shared task with a linked Internal comment | Open the shared task in the client experience. | The shared task appears without its Internal comment. |
| US-06.012 | Client opens a visible file attached to an authorized project | Use the approved download action. | The server authorizes the file and returns a signed URL that can retrieve it within its configured lifetime. |
| US-06.013 | Client tests the expiry on an authorized file link | Use the signed link within its lifetime and again after its expiry. | The valid link works for its file and expires no later than 15 minutes after issue. |
| US-06.014 | Client uses the raw storage path for an Internal file fixture | Try the ordinary storage read with the Client session and no signed authorization. | The request cannot retrieve the file. |
| US-06.015 | Assigned Client receives a signed file link, then the file becomes Internal | After the Owner reverses visibility, use the project to request a new signed link. | The server refuses to issue a fresh link for the now-Internal file. |
| US-06.016 | Manager shares one file when another file stays Internal | Open the visible file listing and download options as the client. | Only the explicitly shared file is listed and downloadable. |
| US-06.017 | Manager shares a file and task while keeping a second pair Internal | Open the assigned project as a Client in a fresh session and compare the records with the staff fixture list. | Exactly the explicitly shared tasks and files are available, satisfying AC-02. |
| US-06.018 | Manager shares an item while the client remains unassigned | Request the item using a Client who belongs to the correct company but lacks the project's assignment. | Client-visible status alone does not grant project access. |
| US-06.019 | Client switches between two assigned projects with different shared items | Inspect project A and project B separately. | Each view shows only the visible items for that project. |
| US-06.020 | Client opens an assigned project with no visible items | Inspect its task, file and message sections while staff fixtures contain only Internal records. | The project remains available, and the three lists disclose no internal items. |

### Default visibility by item type

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-06.021 | New task defaults to Internal | Create a task with the supported staff action without choosing visibility. Inspect the saved record. | The saved task has Internal visibility. |
| US-06.022 | Client cannot see a default Internal task | As an assigned Client, check the project listing after staff creates an Internal task. | The task is absent from the listing. |
| US-06.023 | New file defaults to Internal | Create a file with the supported staff action without choosing visibility. Inspect the saved record. | The saved file has Internal visibility. |
| US-06.024 | Client cannot see a default Internal file | As an assigned Client, check the project listing after staff creates an Internal file. | The file is absent from the listing. |
| US-06.025 | New message defaults to Internal | Create a message with the supported staff action without choosing visibility. Inspect the saved record. | The saved message has Internal visibility. |
| US-06.026 | Client cannot see a default Internal message | As an assigned Client, check the project listing after staff creates an Internal message. | The message is absent from the listing. |

### Share and revert by authorized role

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-06.027 | Owner explicitly shares a task | Start with an Internal task on an assigned project, select Client-visible as Owner, and refresh as the assigned Client. | Client-visible persists and the assigned Client can read the task. |
| US-06.028 | Owner returns a shared task to Internal | Start with a Client-visible task, reverse visibility as Owner, and request the record in a fresh Client session. | Internal persists. The task disappears from the listing and a new client read is refused. |
| US-06.029 | Project Manager explicitly shares a task | Start with an Internal task on an assigned project, select Client-visible as Project Manager, and refresh as the assigned Client. | Client-visible persists and the assigned Client can read the task. |
| US-06.030 | Project Manager returns a shared task to Internal | Start with a Client-visible task, reverse visibility as Project Manager, and request the record in a fresh Client session. | Internal persists. The task disappears from the listing and a new client read is refused. |
| US-06.031 | Owner explicitly shares a file | Start with an Internal file on an assigned project, select Client-visible as Owner, and refresh as the assigned Client. | Client-visible persists and the assigned Client can read the file. |
| US-06.032 | Owner returns a shared file to Internal | Start with a Client-visible file, reverse visibility as Owner, and request the record in a fresh Client session. | Internal persists. The file disappears from the listing and a new client read or download link is refused. |
| US-06.033 | Project Manager explicitly shares a file | Start with an Internal file on an assigned project, select Client-visible as Project Manager, and refresh as the assigned Client. | Client-visible persists and the assigned Client can read the file. |
| US-06.034 | Project Manager returns a shared file to Internal | Start with a Client-visible file, reverse visibility as Project Manager, and request the record in a fresh Client session. | Internal persists. The file disappears from the listing and a new client read or download link is refused. |
| US-06.035 | Owner explicitly shares a message | Start with an Internal message on an assigned project, select Client-visible as Owner, and refresh as the assigned Client. | Client-visible persists and the assigned Client can read the message. |
| US-06.036 | Owner returns a shared message to Internal | Start with a Client-visible message, reverse visibility as Owner, and request the record in a fresh Client session. | Internal persists. The message disappears from the listing and a new client read is refused. |
| US-06.037 | Project Manager explicitly shares a message | Start with an Internal message on an assigned project, select Client-visible as Project Manager, and refresh as the assigned Client. | Client-visible persists and the assigned Client can read the message. |
| US-06.038 | Project Manager returns a shared message to Internal | Start with a Client-visible message, reverse visibility as Project Manager, and request the record in a fresh Client session. | Internal persists. The message disappears from the listing and a new client read is refused. |

### Visibility writes by unauthorized role

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-06.039 | Employee attempts to publish an Internal task | Submit a visibility-only change for an Internal task using the Employee session and the approved fixture harness. | The write cannot publish the task. Internal visibility is retained. |
| US-06.040 | Employee attempts to make a shared task Internal | Submit a sharing reversal for a shared task in the Employee session. | The write is denied and visibility remains Client-visible. |
| US-06.041 | Client attempts to publish an Internal task | Submit a visibility-only change for an Internal task using the Client session and the approved fixture harness. | The write cannot publish the task. Internal visibility is retained. |
| US-06.042 | Client attempts to make a shared task Internal | Submit a sharing reversal for a shared task in the Client session. | The write is denied and visibility remains Client-visible. |
| US-06.043 | Employee attempts to publish an Internal file | Submit a visibility-only change for an Internal file using the Employee session and the approved fixture harness. | The write cannot publish the file. Internal visibility is retained. |
| US-06.044 | Employee attempts to make a shared file Internal | Submit a sharing reversal for a shared file in the Employee session. | The write is denied and visibility remains Client-visible. |
| US-06.045 | Client attempts to publish an Internal file | Submit a visibility-only change for an Internal file using the Client session and the approved fixture harness. | The write cannot publish the file. Internal visibility is retained. |
| US-06.046 | Client attempts to make a shared file Internal | Submit a sharing reversal for a shared file in the Client session. | The write is denied and visibility remains Client-visible. |
| US-06.047 | Employee attempts to publish an Internal message | Submit a visibility-only change for an Internal message using the Employee session and the approved fixture harness. | The write cannot publish the message. Internal visibility is retained. |
| US-06.048 | Employee attempts to make a shared message Internal | Submit a sharing reversal for a shared message in the Employee session. | The write is denied and visibility remains Client-visible. |
| US-06.049 | Client attempts to publish an Internal message | Submit a visibility-only change for an Internal message using the Client session and the approved fixture harness. | The write cannot publish the message. Internal visibility is retained. |
| US-06.050 | Client attempts to make a shared message Internal | Submit a sharing reversal for a shared message in the Client session. | The write is denied and visibility remains Client-visible. |

### Listing and direct reads by record type

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-06.051 | Task listing for assigned Internal fixture | Place the task on the Client’s assigned project where the target item is Internal. Open the Client’s normal project and item lists. | The lists disclose no data from the target task. |
| US-06.052 | Direct task read for assigned Internal fixture | Request the fixture task from the Client’s assigned project where the target item is Internal through the normal application read or download operation in the Client session. | No task content or protected metadata is returned. |
| US-06.053 | Task listing for same-company unassigned fixture | Place the task on an unassigned project of the Client’s own company with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target task. |
| US-06.054 | Direct task read for same-company unassigned fixture | Request the fixture task from an unassigned project of the Client’s own company with a Client-visible item through the normal application read or download operation in the Client session. | No task content or protected metadata is returned. |
| US-06.055 | Task listing for same-agency other company fixture | Place the task on a project of another company in the same agency with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target task. |
| US-06.056 | Direct task read for same-agency other company fixture | Request the fixture task from a project of another company in the same agency with a Client-visible item through the normal application read or download operation in the Client session. | No task content or protected metadata is returned. |
| US-06.057 | Task listing for different agency fixture | Place the task on a project in another agency with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target task. |
| US-06.058 | Direct task read for different agency fixture | Request the fixture task from a project in another agency with a Client-visible item through the normal application read or download operation in the Client session. | No task content or protected metadata is returned. |
| US-06.059 | File listing for assigned Internal fixture | Place the file on the Client’s assigned project where the target item is Internal. Open the Client’s normal project and item lists. | The lists disclose no data from the target file. |
| US-06.060 | Direct file read for assigned Internal fixture | Request the fixture file from the Client’s assigned project where the target item is Internal through the normal application read or download operation in the Client session. | No file content or protected metadata is returned and no signed URL is issued. |
| US-06.061 | File listing for same-company unassigned fixture | Place the file on an unassigned project of the Client’s own company with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target file. |
| US-06.062 | Direct file read for same-company unassigned fixture | Request the fixture file from an unassigned project of the Client’s own company with a Client-visible item through the normal application read or download operation in the Client session. | No file content or protected metadata is returned and no signed URL is issued. |
| US-06.063 | File listing for same-agency other company fixture | Place the file on a project of another company in the same agency with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target file. |
| US-06.064 | Direct file read for same-agency other company fixture | Request the fixture file from a project of another company in the same agency with a Client-visible item through the normal application read or download operation in the Client session. | No file content or protected metadata is returned and no signed URL is issued. |
| US-06.065 | File listing for different agency fixture | Place the file on a project in another agency with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target file. |
| US-06.066 | Direct file read for different agency fixture | Request the fixture file from a project in another agency with a Client-visible item through the normal application read or download operation in the Client session. | No file content or protected metadata is returned and no signed URL is issued. |
| US-06.067 | Message listing for assigned Internal fixture | Place the message on the Client’s assigned project where the target item is Internal. Open the Client’s normal project and item lists. | The lists disclose no data from the target message. |
| US-06.068 | Direct message read for assigned Internal fixture | Request the fixture message from the Client’s assigned project where the target item is Internal through the normal application read or download operation in the Client session. | No message content or protected metadata is returned. |
| US-06.069 | Message listing for same-company unassigned fixture | Place the message on an unassigned project of the Client’s own company with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target message. |
| US-06.070 | Direct message read for same-company unassigned fixture | Request the fixture message from an unassigned project of the Client’s own company with a Client-visible item through the normal application read or download operation in the Client session. | No message content or protected metadata is returned. |
| US-06.071 | Message listing for same-agency other company fixture | Place the message on a project of another company in the same agency with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target message. |
| US-06.072 | Direct message read for same-agency other company fixture | Request the fixture message from a project of another company in the same agency with a Client-visible item through the normal application read or download operation in the Client session. | No message content or protected metadata is returned. |
| US-06.073 | Message listing for different agency fixture | Place the message on a project in another agency with a Client-visible item. Open the Client’s normal project and item lists. | The lists disclose no data from the target message. |
| US-06.074 | Direct message read for different agency fixture | Request the fixture message from a project in another agency with a Client-visible item through the normal application read or download operation in the Client session. | No message content or protected metadata is returned. |

### Database read enforcement for client sessions

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-06.075 | Client database read of an authorized shared task | Use the ordinary signed-in Client session for a Client-visible task in an assigned project through the database-facing interface. | The client policy permits the authorized task read. |
| US-06.076 | Client database read of an Internal task | Use the ordinary signed-in Client session for the target task on an assigned project. | The database policy withholds the task. |
| US-06.077 | Client database read of another company’s task | Use the ordinary signed-in Client session for the target task on another company’s project in the same agency. | The database policy withholds the task. |
| US-06.078 | Client database read of another agency’s task | Use the ordinary signed-in Client session for the target task on another tenant’s project. | The database policy withholds the task. |
| US-06.079 | Client database read of an authorized shared file | Use the ordinary signed-in Client session for a Client-visible file in an assigned project through the database-facing interface. | The client policy permits the authorized file read. |
| US-06.080 | Client database read of an Internal file | Use the ordinary signed-in Client session for the target file on an assigned project. | The database policy withholds the file. |
| US-06.081 | Client database read of another company’s file | Use the ordinary signed-in Client session for the target file on another company’s project in the same agency. | The database policy withholds the file. |
| US-06.082 | Client database read of another agency’s file | Use the ordinary signed-in Client session for the target file on another tenant’s project. | The database policy withholds the file. |
| US-06.083 | Client database read of an authorized shared message | Use the ordinary signed-in Client session for a Client-visible message in an assigned project through the database-facing interface. | The client policy permits the authorized message read. |
| US-06.084 | Client database read of an Internal message | Use the ordinary signed-in Client session for the target message on an assigned project. | The database policy withholds the message. |
| US-06.085 | Client database read of another company’s message | Use the ordinary signed-in Client session for the target message on another company’s project in the same agency. | The database policy withholds the message. |
| US-06.086 | Client database read of another agency’s message | Use the ordinary signed-in Client session for the target message on another tenant’s project. | The database policy withholds the message. |

## US-07 Create tasks and enforce status transitions

FR-PRJ-06–07, SRS section 7.3. Wireframes 10 and 13.

### Task data and validation

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-07.001 | Manager creates a task with all documented fields | Select a project and eligible Employee. Enter a unique title, multiline description, future due date and Medium priority. Save, then refresh the task detail. | The task belongs to the correct project. All values persist and the task has one valid status. |
| US-07.002 | Manager saves an accented title | Create a task titled Révision créative and reopen it. | The task retains the title text and accents. |
| US-07.003 | Manager saves a multiline task description | Enter a description with two distinct lines and reload after save. | Both lines remain in the saved description. |
| US-07.004 | Manager creates two tasks on one project | Use two distinct titles and different assignees, due dates and priorities. | Two separate tasks exist, each with its own fields and assignee. |
| US-07.005 | Manager creates one task on each of two projects | Use distinct fixture data for each project. | Both tasks retain their own project association. |
| US-07.006 | Manager opens a new task from its project list | Save the task, find it in the project and open it. | The correct task appears in the correct project and loads its saved fields. |
| US-07.007 | Manager creates a task with an assignee also active in a second agency | Choose the user in the current agency's project and save. | The task belongs to the current agency, and being active elsewhere does not change that association. |
| US-07.008 | Manager creates a task due on a leap day | Use 29 February 2028 as the valid due date and reload. | The calendar date persists as 29 February 2028. |
| US-07.009 | Manager creates a task due in a different timezone | Save a date-only value in the agency timezone, then open the task from a browser with a different timezone. | The saved due date remains the same calendar day. |
| US-07.010 | Manager omits the task title | Complete other fields and submit the form. | Validation requests a title and no task is created. |
| US-07.011 | Manager uses only whitespace for the task title | Submit a title containing spaces and tabs. | The blank title is rejected and no task is created. |
| US-07.012 | Manager supplies an invalid due date | Try 30 February in the test data. | The invalid date is rejected and no malformed task is created. |
| US-07.013 | Manager supplies an unsupported priority | Submit a priority outside Low, Medium, High or Urgent through the test harness. | The server rejects the value and no task with an invalid priority is saved. |
| US-07.014 | Manager supplies an unsupported status | Submit an unknown status value through the authorized task operation. | A task is never created or updated with a status outside the five supported values. |
| US-07.015 | Manager supplies two simultaneous statuses | In a validation test fixture, represent two distinct statuses in one task write. | The operation cannot persist multiple statuses. Any saved task has exactly one status. |
| US-07.016 | Manager supplies no explicit status at creation | Create a task through the default workflow using valid fields. | The new task has one supported initial status. |
| US-07.017 | Manager selects a missing assignee | Use a removed account fixture in otherwise valid task data. | No invalid assignee reference persists. |
| US-07.018 | Northline Manager selects a Brightside assignee | Use a known employee fixture from another agency for a Northline task. | No cross-tenant assignment is persisted. |
| US-07.019 | Northline Manager tries to create a task in a Brightside project | Submit valid task fields for the other agency's project fixture. | The write is denied and no task is created in the other agency. |
| US-07.020 | Manager tries creating a task in a nonexistent project | Use a missing project fixture and valid fields. | The operation returns an unavailable-project or validation outcome and leaves no dangling task. |
| US-07.021 | Client tries to create a task in an assigned project | Use the ordinary task creation entry point with a Client session. | The client cannot create staff tasks and no task is written. |
| US-07.022 | Client tries to alter a staff task's assignee | Use a visible task owned by an assigned project. | The operation cannot change the task’s assignee. |
| US-07.023 | Signed-out visitor attempts to create a task | Submit an otherwise valid task operation with no session. | Authentication is required and no task is created. |
| US-07.024 | Manager corrects validation errors on a task form | After an invalid title is rejected, fix the title and submit the same task fields. | A single valid task is created and no partial task remains. |

### Transition sequences and record integrity

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-07.025 | Assigned Employee moves a task through the staff handoff to review | Move To Do to In Progress and then to In Review. Reopen the record. | Both permitted steps persist in order and the task retains a single status of In Review. |
| US-07.026 | Manager completes a task after internal review | Open an In Review task, mark it Done, and reopen it. | Done persists on the same task without modifying its title, project, priority or due date. |
| US-07.027 | Manager returns a reviewed task to work | Move an In Review task back to In Progress and inspect it as the assigned Employee. | The task is again In Progress, with the same identity and assignee. |
| US-07.028 | Assigned Employee resumes a blocked task | Move Blocked to In Progress and refresh. | The task is In Progress and its other saved fields remain intact. |
| US-07.029 | Manager reopens completed work | Move Done to In Progress and refresh the record. | The existing task is reopened as In Progress, without creating a copy. |
| US-07.030 | Manager changes the assignee before an Employee transition | Reassign a To Do task from Employee A to Employee B. Try To Do to In Progress in A’s existing session, then in B’s. | A’s write is denied and B’s valid transition succeeds. |
| US-07.031 | Employee tries an assignee transition after losing agency access | Deactivate the membership while a To Do task remains assigned to that Employee, then attempt To Do to In Progress. | The inactive Employee cannot update the task. |
| US-07.032 | Northline Manager attempts a valid-looking transition on a Brightside task | Run the To Do to In Progress operation using the Northline session on the Brightside fixture. | The tenant boundary denies the write and the Brightside task stays To Do. |
| US-07.033 | Client refreshes a shared task after a permitted status change | As Manager, move a Client-visible task on an assigned project from To Do to In Progress. As Client, refresh. | The updated status is visible. The operation has not changed task visibility. |

### Priority values

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-07.034 | Manager creates a task with Low priority | Submit an otherwise valid task with Low priority and reopen it. | Low persists on the new task. |
| US-07.035 | Manager creates a task with Medium priority | Submit an otherwise valid task with Medium priority and reopen it. | Medium persists on the new task. |
| US-07.036 | Manager creates a task with High priority | Submit an otherwise valid task with High priority and reopen it. | High persists on the new task. |
| US-07.037 | Manager creates a task with Urgent priority | Submit an otherwise valid task with Urgent priority and reopen it. | Urgent persists on the new task. |

### Complete transition matrix for Manager and assigned Employee

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-07.038 | Project Manager requests To Do to In Progress | Start with a task in To Do and request In Progress as Project Manager. Re-read the task. | The same task has exactly one status, In Progress. |
| US-07.039 | Project Manager requests To Do to In Review | Start with a task in To Do and request In Review as Project Manager. Re-read the task. | The transition is refused and the task remains To Do. |
| US-07.040 | Project Manager requests To Do to Done | Start with a task in To Do and request Done as Project Manager. Re-read the task. | The transition is refused and the task remains To Do. |
| US-07.041 | Project Manager requests To Do to Blocked | Start with a task in To Do and request Blocked as Project Manager. Re-read the task. | The same task has exactly one status, Blocked. |
| US-07.042 | Project Manager requests In Progress to To Do | Start with a task in In Progress and request To Do as Project Manager. Re-read the task. | The same task has exactly one status, To Do. |
| US-07.043 | Project Manager requests In Progress to In Review | Start with a task in In Progress and request In Review as Project Manager. Re-read the task. | The same task has exactly one status, In Review. |
| US-07.044 | Project Manager requests In Progress to Done | Start with a task in In Progress and request Done as Project Manager. Re-read the task. | The transition is refused and the task remains In Progress. |
| US-07.045 | Project Manager requests In Progress to Blocked | Start with a task in In Progress and request Blocked as Project Manager. Re-read the task. | The same task has exactly one status, Blocked. |
| US-07.046 | Project Manager requests In Review to To Do | Start with a task in In Review and request To Do as Project Manager. Re-read the task. | The transition is refused and the task remains In Review. |
| US-07.047 | Project Manager requests In Review to In Progress | Start with a task in In Review and request In Progress as Project Manager. Re-read the task. | The same task has exactly one status, In Progress. |
| US-07.048 | Project Manager requests In Review to Done | Start with a task in In Review and request Done as Project Manager. Re-read the task. | The same task has exactly one status, Done. |
| US-07.049 | Project Manager requests In Review to Blocked | Start with a task in In Review and request Blocked as Project Manager. Re-read the task. | The transition is refused and the task remains In Review. |
| US-07.050 | Project Manager requests Done to To Do | Start with a task in Done and request To Do as Project Manager. Re-read the task. | The transition is refused and the task remains Done. |
| US-07.051 | Project Manager requests Done to In Progress | Start with a task in Done and request In Progress as Project Manager. Re-read the task. | The same task has exactly one status, In Progress. |
| US-07.052 | Project Manager requests Done to In Review | Start with a task in Done and request In Review as Project Manager. Re-read the task. | The transition is refused and the task remains Done. |
| US-07.053 | Project Manager requests Done to Blocked | Start with a task in Done and request Blocked as Project Manager. Re-read the task. | The transition is refused and the task remains Done. |
| US-07.054 | Project Manager requests Blocked to To Do | Start with a task in Blocked and request To Do as Project Manager. Re-read the task. | The same task has exactly one status, To Do. |
| US-07.055 | Project Manager requests Blocked to In Progress | Start with a task in Blocked and request In Progress as Project Manager. Re-read the task. | The same task has exactly one status, In Progress. |
| US-07.056 | Project Manager requests Blocked to In Review | Start with a task in Blocked and request In Review as Project Manager. Re-read the task. | The transition is refused and the task remains Blocked. |
| US-07.057 | Project Manager requests Blocked to Done | Start with a task in Blocked and request Done as Project Manager. Re-read the task. | The transition is refused and the task remains Blocked. |
| US-07.058 | Assigned Employee requests To Do to In Progress | Start with a task in To Do and request In Progress as Assigned Employee. Re-read the task. | The same task has exactly one status, In Progress. |
| US-07.059 | Assigned Employee requests To Do to In Review | Start with a task in To Do and request In Review as Assigned Employee. Re-read the task. | The transition is refused and the task remains To Do. |
| US-07.060 | Assigned Employee requests To Do to Done | Start with a task in To Do and request Done as Assigned Employee. Re-read the task. | The transition is refused and the task remains To Do. |
| US-07.061 | Assigned Employee requests To Do to Blocked | Start with a task in To Do and request Blocked as Assigned Employee. Re-read the task. | The same task has exactly one status, Blocked. |
| US-07.062 | Assigned Employee requests In Progress to To Do | Start with a task in In Progress and request To Do as Assigned Employee. Re-read the task. | The same task has exactly one status, To Do. |
| US-07.063 | Assigned Employee requests In Progress to In Review | Start with a task in In Progress and request In Review as Assigned Employee. Re-read the task. | The same task has exactly one status, In Review. |
| US-07.064 | Assigned Employee requests In Progress to Done | Start with a task in In Progress and request Done as Assigned Employee. Re-read the task. | The transition is refused and the task remains In Progress. |
| US-07.065 | Assigned Employee requests In Progress to Blocked | Start with a task in In Progress and request Blocked as Assigned Employee. Re-read the task. | The same task has exactly one status, Blocked. |
| US-07.066 | Assigned Employee requests In Review to To Do | Start with a task in In Review and request To Do as Assigned Employee. Re-read the task. | The transition is refused and the task remains In Review. |
| US-07.067 | Assigned Employee requests In Review to In Progress | Start with a task in In Review and request In Progress as Assigned Employee. Re-read the task. | The transition is refused and the task remains In Review. |
| US-07.068 | Assigned Employee requests In Review to Done | Start with a task in In Review and request Done as Assigned Employee. Re-read the task. | The transition is refused and the task remains In Review. |
| US-07.069 | Assigned Employee requests In Review to Blocked | Start with a task in In Review and request Blocked as Assigned Employee. Re-read the task. | The transition is refused and the task remains In Review. |
| US-07.070 | Assigned Employee requests Done to To Do | Start with a task in Done and request To Do as Assigned Employee. Re-read the task. | The transition is refused and the task remains Done. |
| US-07.071 | Assigned Employee requests Done to In Progress | Start with a task in Done and request In Progress as Assigned Employee. Re-read the task. | The transition is refused and the task remains Done. |
| US-07.072 | Assigned Employee requests Done to In Review | Start with a task in Done and request In Review as Assigned Employee. Re-read the task. | The transition is refused and the task remains Done. |
| US-07.073 | Assigned Employee requests Done to Blocked | Start with a task in Done and request Blocked as Assigned Employee. Re-read the task. | The transition is refused and the task remains Done. |
| US-07.074 | Assigned Employee requests Blocked to To Do | Start with a task in Blocked and request To Do as Assigned Employee. Re-read the task. | The same task has exactly one status, To Do. |
| US-07.075 | Assigned Employee requests Blocked to In Progress | Start with a task in Blocked and request In Progress as Assigned Employee. Re-read the task. | The same task has exactly one status, In Progress. |
| US-07.076 | Assigned Employee requests Blocked to In Review | Start with a task in Blocked and request In Review as Assigned Employee. Re-read the task. | The transition is refused and the task remains Blocked. |
| US-07.077 | Assigned Employee requests Blocked to Done | Start with a task in Blocked and request Done as Assigned Employee. Re-read the task. | The transition is refused and the task remains Blocked. |

### Permission checks for otherwise valid transitions

| Case | Scenario | Steps | Expected result |
| --- | --- | --- | --- |
| US-07.078 | Unassigned Employee attempts To Do to In Progress | Start with a task in To Do and request In Progress with the indicated session. | The transition is denied and the task remains To Do. |
| US-07.079 | Unassigned Employee attempts To Do to Blocked | Start with a task in To Do and request Blocked with the indicated session. | The transition is denied and the task remains To Do. |
| US-07.080 | Unassigned Employee attempts In Progress to In Review | Start with a task in In Progress and request In Review with the indicated session. | The transition is denied and the task remains In Progress. |
| US-07.081 | Unassigned Employee attempts In Progress to Blocked | Start with a task in In Progress and request Blocked with the indicated session. | The transition is denied and the task remains In Progress. |
| US-07.082 | Unassigned Employee attempts In Progress to To Do | Start with a task in In Progress and request To Do with the indicated session. | The transition is denied and the task remains In Progress. |
| US-07.083 | Unassigned Employee attempts In Review to Done | Start with a task in In Review and request Done with the indicated session. | The transition is denied and the task remains In Review. |
| US-07.084 | Unassigned Employee attempts In Review to In Progress | Start with a task in In Review and request In Progress with the indicated session. | The transition is denied and the task remains In Review. |
| US-07.085 | Unassigned Employee attempts Done to In Progress | Start with a task in Done and request In Progress with the indicated session. | The transition is denied and the task remains Done. |
| US-07.086 | Unassigned Employee attempts Blocked to To Do | Start with a task in Blocked and request To Do with the indicated session. | The transition is denied and the task remains Blocked. |
| US-07.087 | Unassigned Employee attempts Blocked to In Progress | Start with a task in Blocked and request In Progress with the indicated session. | The transition is denied and the task remains Blocked. |
| US-07.088 | Client with access to the shared task attempts To Do to In Progress | Start with a task in To Do and request In Progress with the indicated session. | The transition is denied and the task remains To Do. |
| US-07.089 | Client with access to the shared task attempts To Do to Blocked | Start with a task in To Do and request Blocked with the indicated session. | The transition is denied and the task remains To Do. |
| US-07.090 | Client with access to the shared task attempts In Progress to In Review | Start with a task in In Progress and request In Review with the indicated session. | The transition is denied and the task remains In Progress. |
| US-07.091 | Client with access to the shared task attempts In Progress to Blocked | Start with a task in In Progress and request Blocked with the indicated session. | The transition is denied and the task remains In Progress. |
| US-07.092 | Client with access to the shared task attempts In Progress to To Do | Start with a task in In Progress and request To Do with the indicated session. | The transition is denied and the task remains In Progress. |
| US-07.093 | Client with access to the shared task attempts In Review to Done | Start with a task in In Review and request Done with the indicated session. | The transition is denied and the task remains In Review. |
| US-07.094 | Client with access to the shared task attempts In Review to In Progress | Start with a task in In Review and request In Progress with the indicated session. | The transition is denied and the task remains In Review. |
| US-07.095 | Client with access to the shared task attempts Done to In Progress | Start with a task in Done and request In Progress with the indicated session. | The transition is denied and the task remains Done. |
| US-07.096 | Client with access to the shared task attempts Blocked to To Do | Start with a task in Blocked and request To Do with the indicated session. | The transition is denied and the task remains Blocked. |
| US-07.097 | Client with access to the shared task attempts Blocked to In Progress | Start with a task in Blocked and request In Progress with the indicated session. | The transition is denied and the task remains Blocked. |
