-- ENMX Security Cam: tabla independiente para reparaciones/cambios de cámaras.
-- Ejecuta este archivo en Supabase > SQL Editor. No borra ni modifica cotizaciones existentes.
create table if not exists public.repair_quotes (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  customer_name text not null,
  phone text,
  location text,
  work_description text not null,
  materials_cost_dop numeric(12,2) not null default 0 check (materials_cost_dop >= 0),
  total_charge_dop numeric(12,2) not null check (total_charge_dop >= 0),
  profit_dop numeric(12,2) not null default 0,
  status text not null default 'Pendiente'
    check (status in ('Pendiente','En proceso','Completada')),
  notes text
);

alter table public.repair_quotes enable row level security;

drop policy if exists "Admin puede leer reparaciones ENMX" on public.repair_quotes;
create policy "Admin puede leer reparaciones ENMX"
on public.repair_quotes for select to authenticated
using (auth.uid() = 'bf585a90-413c-4330-9aef-12a702fd148d'::uuid);

drop policy if exists "Admin puede crear reparaciones ENMX" on public.repair_quotes;
create policy "Admin puede crear reparaciones ENMX"
on public.repair_quotes for insert to authenticated
with check (auth.uid() = 'bf585a90-413c-4330-9aef-12a702fd148d'::uuid);

drop policy if exists "Admin puede actualizar reparaciones ENMX" on public.repair_quotes;
create policy "Admin puede actualizar reparaciones ENMX"
on public.repair_quotes for update to authenticated
using (auth.uid() = 'bf585a90-413c-4330-9aef-12a702fd148d'::uuid)
with check (auth.uid() = 'bf585a90-413c-4330-9aef-12a702fd148d'::uuid);

grant select, insert, update on public.repair_quotes to authenticated;
