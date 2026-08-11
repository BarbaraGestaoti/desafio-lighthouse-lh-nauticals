-- Consulta para validar a volumetria de cada tabela carregada na Camada Bronze
SELECT 'addresses' AS tabela, COUNT(*) AS total FROM addresses
UNION ALL SELECT 'attributes', COUNT(*) FROM attributes
UNION ALL SELECT 'brands', COUNT(*) FROM brands
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'fiscal_invoices', COUNT(*) FROM fiscal_invoices
UNION ALL SELECT 'goods_receipt_items', COUNT(*) FROM goods_receipt_items
UNION ALL SELECT 'goods_receipts', COUNT(*) FROM goods_receipts
UNION ALL SELECT 'locations', COUNT(*) FROM locations
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'product_suppliers', COUNT(*) FROM product_suppliers
UNION ALL SELECT 'product_variants', COUNT(*) FROM product_variants
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'purchase_order_items', COUNT(*) FROM purchase_order_items
UNION ALL SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL SELECT 'return_items', COUNT(*) FROM return_items
UNION ALL SELECT 'returns', COUNT(*) FROM returns
UNION ALL SELECT 'stock_levels', COUNT(*) FROM stock_levels
UNION ALL SELECT 'stock_movements', COUNT(*) FROM stock_movements
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'variant_attribute_values', COUNT(*) FROM variant_attribute_values
ORDER BY total DESC;