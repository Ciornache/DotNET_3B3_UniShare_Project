INSERT INTO "Universities" ("Id", "Name", "ShortCode", "EmailDomain", "CreatedAt")
VALUES
    -- Alexandru Ioan Cuza University of Iași
    (gen_random_uuid(), 'Alexandru Ioan Cuza University of Iași', 'UAIC', 'uaic.ro', NOW() AT TIME ZONE 'UTC'),

    -- Gheorghe Asachi Technical University of Iași
    (gen_random_uuid(), 'Gheorghe Asachi Technical University of Iași', 'TUIASI', 'tuiasi.ro', NOW() AT TIME ZONE 'UTC'),

    -- University of Bucharest
    (gen_random_uuid(), 'University of Bucharest', 'UB', 'unibuc.ro', NOW() AT TIME ZONE 'UTC'),

    -- Babeș-Bolyai University
    (gen_random_uuid(), 'Babeș-Bolyai University', 'UBB', 'ubbcluj.ro', NOW() AT TIME ZONE 'UTC'),

    -- Politehnica University of Bucharest
    (gen_random_uuid(), 'Politehnica University of Bucharest', 'UPB', 'upb.ro', NOW() AT TIME ZONE 'UTC'),

    -- West University of Timișoara
    (gen_random_uuid(), 'West University of Timișoara', 'UVT', 'e-uvt.ro', NOW() AT TIME ZONE 'UTC'),

    -- University of Craiova
    (gen_random_uuid(), 'University of Craiova', 'UCV', 'ucv.ro', NOW() AT TIME ZONE 'UTC');
