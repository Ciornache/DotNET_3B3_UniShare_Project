-- =============================
-- INSERT USERS (UAIC emails)
-- =============================
INSERT INTO "Users" ("Id", "Email", "UserName", "FirstName", "LastName", "EmailConfirmed", "CreatedAt")
SELECT gen_random_uuid(), 'john.doe@student.uaic.ro', 'john.doe', 'John', 'Doe', TRUE, NOW()
    WHERE NOT EXISTS (SELECT 1 FROM "Users" WHERE "Email" = 'john.doe@student.uaic.ro');

INSERT INTO "Users" ("Id", "Email", "UserName", "FirstName", "LastName", "EmailConfirmed", "CreatedAt")
SELECT gen_random_uuid(), 'alice.smith@student.uaic.ro', 'alice.smith', 'Alice', 'Smith', TRUE, NOW()
    WHERE NOT EXISTS (SELECT 1 FROM "Users" WHERE "Email" = 'alice.smith@student.uaic.ro');

INSERT INTO "Users" ("Id", "Email", "UserName", "FirstName", "LastName", "EmailConfirmed", "CreatedAt")
SELECT gen_random_uuid(), 'maria.popescu@student.uaic.ro', 'maria.popescu', 'Maria', 'Popescu', TRUE, NOW()
    WHERE NOT EXISTS (SELECT 1 FROM "Users" WHERE "Email" = 'maria.popescu@student.uaic.ro');

-- ==================================
-- INSERT ITEMS by joining to Users
-- ==================================
INSERT INTO "Items" ("Id", "Name", "Description", "Category", "Condition", "OwnerId", "ImageUrl", "CreatedAt", "IsAvailable")
SELECT
    gen_random_uuid(), v."Name", v."Description", v."Category", v."Condition", u."Id", v."ImageUrl", NOW(), TRUE
FROM (
         VALUES
             ('Laptop','High-end gaming laptop',0,0,'https://picsum.photos/200?1'),
             ('Textbook','Math textbook',1,1,'https://picsum.photos/200?2'),
             ('Backpack','Durable backpack',2,0,'https://picsum.photos/200?3'),
             ('Smartphone','Latest model smartphone',0,0,'https://picsum.photos/200?4'),
             ('Desk Chair','Office chair',4,1,'https://picsum.photos/200?5'),
             ('Monitor','27-inch 4K monitor',0,0,'https://picsum.photos/200?6'),
             ('Coffee Mug','Ceramic mug',3,1,'https://picsum.photos/200?7'),
             ('Headphones','Noise-cancelling headphones',0,0,'https://picsum.photos/200?8'),
             ('Notebook','College-ruled notebook',4,1,'https://picsum.photos/200?9'),
             ('Lamp','Desk lamp',4,0,'https://picsum.photos/200?10')
     ) AS v("Name","Description","Category","Condition","ImageUrl")
         JOIN "Users" u ON u."Email" = CASE
                                           WHEN v."Name" IN ('Laptop','Smartphone','Coffee Mug','Lamp') THEN 'john.doe@student.uaic.ro'
                                           WHEN v."Name" IN ('Textbook','Desk Chair','Headphones') THEN 'alice.smith@student.uaic.ro'
                                           ELSE 'maria.popescu@student.uaic.ro'
    END
WHERE NOT EXISTS (SELECT 1 FROM "Items");
