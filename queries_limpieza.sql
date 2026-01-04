-- ==========================================================
-- PROYECTO: ANÁLISIS DEL ECOSISTEMA DE STREAMING 2024
-- PROPÓSITO: Limpieza, Transformación y Unión de Datos
-- AUTOR: Alejandro Diaz
-- ==========================================================

-- 1. EXPLORACIÓN INICIAL Y CÁLCULO DE REVENUE MENSUAL
-- Se calcula el ingreso mensual estimado basado en suscriptores y ARPU.
-- Se utiliza ROUND y CAST (::numeric) para asegurar precisión en PostgreSQL.
SELECT 
    service_name,
    content_type,
    subscribers_millions,
    arpu_usd,
    ROUND((subscribers_millions * arpu_usd)::numeric, 2) AS revenue_mensual_millones
FROM paid_video_streaming_services
ORDER BY revenue_mensual_millones DESC;

-- 2. SEGMENTACIÓN POR CATEGORÍA DE PRECIO (Lógica de Negocio)
-- Clasificación de servicios según su costo mensual usando CASE WHEN.
SELECT 
    service_name,
    monthly_price_usd,
    CASE 
        WHEN monthly_price_usd > 12 THEN 'Premium'
        WHEN monthly_price_usd BETWEEN 5 AND 12 THEN 'Estándar'
        ELSE 'Económica'
    END AS categoria_precio,
    churn_rate_pct
FROM paid_video_streaming_services
WHERE subscribers_millions > 0;

-- 3. UNIÓN DE TABLAS (JOIN): PRESENTE VS PREDICCIONES FUTURAS
-- Cruzamos la tabla de servicios actuales con las predicciones de crecimiento.
-- Esto permite calcular la brecha de crecimiento absoluto.
SELECT 
    p.service_name,
    p.subscribers_millions AS subs_actuales,
    g.predicted_subscribers AS subs_proyectados,
    ROUND((g.predicted_subscribers - p.subscribers_millions)::numeric, 2) AS crecimiento_esperado
FROM paid_video_streaming_services p
INNER JOIN paid_video_growth_predictions g 
    ON p.service_name = g.service_name
ORDER BY crecimiento_esperado DESC;

-- 4. ANÁLISIS DE ECOSISTEMA (PAID VS FREE)
-- Buscamos empresas que operan en ambos modelos para identificar estrategias de retención.
SELECT 
    p.parent_company,
    p.service_name AS servicio_pago,
    f.service_name AS servicio_gratis,
    p.churn_rate_pct AS churn_pago
FROM paid_video_streaming_services p
LEFT JOIN free_video_streaming_services f 
    ON p.parent_company = f.parent_company
WHERE f.service_name IS NOT NULL
ORDER BY p.churn_rate_pct ASC;

-- 5. EXTRACCIÓN DE TABLA MAESTRA PARA DASHBOARD
-- Query final utilizada para exportar a Google Sheets/Excel.
SELECT *, 
    (subscribers_millions * arpu_usd) AS revenue_mensual
FROM paid_video_streaming_services;