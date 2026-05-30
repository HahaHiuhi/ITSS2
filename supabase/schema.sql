-- Supabase Database Schema for Student Academic Planner MVP

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. SUBJECTS TABLE
create table public.subjects (
    id uuid default gen_random_uuid() primary key,
    name text not null,
    color text not null default '#3525CD', -- Hex color code
    user_id uuid default auth.uid(), -- Multi-user support linked to Supabase Auth
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for Subjects
alter table public.subjects enable row level security;

-- Policies for Subjects
create policy "Allow all actions for owners on subjects" 
on public.subjects 
for all 
using (auth.uid() = user_id) 
with check (auth.uid() = user_id);


-- 2. TASKS / DEADLINES TABLE
create table public.tasks (
    id uuid default gen_random_uuid() primary key,
    title text not null,
    description text,
    deadline timestamp with time zone,
    priority text default 'MEDIUM' check (priority in ('LOW', 'MEDIUM', 'HIGH')),
    is_completed boolean default false not null,
    subject_id uuid references public.subjects(id) on delete set null,
    user_id uuid default auth.uid(),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for Tasks
alter table public.tasks enable row level security;

-- Policies for Tasks
create policy "Allow all actions for owners on tasks" 
on public.tasks 
for all 
using (auth.uid() = user_id) 
with check (auth.uid() = user_id);

-- Index for querying active/upcoming deadlines quickly
create index tasks_deadline_idx on public.tasks(deadline) where is_completed = false;


-- 3. SCHEDULES (CLASS TIMETABLES) TABLE
create table public.schedules (
    id uuid default gen_random_uuid() primary key,
    title text not null,
    start_time timestamp with time zone not null,
    end_time timestamp with time zone not null,
    day_of_week integer check (day_of_week between 1 and 7), -- 1 = Monday, 7 = Sunday
    location text,
    subject_id uuid references public.subjects(id) on delete set null,
    user_id uuid default auth.uid(),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for Schedules
alter table public.schedules enable row level security;

-- Policies for Schedules
create policy "Allow all actions for owners on schedules" 
on public.schedules 
for all 
using (auth.uid() = user_id) 
with check (auth.uid() = user_id);

-- Create a helper function to retrieve all academic dashboard items in a single request
create or replace function public.get_dashboard_summary(p_user_id uuid)
returns json as $$
declare
    v_total_tasks int;
    v_completed_tasks int;
    v_upcoming_deadlines json;
    v_today_schedules json;
begin
    -- Count tasks
    select count(*) into v_total_tasks from public.tasks where user_id = p_user_id;
    select count(*) into v_completed_tasks from public.tasks where user_id = p_user_id and is_completed = true;

    -- Get top 3 upcoming deadlines
    select coalesce(json_agg(t), '[]'::json) into v_upcoming_deadlines
    from (
        select t.id, t.title, t.deadline, t.priority, s.name as subject_name, s.color as subject_color
        from public.tasks t
        left join public.subjects s on t.subject_id = s.id
        where t.user_id = p_user_id and t.is_completed = false
        order by t.deadline asc nulls last
        limit 3
    ) t;

    -- Get today's schedules
    select coalesce(json_agg(sch), '[]'::json) into v_today_schedules
    from (
        select sch.id, sch.title, sch.start_time, sch.end_time, sch.location, s.name as subject_name, s.color as subject_color
        from public.schedules sch
        left join public.subjects s on sch.subject_id = s.id
        where sch.user_id = p_user_id and sch.day_of_week = extract(isodow from current_date)
        order by sch.start_time asc
    ) sch;

    return json_build_object(
        'total_tasks', v_total_tasks,
        'completed_tasks', v_completed_tasks,
        'upcoming_deadlines', v_upcoming_deadlines,
        'today_schedules', v_today_schedules
    );
end;
$$ language plpgsql security definer;
