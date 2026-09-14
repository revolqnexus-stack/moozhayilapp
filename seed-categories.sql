-- Seed basic jewelry categories

INSERT INTO categories (id, name, slug, parent_id, sort_order, is_active, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'Rings', 'rings', NULL, 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Necklaces', 'necklaces', NULL, 2, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Earrings', 'earrings', NULL, 3, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Bangles', 'bangles', NULL, 4, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Bracelets', 'bracelets', NULL, 5, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Pendants', 'pendants', NULL, 6, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Chains', 'chains', NULL, 7, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Anklets', 'anklets', NULL, 8, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Nose Pins', 'nose-pins', NULL, 9, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Mangalsutra', 'mangalsutra', NULL, 10, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Seed basic occasions

INSERT INTO occasions (id, name, slug, sort_order, is_active, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'Wedding', 'wedding', 1, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Engagement', 'engagement', 2, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Festival', 'festival', 3, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Birthday', 'birthday', 4, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Anniversary', 'anniversary', 5, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Daily Wear', 'daily-wear', 6, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Office Wear', 'office-wear', 7, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Party Wear', 'party-wear', 8, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Seed a basic collection

INSERT INTO collections (id, name, slug, description, is_active, is_featured, sort_order, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'Heritage Collection', 'heritage-collection', 'Timeless pieces celebrating 100+ years of craftsmanship', true, true, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Modern Elegance', 'modern-elegance', 'Contemporary designs for the modern wearer', true, true, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (gen_random_uuid(), 'Bridal Collection', 'bridal-collection', 'Exquisite pieces for your special day', true, true, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
