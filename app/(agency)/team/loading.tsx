/**
 * Loading state for /team.
 *
 * Next.js renders this automatically while the page's data is being
 * fetched. Every list page should have one, and the skeleton should
 * match the shape of the real content so the layout doesn't jump.
 */
export default function Loading() {
  return (
    <div className="space-y-8">
      <div className="space-y-2">
        <div className="h-8 w-32 animate-pulse rounded-md bg-muted" />
        <div className="h-4 w-64 animate-pulse rounded-md bg-muted" />
      </div>

      <div className="space-y-3">
        <div className="h-4 w-20 animate-pulse rounded-md bg-muted" />
        <div className="rounded-lg border border-border">
          <div className="h-11 border-b border-border bg-muted/40" />
          {[0, 1, 2, 3].map((i) => (
            <div
              key={i}
              className="flex items-center gap-3 border-b border-border p-4 last:border-b-0"
            >
              <div className="size-7 animate-pulse rounded-full bg-muted" />
              <div className="h-4 w-40 animate-pulse rounded-md bg-muted" />
              <div className="ml-auto h-4 w-20 animate-pulse rounded-md bg-muted" />
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
