-- Store branding & product images: columns + Supabase Storage buckets.

-- Product image metadata (optional; images live in storage).
alter table products
  add column if not exists image_url text,
  add column if not exists thumbnail_url text,
  add column if not exists category_icon text,
  add column if not exists has_image boolean not null default false;

-- Store contact / branding (logo_url already exists on stores).
alter table stores
  add column if not exists phone text,
  add column if not exists email text,
  add column if not exists invoice_footer text;

-- ---------------------------------------------------------------------------
-- Storage buckets
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  (
    'store-logos',
    'store-logos',
    true,
    2097152,
    array['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'product-images',
    'product-images',
    true,
    5242880,
    array['image/jpeg', 'image/png', 'image/webp']
  )
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- ---------------------------------------------------------------------------
-- Storage policies (authenticated store members)
-- ---------------------------------------------------------------------------

drop policy if exists inventrax_store_logos_select on storage.objects;
create policy inventrax_store_logos_select on storage.objects
  for select
  using (bucket_id = 'store-logos');

drop policy if exists inventrax_store_logos_insert on storage.objects;
create policy inventrax_store_logos_insert on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'store-logos'
    and (storage.foldername(name))[1] = public.inventrax_tenant_id()
    and (storage.foldername(name))[2] = public.inventrax_store_id()
  );

drop policy if exists inventrax_store_logos_update on storage.objects;
create policy inventrax_store_logos_update on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'store-logos'
    and (storage.foldername(name))[1] = public.inventrax_tenant_id()
    and (storage.foldername(name))[2] = public.inventrax_store_id()
  );

drop policy if exists inventrax_store_logos_delete on storage.objects;
create policy inventrax_store_logos_delete on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'store-logos'
    and (storage.foldername(name))[1] = public.inventrax_tenant_id()
    and (storage.foldername(name))[2] = public.inventrax_store_id()
  );

drop policy if exists inventrax_product_images_select on storage.objects;
create policy inventrax_product_images_select on storage.objects
  for select
  using (bucket_id = 'product-images');

drop policy if exists inventrax_product_images_insert on storage.objects;
create policy inventrax_product_images_insert on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] = public.inventrax_tenant_id()
    and (storage.foldername(name))[2] = public.inventrax_store_id()
  );

drop policy if exists inventrax_product_images_update on storage.objects;
create policy inventrax_product_images_update on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] = public.inventrax_tenant_id()
    and (storage.foldername(name))[2] = public.inventrax_store_id()
  );

drop policy if exists inventrax_product_images_delete on storage.objects;
create policy inventrax_product_images_delete on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] = public.inventrax_tenant_id()
    and (storage.foldername(name))[2] = public.inventrax_store_id()
  );
