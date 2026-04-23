create extension if not exists pgcrypto;

alter table public.animals
  add column if not exists favorite_count integer not null default 0,
  add column if not exists graduated_at timestamptz,
  add column if not exists graduation_reason text,
  add column if not exists published_at timestamptz,
  add column if not exists updated_at timestamptz not null default now();

update public.animals
set published_at = coalesce(animal_createtime, animal_update, last_seen_at)
where published_at is null;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists animals_set_updated_at on public.animals;
create trigger animals_set_updated_at
before update on public.animals
for each row
execute function public.set_updated_at();

create or replace function public.track_animal_graduation()
returns trigger
language plpgsql
as $$
begin
  if new.published_at is null then
    new.published_at := coalesce(new.animal_createtime, new.animal_update, new.last_seen_at, now());
  end if;

  if old.is_active is distinct from new.is_active then
    if new.is_active = false then
      new.graduated_at := coalesce(new.graduated_at, now());
      new.graduation_reason := coalesce(new.graduation_reason, 'missing_from_open_data');
    else
      new.graduated_at := null;
      new.graduation_reason := null;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists animals_track_graduation on public.animals;
create trigger animals_track_graduation
before update on public.animals
for each row
execute function public.track_animal_graduation();

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  city text default '新北市',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

create or replace function public.handle_new_user_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user_profile();

create table if not exists public.favorites (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  animal_id bigint not null references public.animals(animal_id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, animal_id)
);

create index if not exists favorites_user_id_idx on public.favorites (user_id);
create index if not exists favorites_animal_id_idx on public.favorites (animal_id);

create or replace function public.sync_animal_favorite_count()
returns trigger
language plpgsql
as $$
declare
  target_animal_id bigint;
begin
  target_animal_id := coalesce(new.animal_id, old.animal_id);

  update public.animals
  set favorite_count = (
    select count(*)
    from public.favorites
    where animal_id = target_animal_id
  )
  where animal_id = target_animal_id;

  return coalesce(new, old);
end;
$$;

drop trigger if exists favorites_sync_count_after_insert on public.favorites;
create trigger favorites_sync_count_after_insert
after insert on public.favorites
for each row
execute function public.sync_animal_favorite_count();

drop trigger if exists favorites_sync_count_after_delete on public.favorites;
create trigger favorites_sync_count_after_delete
after delete on public.favorites
for each row
execute function public.sync_animal_favorite_count();

drop trigger if exists favorites_sync_count_after_update on public.favorites;
create trigger favorites_sync_count_after_update
after update of animal_id on public.favorites
for each row
execute function public.sync_animal_favorite_count();

create index if not exists animals_active_status_idx
  on public.animals (is_active, animal_status);

create index if not exists animals_city_idx
  on public.animals (city);

create index if not exists animals_createtime_desc_idx
  on public.animals (animal_createtime desc nulls last);

create index if not exists animals_opendate_idx
  on public.animals (animal_opendate asc nulls last);

create index if not exists animals_favorite_count_idx
  on public.animals (favorite_count desc);

create index if not exists animals_graduated_at_idx
  on public.animals (graduated_at desc nulls last);

create or replace view public.v_animals_card_base as
select
  a.animal_id,
  a.animal_subid,
  a.animal_kind,
  a.animal_variety,
  a.animal_sex,
  a.animal_bodytype,
  a.animal_colour,
  a.animal_age,
  a.animal_title,
  a.animal_status,
  a.animal_place,
  a.shelter_name,
  a.shelter_address,
  a.shelter_tel,
  a.album_file,
  a.city,
  a.favorite_count,
  a.is_active,
  a.published_at,
  a.animal_createtime,
  a.animal_opendate,
  a.animal_update,
  a.graduated_at,
  a.graduation_reason,
  coalesce(nullif(a.album_file, ''), null) is not null as has_image,
  a.animal_status = 'OPEN' and a.is_active = true as is_open_for_adoption,
  case
    when a.animal_opendate is not null then (current_date - a.animal_opendate)
    else null
  end as waiting_days
from public.animals a;

