-- PORTFOLIO ARCHIVE / Supabase 初期設定
-- Supabase Dashboard > SQL Editor でこのファイル全体を実行してください。

create table if not exists public.portfolio_works (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null default '',
  tags text[] not null default '{}',
  note text not null default '',
  published boolean not null default true,
  image_url text not null,
  storage_path text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.portfolio_works enable row level security;

create or replace function public.is_portfolio_admin()
returns boolean
language sql
stable
as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'portfolio_admin')::boolean, false);
$$;

revoke all on function public.is_portfolio_admin() from public;
grant execute on function public.is_portfolio_admin() to anon, authenticated;

drop policy if exists "portfolio public can read published" on public.portfolio_works;
create policy "portfolio public can read published"
on public.portfolio_works for select
to public
using (published = true);

drop policy if exists "portfolio admin can read all" on public.portfolio_works;
create policy "portfolio admin can read all"
on public.portfolio_works for select
to authenticated
using (public.is_portfolio_admin());

drop policy if exists "portfolio admin can insert" on public.portfolio_works;
create policy "portfolio admin can insert"
on public.portfolio_works for insert
to authenticated
with check (public.is_portfolio_admin());

drop policy if exists "portfolio admin can update" on public.portfolio_works;
create policy "portfolio admin can update"
on public.portfolio_works for update
to authenticated
using (public.is_portfolio_admin())
with check (public.is_portfolio_admin());

drop policy if exists "portfolio admin can delete" on public.portfolio_works;
create policy "portfolio admin can delete"
on public.portfolio_works for delete
to authenticated
using (public.is_portfolio_admin());

insert into storage.buckets (id, name, public)
values ('portfolio', 'portfolio', true)
on conflict (id) do update set public = true;

drop policy if exists "portfolio admin storage insert" on storage.objects;
create policy "portfolio admin storage insert"
on storage.objects for insert
to authenticated
with check (bucket_id = 'portfolio' and public.is_portfolio_admin());

drop policy if exists "portfolio admin storage update" on storage.objects;
create policy "portfolio admin storage update"
on storage.objects for update
to authenticated
using (bucket_id = 'portfolio' and public.is_portfolio_admin())
with check (bucket_id = 'portfolio' and public.is_portfolio_admin());

drop policy if exists "portfolio admin storage delete" on storage.objects;
create policy "portfolio admin storage delete"
on storage.objects for delete
to authenticated
using (bucket_id = 'portfolio' and public.is_portfolio_admin());

-- 初期3作品。画像はGitHub Pagesの assets/ を参照します。
insert into public.portfolio_works (id,title,category,tags,note,published,image_url,storage_path,sort_order)
values
('00000000-0000-4000-8000-000000000001','Girly Recruitment Visual','かわいい',array['CUTE','PINK','RECRUITING'],'',true,'assets/work-01.jpg',null,0),
('00000000-0000-4000-8000-000000000002','Luxury Recruitment Visual','高級感',array['LUXURY','GOLD','RECRUITING'],'',true,'assets/work-02.jpg',null,1),
('00000000-0000-4000-8000-000000000003','Neon Recruitment Visual','ネオン',array['NEON','BLUE','RECRUITING'],'',true,'assets/work-03.jpg',null,2)
on conflict (id) do nothing;

-- Realtimeで別端末にも自動反映。
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname='supabase_realtime' and schemaname='public' and tablename='portfolio_works'
  ) then
    alter publication supabase_realtime add table public.portfolio_works;
  end if;
end $$;

-- ==============================
-- 管理者ユーザーを作成した後に実行
-- YOUR_ADMIN_EMAIL を実際のメールアドレスへ置き換えてください。
-- ==============================
-- update auth.users
-- set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"portfolio_admin": true}'::jsonb
-- where email = 'YOUR_ADMIN_EMAIL';
