-- ============================================
-- TG-SYSTEM Seed Data
-- ============================================

-- Insert sample offense detections
INSERT INTO offense_detections (id, obj_id, type, lat, lng, alt, ground_height, objective, size, details, timestamp) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'DRONE-001',
    'drone',
    13.7563,
    100.5018,
    150.50,
    '50m',
    'Surveillance',
    'medium',
    '{"color": "black", "speed": "25 km/h", "model": "DJI Phantom 4"}',
    '2024-11-12 10:30:00+07'
),
(
    '22222222-2222-2222-2222-222222222222',
    'DRONE-002',
    'drone',
    13.7400,
    100.5300,
    200.00,
    '75m',
    'Unknown',
    'large',
    '{"color": "white", "speed": "35 km/h", "model": "Unknown"}',
    '2024-11-12 11:15:00+07'
),
(
    '33333333-3333-3333-3333-333333333333',
    'VEH-001',
    'vehicle',
    13.7600,
    100.5100,
    0,
    '0m',
    'Transport',
    'large',
    '{"color": "red", "speed": "60 km/h", "type": "truck"}',
    '2024-11-12 12:00:00+07'
);

-- Insert sample image paths for detections
-- DRONE-001 has 3 images
INSERT INTO offense_detection_images (offense_detection_id, path, bucket_name, file_name, file_size, mime_type, is_primary) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'detections/2024/11/12/DRONE-001/image-001-front.jpg',
    'tg-detections',
    'image-001-front.jpg',
    2048576,
    'image/jpeg',
    TRUE
),
(
    '11111111-1111-1111-1111-111111111111',
    'detections/2024/11/12/DRONE-001/image-001-side.jpg',
    'tg-detections',
    'image-001-side.jpg',
    1984532,
    'image/jpeg',
    FALSE
),
(
    '11111111-1111-1111-1111-111111111111',
    'detections/2024/11/12/DRONE-001/image-001-top.jpg',
    'tg-detections',
    'image-001-top.jpg',
    1756234,
    'image/jpeg',
    FALSE
);

-- DRONE-002 has 2 images
INSERT INTO offense_detection_images (offense_detection_id, path, bucket_name, file_name, file_size, mime_type, is_primary) VALUES
(
    '22222222-2222-2222-2222-222222222222',
    'detections/2024/11/12/DRONE-002/image-002-front.jpg',
    'tg-detections',
    'image-002-front.jpg',
    3145728,
    'image/jpeg',
    TRUE
),
(
    '22222222-2222-2222-2222-222222222222',
    'detections/2024/11/12/DRONE-002/image-002-close.jpg',
    'tg-detections',
    'image-002-close.jpg',
    2897456,
    'image/jpeg',
    FALSE
);

-- VEH-001 has 1 image
INSERT INTO offense_detection_images (offense_detection_id, path, bucket_name, file_name, file_size, mime_type, is_primary) VALUES
(
    '33333333-3333-3333-3333-333333333333',
    'detections/2024/11/12/VEH-001/image-003.jpg',
    'tg-detections',
    'image-003.jpg',
    1567890,
    'image/jpeg',
    TRUE
);

-- ============================================
-- Verification Queries (commented out, uncomment to run)
-- ============================================

-- Check total detections
-- SELECT COUNT(*) as total_detections FROM offense_detections;

-- Check total images
-- SELECT COUNT(*) as total_images FROM offense_detection_images;

-- View all detections with their image counts
-- SELECT * FROM offense_detections_summary;

-- View detections with primary images
-- SELECT * FROM offense_detections_with_primary_image;

-- Get a specific detection with all its images
-- SELECT 
--     od.*,
--     json_agg(
--         json_build_object(
--             'path', odi.path,
--             'file_name', odi.file_name,
--             'is_primary', odi.is_primary,
--             'upload_timestamp', odi.upload_timestamp
--         ) ORDER BY odi.is_primary DESC, odi.upload_timestamp
--     ) as images
-- FROM offense_detections od
-- LEFT JOIN offense_detection_images odi ON od.id = odi.offense_detection_id
-- WHERE od.obj_id = 'DRONE-001'
-- GROUP BY od.id;