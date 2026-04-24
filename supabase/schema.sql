-- Finance Dashboard Supabase schema
-- Run this once in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.finance_profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique references auth.users(id) on delete cascade,
  email text unique,
  role text not null default 'viewer' check (role in ('admin','supervisor','operator','viewer')),
  display_name text,
  department text,
  title text,
  signature text,
  allowed_brands text[] not null default array['wiseedge','revovision'],
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.finance_transactions (
  id text primary key,
  brand text not null,
  payload jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.finance_budgets (
  id text primary key,
  brand text not null,
  payload jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.finance_app_configs (
  brand text primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_finance_profiles_updated_at on public.finance_profiles;
create trigger trg_finance_profiles_updated_at
before update on public.finance_profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_finance_transactions_updated_at on public.finance_transactions;
create trigger trg_finance_transactions_updated_at
before update on public.finance_transactions
for each row execute function public.set_updated_at();

drop trigger if exists trg_finance_budgets_updated_at on public.finance_budgets;
create trigger trg_finance_budgets_updated_at
before update on public.finance_budgets
for each row execute function public.set_updated_at();

drop trigger if exists trg_finance_app_configs_updated_at on public.finance_app_configs;
create trigger trg_finance_app_configs_updated_at
before update on public.finance_app_configs
for each row execute function public.set_updated_at();

alter table public.finance_profiles enable row level security;
alter table public.finance_transactions enable row level security;
alter table public.finance_budgets enable row level security;
alter table public.finance_app_configs enable row level security;

-- Starter policies for internal app usage. Tighten later if needed.
drop policy if exists "finance_profiles_select_authenticated" on public.finance_profiles;
create policy "finance_profiles_select_authenticated"
on public.finance_profiles for select
to authenticated
using (true);

drop policy if exists "finance_profiles_insert_own" on public.finance_profiles;
create policy "finance_profiles_insert_own"
on public.finance_profiles for insert
to authenticated
with check (auth_user_id = auth.uid() or auth_user_id is null);

drop policy if exists "finance_profiles_update_own" on public.finance_profiles;
create policy "finance_profiles_update_own"
on public.finance_profiles for update
to authenticated
using (auth_user_id = auth.uid())
with check (auth_user_id = auth.uid());

drop policy if exists "finance_transactions_all_authenticated" on public.finance_transactions;
create policy "finance_transactions_all_authenticated"
on public.finance_transactions for all
to authenticated
using (true)
with check (true);

drop policy if exists "finance_budgets_all_authenticated" on public.finance_budgets;
create policy "finance_budgets_all_authenticated"
on public.finance_budgets for all
to authenticated
using (true)
with check (true);

drop policy if exists "finance_app_configs_all_authenticated" on public.finance_app_configs;
create policy "finance_app_configs_all_authenticated"
on public.finance_app_configs for all
to authenticated
using (true)
with check (true);

-- After creating a Supabase Auth user, insert/update its app profile.
-- Replace the UUID and email before running.
-- insert into public.finance_profiles (auth_user_id, email, role, display_name, allowed_brands)
-- values ('YOUR_AUTH_USER_ID', 'myself520@gmail.com', 'admin', 'Mickey', array['wiseedge','revovision'])
-- on conflict (email) do update set
--   auth_user_id = excluded.auth_user_id,
--   role = excluded.role,
--   display_name = excluded.display_name,
--   allowed_brands = excluded.allowed_brands;
