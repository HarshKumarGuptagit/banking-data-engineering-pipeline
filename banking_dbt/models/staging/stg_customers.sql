{{
    config(
        materialized = "view"
    )
}}

WITH ranked AS(
    SELECT 
        v:id::string as customer_id,
        v:first_name::string as first_name,
        v:last_name::string as last_name,
        v:email::string as email,
        v:created_at::string as created_at,
        current_timestamp AS load_timestamp,
        row_number() over (
            partition by v:id::string
            order by v:created_at desc
        ) AS rn
    FROM 
        {{ source('raw','customers')}}
)
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    created_at,
    load_timestamp
FROM ranked 
WHERE rn = 1 