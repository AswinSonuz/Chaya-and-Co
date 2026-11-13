create table if not exists public.votes (
  voter_id uuid primary key references auth.users (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 40),
  place_id text not null check (place_id in ('park-chai', 'sunset-cutting', 'street-snacks')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.votes enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update on public.votes to authenticated;

drop policy if exists "Authenticated users can read votes" on public.votes;
create policy "Authenticated users can read votes"
  on public.votes for select to authenticated
  using (true);

drop policy if exists "Users can add their own vote" on public.votes;
create policy "Users can add their own vote"
  on public.votes for insert to authenticated
  with check ((select auth.uid()) = voter_id);

drop policy if exists "Users can update their own vote" on public.votes;
create policy "Users can update their own vote"
  on public.votes for update to authenticated
  using ((select auth.uid()) = voter_id)
  with check ((select auth.uid()) = voter_id);

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'votes'
  ) then
    alter publication supabase_realtime add table public.votes;
  end if;
end
$$;
