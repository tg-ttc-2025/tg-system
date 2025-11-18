-- ============================================
-- TG-SYSTEM Database Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- DEFENSE DETECTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS defense_detections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    obj_id VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    alt DECIMAL(10, 2),
    ground_height VARCHAR(50),
    objective VARCHAR(100),
    size VARCHAR(50),
    details JSONB DEFAULT '{}',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for better query performance (removed unique constraint for logging)
    CONSTRAINT defense_detections_type_check CHECK (type IN ('drone', 'vehicle', 'person', 'unknown'))
);

-- ============================================
-- IMAGE PATHS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS defense_detection_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    defense_detection_id UUID NOT NULL,
    path TEXT NOT NULL,
    bucket_name VARCHAR(100) DEFAULT 'tg-detections',
    file_name VARCHAR(255) NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    upload_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Foreign key constraint
    CONSTRAINT fk_defense_detection 
        FOREIGN KEY (defense_detection_id) 
        REFERENCES defense_detections(id) 
        ON DELETE CASCADE,
    
    -- Ensure path is unique
    CONSTRAINT unique_image_path UNIQUE (path)
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_defense_detections_timestamp ON defense_detections(timestamp DESC);
CREATE INDEX idx_defense_detections_type ON defense_detections(type);
CREATE INDEX idx_defense_detections_obj_id ON defense_detections(obj_id);
CREATE INDEX idx_defense_detections_location ON defense_detections(lat, lng);

CREATE INDEX idx_images_defense_detection_id ON defense_detection_images(defense_detection_id);
CREATE INDEX idx_images_upload_timestamp ON defense_detection_images(upload_timestamp DESC);
CREATE INDEX idx_images_is_primary ON defense_detection_images(is_primary) WHERE is_primary = TRUE;

-- ============================================
-- UPDATED_AT TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_defense_detections_updated_at 
    BEFORE UPDATE ON defense_detections
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS
-- ============================================

-- View to get detections with image count
CREATE OR REPLACE VIEW defense_detections_summary AS
SELECT 
    od.*,
    COUNT(odi.id) as image_count,
    ARRAY_AGG(odi.path ORDER BY odi.is_primary DESC, odi.upload_timestamp) FILTER (WHERE odi.id IS NOT NULL) as image_paths
FROM defense_detections od
LEFT JOIN defense_detection_images odi ON od.id = odi.defense_detection_id
GROUP BY od.id;

-- View to get primary images for each detection
CREATE OR REPLACE VIEW defense_detections_with_primary_image AS
SELECT 
    od.*,
    odi.path as primary_image_path,
    odi.file_name as primary_image_name
FROM defense_detections od
LEFT JOIN LATERAL (
    SELECT * FROM defense_detection_images
    WHERE defense_detection_id = od.id
    ORDER BY is_primary DESC, upload_timestamp ASC
    LIMIT 1
) odi ON true;

-- ============================================
-- COMMENTS
-- ============================================
COMMENT ON TABLE defense_detections IS 'Main table storing defense detection events';
COMMENT ON TABLE defense_detection_images IS 'Stores multiple image paths from MinIO for each detection';
COMMENT ON COLUMN defense_detections.details IS 'JSON object storing additional detection details (color, speed, etc.)';
COMMENT ON COLUMN defense_detection_images.is_primary IS 'Marks the primary/thumbnail image for the detection';
COMMENT ON COLUMN defense_detection_images.bucket_name IS 'MinIO bucket name where the image is stored';