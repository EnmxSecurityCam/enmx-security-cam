-- ENMX Security Cam: tabla para reparaciones, trabajos aparte y facturas.
-- Ejecuta este archivo en Supabase > SQL Editor > New query.
-- No borra ni modifica las cotizaciones existentes.

create extension if not exists pgcrypto;

create table if not exists public.repair_quotes (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  customer_name text not null,
  phone text,
  location text,
  work_description text not null,
  quantity integer not null default 1 check (quantity > 0),
  work_level text not null default 'normal',
  labor_charge_dop numeric(12,2) not null default 0,
  materials_cost_dop numeric(12,2) not null default 0,
  total_charge_dop numeric(12,2) not null default 0,
  paid_dop numeric(12,2) not null default 0,
  invoice_number text,
  profit_dop numeric(12,2) not null default 0,
  status text not null default 'Pendiente',
  notes text
);

alter table public.repair_quotes add column if not exists quantity integer not null default 1;
alter table public.repair_quotes add column if not exists work_level text not null default 'normal';
alter table public.repair_quotes add column if not exists labor_charge_dop numeric(12,2) not null default 0;
alter table public.repair_quotes add column if not exists paid_dop numeric(12,2) not null default 0;
alter table public.repair_quotes add column if not exists invoice_number text;

-- Mantiene compatibilidad con una tabla previa que ya tuviera estos registros.
update public.repair_quotes
set labor_charge_dop = greatest(coalesce(total_charge_dop,0) - coalesce(materials_cost_dop,0),0)
where coalesce(labor_charge_dop,0)=0 and coalesce(total_charge_dop,0)>coalesce(materials_cost_dop,0);

alter table public.repair_quotes enable row level security;

drop policy if exists "ENMX admin full access repair_quotes" on public.repair_quotes;
create policy "ENMX admin full access repair_quotes"
on public.repair_quotes
for all
to authenticated
using (auth.uid() = 'bf585a90-413c-4330-9aef-12a702fd148d'::uuid)
with check (auth.uid() = 'bf585a90-413c-4330-9aef-12a702fd148d'::uuid);

grant select, insert, update on public.repair_quotes to authenticated;
