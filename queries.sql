-- Inserts
-- Adding a new client
INSERT INTO "clients" ("first_name", "last_name", "title")
VALUES ('Mister', 'Anteater', 'Mr');

-- Opening a case for the new client
INSERT INTO "cases" ("title", "type", "price", "client_id")
VALUES (
    'The disappearance of Mr Shark', 'Missing person',
    100000,
    (SELECT "id" FROM "clients" WHERE "first_name" = 'Mister' AND "last_name" = 'Anteater')
);

-- Adding a new detective to the agency
INSERT INTO "personnel" ("first_name", "last_name", "title")
VALUES ('Mister', 'Sheep', 'Mr');

-- Adding a new assignment for Mister Sheep for the current case
INSERT INTO "assignments" ("case_id", "personnel_id", "payment", "paid")
VALUES (
    (SELECT "id" FROM "cases" WHERE "title" = 'The disappearance of Mr Shark'),
    (SELECT "id" FROM "personnel" WHERE "first_name" = 'Mister' AND "last_name" = 'Sheep'),
    20000,
    5000
);

-- Adding a new person of interest
INSERT INTO "people_of_interest" ("first_name", "last_name", "title", "address")
VALUES ("Fat", "Cat", "Mrs.", "pier");

-- Adding person of interest to the relation to case table
INSERT INTO "relation_to_case" ("poi_id", "case_id", "role")
VALUES (
    (SELECT "id" FROM "people_of_interest" WHERE "first_name" = 'Fat' AND "last_name" = 'Cat'),
    (SELECT "id" FROM "cases" WHERE "title" = 'The disappearance of Mr Shark'),
    "witness"
);

-- Adding testimony into evidence
INSERT INTO "evidence" ("title", "registration_date", "type", "description", "case_id", "poi_id")
VALUES (
    'Account of Mrs. Fat Cat',
    '2026-06-16',
    'Testimonial',
    '"I was at the pier yesterday afternoon, eating a delicious, big, juicy salmon, purr,
    sooo delicious, purr, the sun was warm on my fur, such a lovely day, purr,
    and I saw Mr. Shark swimming in the water, nothing special seemed to be happening.
    But then when I went to get another scrumptious salmon and returned, Mr. Shark wasn''t there anymore,
    I thought nothing of it at the time. That must have been around 15, before my 3-hour afternoon nap before dinner."
    Mrs. Cat will testify in court.',
    (SELECT "id" FROM "cases" WHERE "title" = 'The disappearance of Mr Shark'),
    (SELECT "id" FROM "people_of_interest" WHERE "first_name" = 'Fat' AND "last_name" = 'Cat')
);

-- Updates
-- Updating the paid salary for the detective
UPDATE "assignments"
SET "paid" = "paid" + 5000
WHERE "personnel_id" = (
    SELECT "id" FROM "personnel"
    WHERE "first_name" = 'Mister'
    AND "last_name" = 'Sheep'
)
AND "case_id" = (
    SELECT "id" FROM "cases"
    WHERE "title" = 'The disappearance of Mr Shark'
);

-- Updating the received payment from the client
UPDATE "cases"
SET "received" = "received" + 27500
WHERE "title" = 'The disappearance of Mr Shark';


-- Queries
-- Opens the current cases for client Mr Anteater
SELECT *
FROM "cases"
WHERE "client_id" IN (
    SELECT "id"
    FROM "clients"
    WHERE "first_name" = 'Mister'
    AND "last_name" = 'Anteater'
);

-- Opens all cases and assigned payments for Mr Anteater
SELECT "Case", "Target" AS "Price", "Owed by client" FROM "payments"
WHERE "Client" = 'Mister Anteater';

-- Opens current account balance of Mr Anteater
SELECT SUM("Owed by client") AS "Total owed" FROM "payments"
WHERE "Client" = 'Mister Anteater';

-- Opens Mrs Fat Cat's testimony on the current case
SELECT "description"
FROM "evidence"
WHERE "type" = 'Testimonial'
AND "case_id" = (
    SELECT "id"
    FROM "cases"
    WHERE "title" = 'The disappearance of Mr Shark'
)
AND "poi_id" = (
    SELECT "id"
    FROM "people_of_interest"
    WHERE "first_name" = 'Fat'
    AND "last_name" = 'Cat'
);
