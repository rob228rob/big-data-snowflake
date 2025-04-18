INSERT INTO dim_countries (name)
SELECT DISTINCT customer_country
FROM mock_data
WHERE customer_country IS NOT NULL
UNION
SELECT DISTINCT seller_country
FROM mock_data
WHERE seller_country IS NOT NULL
UNION
SELECT DISTINCT store_country
FROM mock_data
WHERE store_country IS NOT NULL
UNION
SELECT DISTINCT supplier_country
FROM mock_data
WHERE supplier_country IS NOT NULL;

INSERT INTO dim_cities (name)
SELECT DISTINCT store_city
FROM mock_data
WHERE store_city IS NOT NULL
UNION
SELECT DISTINCT supplier_city
FROM mock_data
WHERE supplier_city IS NOT NULL;

INSERT INTO dim_dates (date)
SELECT DISTINCT TO_DATE(sale_date, 'MM/DD/YYYY')
FROM mock_data
WHERE sale_date IS NOT NULL
UNION
SELECT DISTINCT TO_DATE(product_release_date, 'MM/DD/YYYY')
FROM mock_data
WHERE product_release_date IS NOT NULL
UNION
SELECT DISTINCT TO_DATE(product_expiry_date, 'MM/DD/YYYY')
FROM mock_data
WHERE product_expiry_date IS NOT NULL;

INSERT INTO dim_pet_types (name)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type IS NOT NULL;

INSERT INTO dim_pet_breeds (name)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed IS NOT NULL;

