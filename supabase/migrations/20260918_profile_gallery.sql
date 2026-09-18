-- Profile gallery support. Keep avatar_path for compatibility with existing feeds.
alter table public.profiles
  add column if not exists gallery_paths jsonb not null default '[]'::jsonb;

alter table public.profiles
  add constraint profiles_gallery_paths_is_array
  check (jsonb_typeof(gallery_paths) = 'array');

-- Backfill existing single avatars as the first gallery photo.
update public.profiles
set gallery_paths = jsonb_build_array(avatar_path)
where coalesce(jsonb_array_length(gallery_paths), 0) = 0
  and avatar_path is not null
  and btrim(avatar_path) <> '';

-- The app writes objects below the existing profile-avatars/gallery/ prefix.
-- Preserve the existing bucket policies and ensure they allow authenticated
-- owners to upload/read their own gallery objects without broadening access.