create or replace view public.v_animals_app as
select
  a.*,
  case
    when a.animal_sex = 'M' then '公'
    when a.animal_sex = 'F' then '母'
    else '未標示'
  end as sex_text,
  case
    when a.animal_age = 'CHILD' then '幼年'
    when a.animal_age = 'ADULT' then '成年'
    else coalesce(a.animal_age, '未知')
  end as age_text,
  case
    when a.animal_bodytype = 'SMALL' then '小型'
    when a.animal_bodytype = 'MEDIUM' then '中型'
    when a.animal_bodytype = 'BIG' then '大型'
    else coalesce(a.animal_bodytype, '未知')
  end as body_type_text,
  case
    when a.animal_status = 'NONE' then '未公告'
    when a.animal_status = 'OPEN' then '開放認養'
    when a.animal_status = 'ADOPTED' then '已認養'
    when a.animal_status = 'OTHER' then '其他'
    when a.animal_status = 'DEAD' then '死亡'
    else coalesce(a.animal_status, '未知')
  end as status_text,
  case
    when coalesce(a.animal_title, '') <> '' then a.animal_title
    when coalesce(a.animal_variety, '') <> '' then a.animal_variety
    else '等待認養的毛孩'
  end as display_name,
  case
    when coalesce(a.animal_colour, '') <> '' and coalesce(a.animal_variety, '') <> '' then a.animal_colour || a.animal_variety
    when coalesce(a.animal_colour, '') <> '' then a.animal_colour
    when coalesce(a.animal_variety, '') <> '' then a.animal_variety
    when coalesce(a.animal_title, '') <> '' then a.animal_title
    else '等待認養的毛孩'
  end as headline_title,
  case
    when a.animal_kind = '狗' then '狗狗'
    when a.animal_kind = '貓' then '貓咪'
    else '其他'
  end as category_label,
  case
    when a.animal_kind = '狗' then 'dog'
    when a.animal_kind = '貓' then 'cat'
    else 'other'
  end as filter_category,
  coalesce(nullif(a.shelter_name, ''), nullif(a.animal_place, ''), nullif(a.shelter_address, ''), '收容資訊待更新') as primary_location,
  case
    when coalesce(a.animal_foundplace, '') <> '' then '發現地：' || a.animal_foundplace
    when coalesce(a.animal_place, '') <> '' then '收容地：' || a.animal_place
    else '來源地待更新'
  end as source_location_text,
  coalesce(nullif(a.animal_remark, ''), nullif(a.animal_caption, '')) as note_preview,
  coalesce(nullif(a.album_file, ''), null) is not null as has_image,
  a.animal_status = 'OPEN' and a.is_active = true as is_open_for_adoption,
  case
    when a.animal_createtime is not null then ((now() at time zone 'utc')::date - a.animal_createtime::date)
    else null
  end as days_since_create,
  case
    when a.animal_opendate is not null then ((now() at time zone 'utc')::date - a.animal_opendate::date)
    else null
  end as days_since_open,
  case
    when coalesce(a.animal_update, a.c_date, a.album_update) is not null
      then ((now() at time zone 'utc')::date - coalesce(a.animal_update, a.c_date, a.album_update)::date)
    else null
  end as days_since_update,
  coalesce(a.animal_update, a.c_date, a.album_update) as last_update_at,
  case
    when a.animal_createtime is not null then to_char(a.animal_createtime::date, 'YYYY/MM/DD')
    else '--'
  end as create_date_label,
  case
    when a.animal_opendate is not null then to_char(a.animal_opendate::date, 'YYYY/MM/DD')
    else '--'
  end as open_date_label,
  case
    when coalesce(a.animal_update, a.c_date, a.album_update) is not null
      then to_char(coalesce(a.animal_update, a.c_date, a.album_update)::date, 'YYYY/MM/DD')
    else '--'
  end as update_date_label,
  case
    when a.animal_createtime is not null then '來園 ' || (((now() at time zone 'utc')::date - a.animal_createtime::date))::text || ' 天'
    else '來園 0 天'
  end as stay_duration_label,
  case
    when a.animal_opendate is not null then '開放認養 ' || (((now() at time zone 'utc')::date - a.animal_opendate::date))::text || ' 天'
    else '開放認養 0 天'
  end as adoption_duration_label,
  case
    when coalesce(a.animal_update, a.c_date, a.album_update) is not null
      then (((now() at time zone 'utc')::date - coalesce(a.animal_update, a.c_date, a.album_update)::date))::text || ' 天前更新'
    else '0 天前更新'
  end as update_duration_label,
  case
    when a.animal_createtime is not null then ((now() at time zone 'utc')::date - a.animal_createtime::date) <= 7
    else false
  end as is_recent_arrival
from public.animals a;

create or replace view public.v_home_daily_fate as
select *
from public.v_animals_card_base
where is_open_for_adoption = true
order by random();

create or replace view public.v_home_nearby_animals as
select *
from public.v_animals_card_base
where is_open_for_adoption = true
  and city = '新北市'
order by animal_update desc nulls last, animal_id desc;

create or replace view public.v_home_new_open as
select *
from public.v_animals_card_base
where is_open_for_adoption = true
order by coalesce(animal_opendate, published_at, animal_update) desc nulls last, animal_id desc;

create or replace view public.v_home_waiting_long as
select *
from public.v_animals_card_base
where is_open_for_adoption = true
  and animal_opendate is not null
  and current_date - animal_opendate >= 365
