SELECT
    off.offer_name,
    off.funding_source,
    off.investment_limit,
    off.investment_used,
    prod.brand,
    prod.manufacturer,
    off.allocation_id,
    off.start_date,
    off.end_date
FROM data_offers AS off
INNER JOIN data_offer_products AS det
    ON off.offer_id = det.offer_id
INNER JOIN data_products AS prod
    ON det.product_id = prod.product_id
WHERE off.offer_name IS NOT NULL
  AND off.start_date >= DATE_ADD('month', -4, CURRENT_DATE)
  AND off.investment_limit IS NOT NULL;
