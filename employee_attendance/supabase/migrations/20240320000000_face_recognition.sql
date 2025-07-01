-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create profiles table
create table if not exists public.profiles (
    id uuid references auth.users on delete cascade primary key,
    photo_url text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create attendance_records table
create table if not exists public.attendance_records (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references auth.users on delete cascade,
    photo_url text,
    timestamp timestamp with time zone default timezone('utc'::text, now()) not null,
    status text,
    confidence float
);

-- Create storage buckets
insert into storage.buckets (id, name, public)
values ('profile_photos', 'profile_photos', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('attendance_photos', 'attendance_photos', true)
on conflict (id) do nothing;

-- Set up RLS (Row Level Security)
alter table public.profiles enable row level security;
alter table public.attendance_records enable row level security;

-- Create policies
create policy "Users can view their own profile"
    on public.profiles for select
    using (auth.uid() = id);

create policy "Users can update their own profile"
    on public.profiles for update
    using (auth.uid() = id);

create policy "Users can view their own attendance records"
    on public.attendance_records for select
    using (auth.uid() = user_id);

create policy "Users can insert their own attendance records"
    on public.attendance_records for insert
    with check (auth.uid() = user_id);

-- Create function to handle new user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id)
    values (new.id);
    return new;
end;
$$ language plpgsql security definer;

-- Create trigger for new user signup
create or replace trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user(); 