order by animal_opendate asc, animal_id desc;

create or replace view public.v_home_most_favorited as
select *
from public.v_animals_card_base
where is_open_for_adoption = true
order by favorite_count desc, animal_update desc nulls last, animal_id desc;

create or replace view public.v_home_recent_graduated as
select *
from public.v_animals_card_base
where is_active = false
  and graduated_at is not null
order by graduated_at desc, animal_id desc;

create or replace function public.get_home_sections(
  p_city text default '新北市',
  p_limit integer default 12
)
returns jsonb
language sql
stable
as $$
  with params as (
    select greatest(coalesce(p_limit, 12), 1) as limit_count,
           coalesce(nullif(trim(p_city), ''), '新北市') as city_name
  ),
  daily_fate as (
    select jsonb_agg(to_jsonb(t)) as items
    from (
      select *
      from public.v_animals_card_base
      where is_open_for_adoption = true
      order by random()
      limit (select limit_count from params)
    ) t
  ),
  nearby as (
    select jsonb_agg(to_jsonb(t)) as items
    from (
      select *
      from public.v_animals_card_base
      where is_open_for_adoption = true
        and city = (select city_name from params)
      order by animal_update desc nulls last, animal_id desc
      limit (select limit_count from params)
    ) t
  ),
  new_open as (
    select jsonb_agg(to_jsonb(t)) as items
    from (
      select *
      from public.v_animals_card_base
      where is_open_for_adoption = true
      order by coalesce(animal_opendate, published_at, animal_update) desc nulls last, animal_id desc
      limit (select limit_count from params)
    ) t
  ),
  waiting_long as (
    select jsonb_agg(to_jsonb(t)) as items
    from (
      select *
      from public.v_animals_card_base
      where is_open_for_adoption = true
        and animal_opendate is not null
        and current_date - animal_opendate >= 365
      order by animal_opendate asc, animal_id desc
      limit (select limit_count from params)
    ) t
  ),
  most_favorited as (
    select jsonb_agg(to_jsonb(t)) as items
    from (
      select *
      from public.v_animals_card_base
      where is_open_for_adoption = true
      order by favorite_count desc, animal_update desc nulls last, animal_id desc
      limit (select limit_count from params)
    ) t
  ),
  recent_graduated as (
    select jsonb_agg(to_jsonb(t)) as items
    from (
      select *
      from public.v_animals_card_base
      where is_active = false
        and graduated_at is not null
      order by graduated_at desc, animal_id desc
      limit (select limit_count from params)
    ) t
  )
  select jsonb_build_object(
    'daily_fate', coalesce((select items from daily_fate), '[]'::jsonb),
    'nearby_animals', coalesce((select items from nearby), '[]'::jsonb),
    'new_open', coalesce((select items from new_open), '[]'::jsonb),
    'waiting_long', coalesce((select items from waiting_long), '[]'::jsonb),
    'most_favorited', coalesce((select items from most_favorited), '[]'::jsonb),
    'recent_graduated', coalesce((select items from recent_graduated), '[]'::jsonb)
  );
$$;

alter table public.animals enable row level security;
alter table public.profiles enable row level security;
alter table public.favorites enable row level security;

drop policy if exists "animals are publicly readable" on public.animals;
create policy "animals are publicly readable"
on public.animals
for select
to anon, authenticated
using (true);

drop policy if exists "profiles are publicly readable" on public.profiles;
create policy "profiles are publicly readable"
on public.profiles
for select
to anon, authenticated
using (true);

drop policy if exists "users can insert their own profile" on public.profiles;
create policy "users can insert their own profile"
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "users can update their own profile" on public.profiles;
create policy "users can update their own profile"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "users can read their own favorites" on public.favorites;
create policy "users can read their own favorites"
on public.favorites
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "users can insert their own favorites" on public.favorites;
create policy "users can insert their own favorites"
on public.favorites
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "users can delete their own favorites" on public.favorites;
create policy "users can delete their own favorites"
on public.favorites
for delete
to authenticated
using (auth.uid() = user_id);

grant usage on schema public to anon, authenticated;
grant select on public.v_animals_card_base to anon, authenticated;
grant select on public.v_animals_app to anon, authenticated;
grant select on public.v_home_daily_fate to anon, authenticated;
grant select on public.v_home_nearby_animals to anon, authenticated;
grant select on public.v_home_new_open to anon, authenticated;
grant select on public.v_home_waiting_long to anon, authenticated;
grant select on public.v_home_most_favorited to anon, authenticated;
grant select on public.v_home_recent_graduated to anon, authenticated;
grant execute on function public.get_home_sections(text, integer) to anon, authenticated;
