create extension if not exists pgcrypto;

create table if not exists public.finance_profiles (
  auth_user_id uuid primary key,
  email text unique not null,
  role text not null check (role in ('admin','supervisor','operator','viewer')),
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
  brand text not null check (brand in ('wiseedge','revovision')),
  payload jsonb not null,
  created_by text,
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_finance_transactions_brand on public.finance_transactions (brand);
create index if not exists idx_finance_transactions_updated_at on public.finance_transactions (updated_at desc);

create table if not exists public.finance_budgets (
  id text primary key,
  brand text not null check (brand in ('wiseedge','revovision')),
  payload jsonb not null,
  created_by text,
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_finance_budgets_brand on public.finance_budgets (brand);
create index if not exists idx_finance_budgets_updated_at on public.finance_budgets (updated_at desc);

create table if not exists public.finance_app_configs (
  brand text primary key check (brand in ('wiseedge','revovision')),
  payload jsonb not null default '{}'::jsonb,
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.finance_profiles enable row level security;
alter table public.finance_transactions enable row level security;
alter table public.finance_budgets enable row level security;
alter table public.finance_app_configs enable row level security;

create or replace function public.current_finance_role()
returns text
language sql
stable
as $$
  select coalesce(
    (auth.jwt() -> 'user_metadata' ->> 'role'),
    (select fp.role from public.finance_profiles fp
      where fp.auth_user_id = auth.uid()
         or lower(fp.email) = lower(auth.jwt() ->> 'email')
      limit 1),
    'viewer'
  );
$$;

create or replace function public.current_finance_brands()
returns text[]
language sql
stable
as $$
  select coalesce(
    array(
      select jsonb_array_elements_text(coalesce(auth.jwt() -> 'user_metadata' -> 'allowedBrands', '[]'::jsonb))
    ),
    (select fp.allowed_brands from public.finance_profiles fp
      where fp.auth_user_id = auth.uid()
         or lower(fp.email) = lower(auth.jwt() ->> 'email')
      limit 1),
    array['wiseedge','revovision']
  );
$$;

drop policy if exists finance_profiles_select_self on public.finance_profiles;
create policy finance_profiles_select_self
on public.finance_profiles
for select
to authenticated
using (
  auth.uid() = auth_user_id
  or lower(email) = lower(auth.jwt() ->> 'email')
  or public.current_finance_role() in ('admin','supervisor')
);

drop policy if exists finance_transactions_select on public.finance_transactions;
create policy finance_transactions_select
on public.finance_transactions
for select
to authenticated
using (brand = any(public.current_finance_brands()));

drop policy if exists finance_transactions_modify on public.finance_transactions;
create policy finance_transactions_modify
on public.finance_transactions
for all
to authenticated
using (
  public.current_finance_role() in ('admin','supervisor','operator')
  and brand = any(public.current_finance_brands())
)
with check (
  public.current_finance_role() in ('admin','supervisor','operator')
  and brand = any(public.current_finance_brands())
);

drop policy if exists finance_budgets_select on public.finance_budgets;
create policy finance_budgets_select
on public.finance_budgets
for select
to authenticated
using (brand = any(public.current_finance_brands()));

drop policy if exists finance_budgets_modify on public.finance_budgets;
create policy finance_budgets_modify
on public.finance_budgets
for all
to authenticated
using (
  public.current_finance_role() in ('admin','supervisor')
  and brand = any(public.current_finance_brands())
)
with check (
  public.current_finance_role() in ('admin','supervisor')
  and brand = any(public.current_finance_brands())
);

drop policy if exists finance_app_configs_select on public.finance_app_configs;
create policy finance_app_configs_select
on public.finance_app_configs
for select
to authenticated
using (brand = any(public.current_finance_brands()));

drop policy if exists finance_app_configs_modify on public.finance_app_configs;
create policy finance_app_configs_modify
on public.finance_app_configs
for all
to authenticated
using (
  public.current_finance_role() in ('admin','supervisor')
  and brand = any(public.current_finance_brands())
)
with check (
  public.current_finance_role() in ('admin','supervisor')
  and brand = any(public.current_finance_brands())
);

insert into public.finance_app_configs (brand, payload)
values
  ('wiseedge', '{}'::jsonb),
  ('revovision', '{}'::jsonb)
on conflict (brand) do nothing;