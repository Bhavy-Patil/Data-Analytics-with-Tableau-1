-- Global EV Mobility & Adoption Intelligence Database Schema
-- Optimized for analytical aggregation, indexing, and Tableau connectivity

DROP TABLE IF EXISTS dim_vehicle_specifications CASCADE;
DROP TABLE IF EXISTS fact_ev_market_records CASCADE;

-- Master analytical table for ingestion
CREATE TABLE fact_ev_market_records (
    record_id VARCHAR(64) PRIMARY KEY,
    vehicle_model VARCHAR(120) NOT NULL,
    oem_brand VARCHAR(120) NOT NULL,
    release_year SMALLINT NOT NULL,
    origin_country VARCHAR(100) NOT NULL,
    regional_market VARCHAR(100) NOT NULL,
    vehicle_segment VARCHAR(60) NOT NULL,
    pack_capacity_kwh NUMERIC(8, 2),
    chemistry_type VARCHAR(60),
    max_range_km NUMERIC(8, 2),
    velocity_ceiling_kmh NUMERIC(8, 2),
    powertrain_units SMALLINT DEFAULT 1,
    drive_configuration VARCHAR(30),
    annual_volume_delivered NUMERIC(14, 2),
    retail_price_usd NUMERIC(10, 2),
    consumer_sentiment_score SMALLINT,
    co2_reduction_mt NUMERIC(8, 2),
    dc_fast_charge_duration_hrs NUMERIC(6, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Analytical B-Tree Indexes for rapid query filtering
CREATE INDEX idx_segment_brand ON fact_ev_market_records(vehicle_segment, oem_brand);
CREATE INDEX idx_origin_country ON fact_ev_market_records(origin_country);
CREATE INDEX idx_release_year ON fact_ev_market_records(release_year);
CREATE INDEX idx_chemistry ON fact_ev_market_records(chemistry_type);

-- ============================================================================
-- CORE ANALYTICAL QUERIES
-- ============================================================================

-- Query 1: Top-Level Executive Portfolio Summary
SELECT 
    COUNT(DISTINCT oem_brand) AS total_active_oems,
    COUNT(DISTINCT vehicle_model) AS total_model_variants,
    ROUND(SUM(annual_volume_delivered) / 1000000.0, 2) AS gross_sales_volume_millions,
    ROUND(AVG(consumer_sentiment_score), 2) AS aggregate_satisfaction,
    ROUND(AVG(max_range_km), 2) AS weighted_range_km,
    ROUND(AVG(pack_capacity_kwh), 2) AS weighted_capacity_kwh
FROM fact_ev_market_records;

-- Query 2: OEM Market Share and Segment Dominance
SELECT 
    oem_brand,
    COUNT(DISTINCT vehicle_model) AS offered_models,
    ROUND(SUM(annual_volume_delivered) / 1000000.0, 2) AS total_deliveries_m,
    ROUND(AVG(max_range_km), 1) AS mean_range,
    ROUND(100.0 * SUM(annual_volume_delivered) / (SELECT SUM(annual_volume_delivered) FROM fact_ev_market_records), 2) AS market_share_percentage
FROM fact_ev_market_records
GROUP BY oem_brand
ORDER BY total_deliveries_m DESC
LIMIT 15;

-- Query 3: Battery Chemistry Efficiency & Range Breakdown
SELECT 
    chemistry_type,
    COUNT(*) AS total_deployed_variants,
    ROUND(AVG(max_range_km), 1) AS avg_autonomy_km,
    ROUND(AVG(pack_capacity_kwh), 1) AS avg_capacity_kwh,
    ROUND(AVG(max_range_km / NULLIF(pack_capacity_kwh, 0)), 2) AS km_per_kwh_efficiency
FROM fact_ev_market_records
WHERE chemistry_type IS NOT NULL
GROUP BY chemistry_type
ORDER BY avg_autonomy_km DESC;

-- Query 4: Geographic Production Footprint & Regional Export Volume
SELECT 
    origin_country,
    COUNT(DISTINCT oem_brand) AS participating_manufacturers,
    ROUND(SUM(annual_volume_delivered) / 1000000.0, 2) AS output_volume_millions,
    ROUND(AVG(retail_price_usd), 0) AS avg_retail_ticket_usd
FROM fact_ev_market_records
GROUP BY origin_country
ORDER BY output_volume_millions DESC;