INSERT INTO dim_pet_categories (name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL;

INSERT INTO dim_pets (type_id, name, breed_id, category_id)
SELECT pt.id,
       mock.customer_pet_name,
       pb.id,
       pc.id
FROM mock_data mock
         LEFT JOIN
     dim_pet_types pt ON mock.customer_pet_type = pt.name
         LEFT JOIN
     dim_pet_breeds pb ON mock.customer_pet_breed = pb.name
         LEFT JOIN
     dim_pet_categories pc ON mock.pet_category = pc.name
GROUP BY pt.id, mock.customer_pet_name, pb.id, pc.id;

INSERT INTO dim_product_categories (name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL;

INSERT INTO dim_product_colors (name)
SELECT DISTINCT product_color
FROM mock_data
WHERE product_color IS NOT NULL;

INSERT INTO dim_product_sizes (name)
SELECT DISTINCT product_size
FROM mock_data
WHERE product_size IS NOT NULL;

INSERT INTO dim_product_brands (name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL;

INSERT INTO dim_product_materials (name)
SELECT DISTINCT product_material
FROM mock_data
WHERE product_material IS NOT NULL;

INSERT INTO dim_products (name,
                          category_id,
                          price,
                          weight,
                          color_id,
                          size_id,
                          brand_id,
                          material_id,
                          description,
                          rating,
                          reviews,
                          release_date_id,
                          expiry_date_id)
SELECT mock.product_name,
       dp_cats.id,
       mock.product_price,
       mock.product_weight,
       dp_col.id,
       dp_sizes.id,
       dp_brands.id,
       dp_mat.id,
       mock.product_description,
       mock.product_rating,
       mock.product_reviews,
       d_date.id,
       e_date.id
FROM mock_data mock
         JOIN
     dim_product_categories dp_cats ON mock.product_category = dp_cats.name
         LEFT JOIN
     dim_product_colors dp_col ON mock.product_color = dp_col.name
         LEFT JOIN
     dim_product_sizes dp_sizes ON mock.product_size = dp_sizes.name
         LEFT JOIN
     dim_product_brands dp_brands ON mock.product_brand = dp_brands.name
         LEFT JOIN
     dim_product_materials dp_mat ON mock.product_material = dp_mat.name
         LEFT JOIN
     dim_dates d_date ON TO_DATE(mock.product_release_date, 'MM/DD/YYYY') = d_date.date
         LEFT JOIN
     dim_dates e_date ON TO_DATE(mock.product_expiry_date, 'MM/DD/YYYY') = e_date.date
GROUP BY mock.product_name, dp_cats.id, mock.product_price, mock.product_weight, dp_col.id, dp_sizes.id, dp_brands.id, dp_mat.id,
         mock.product_description, mock.product_rating, mock.product_reviews, d_date.id, e_date.id;

INSERT INTO dim_customers (first_name,
                           last_name,
                           age,
                           email,
                           country_id,
                           postal_code,
                           pet_id)
SELECT mock.customer_first_name,
       mock.customer_last_name,
       mock.customer_age,
       mock.customer_email,
       c.id,
       mock.customer_postal_code,
       p.id
FROM mock_data mock
         LEFT JOIN
     dim_countries c ON mock.customer_country = c.name
         LEFT JOIN
     dim_pet_types pt ON mock.customer_pet_type = pt.name
         LEFT JOIN
     dim_pet_breeds pb ON mock.customer_pet_breed = pb.name
         LEFT JOIN
     dim_pet_categories pc ON mock.pet_category = pc.name
         LEFT JOIN
     dim_pets p ON
         mock.customer_pet_name = p.name
             AND pt.id = p.type_id
             AND pb.id = p.breed_id
             AND pc.id = p.category_id
GROUP BY mock.customer_first_name, mock.customer_last_name, mock.customer_age, mock.customer_email,
         c.id, mock.customer_postal_code, p.id;

INSERT INTO dim_sellers (first_name,
                         last_name,
                         email,
                         country_id,
                         postal_code)
SELECT mock.seller_first_name,
       mock.seller_last_name,
       mock.seller_email,
       c.id,
       mock.seller_postal_code
FROM mock_data mock
         LEFT JOIN
     dim_countries c ON mock.seller_country = c.name
GROUP BY mock.seller_first_name, mock.seller_last_name, mock.seller_email, c.id, mock.seller_postal_code;

INSERT INTO dim_stores (name,
                        location,
                        city_id,
                        state,
                        country_id,
                        phone,
                        email)
SELECT mock.store_name,
       mock.store_location,
       ci.id,
       mock.store_state,
       co.id,
       mock.store_phone,
       mock.store_email
FROM mock_data mock
         LEFT JOIN
     dim_countries co ON mock.store_country = co.name
         LEFT JOIN
     dim_cities ci ON mock.store_city = ci.name
GROUP BY mock.store_name, mock.store_location, ci.id, mock.store_state, co.id, mock.store_phone, mock.store_email;

INSERT INTO dim_suppliers (name,
                           contact,
                           email,
                           phone,
                           address,
                           city_id,
                           country_id)
SELECT mock.supplier_name,
       mock.supplier_contact,
       mock.supplier_email,
       mock.supplier_phone,
       mock.supplier_address,
       ci.id,
       co.id
FROM mock_data mock
         LEFT JOIN
     dim_countries co ON mock.supplier_country = co.name
         LEFT JOIN
     dim_cities ci ON mock.supplier_city = ci.name
GROUP BY mock.supplier_name, 
         mock.supplier_contact, 
         mock.supplier_email, 
         mock.supplier_phone,
         mock.supplier_address, 
         ci.id, 
         co.id;

INSERT INTO facts_sales (customer_id,
                         seller_id,
                         product_id,
                         product_quantity,
                         date_id,
                         quantity,
                         total_price,
                         store_id,
                         supplier_id)
SELECT cu.id,
       s.id,
       p.id,
       mock.product_quantity,
       d.id,
       mock.sale_quantity,
       mock.sale_total_price,
       st.id,
       su.id
FROM mock_data mock
-- customer_id
         LEFT JOIN
     dim_customers cu ON mock.customer_email = cu.email
-- seller_id
         LEFT JOIN
     dim_sellers s ON mock.seller_email = s.email
-- product_id
         LEFT JOIN
     dim_product_categories pca ON mock.product_category = pca.name
         LEFT JOIN
     dim_product_colors pcol ON mock.product_color = pcol.name
         LEFT JOIN
     dim_product_sizes ps ON mock.product_size = ps.name
         LEFT JOIN
     dim_product_brands pb ON mock.product_brand = pb.name
         LEFT JOIN
     dim_product_materials pm ON mock.product_material = pm.name
         LEFT JOIN
     dim_dates dr ON TO_DATE(mock.product_release_date, 'MM/DD/YYYY') = dr.date
         LEFT JOIN
     dim_dates de ON TO_DATE(mock.product_expiry_date, 'MM/DD/YYYY') = de.date
         LEFT JOIN
     dim_products p ON
         mock.product_name = p.name
             AND pca.id = p.category_id
             AND mock.product_price = p.price
             AND mock.product_weight = p.weight
             AND pcol.id = p.color_id
             AND ps.id = p.size_id
             AND pb.id = p.brand_id
             AND pm.id = p.material_id
             AND mock.product_description = p.description
             AND mock.product_rating = p.rating
             AND mock.product_reviews = p.reviews
             AND dr.id = p.release_date_id
             AND de.id = p.expiry_date_id
-- date_id
         LEFT JOIN
     dim_dates d ON TO_DATE(mock.sale_date, 'MM/DD/YYYY') = d.date
-- store_id
         LEFT JOIN
     dim_stores st ON mock.store_email = st.email
-- supplier_id
         LEFT JOIN
     dim_suppliers su ON mock.supplier_email = su.email;
