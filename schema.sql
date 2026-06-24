-- Tables
-- Represents cases of the department
CREATE TABLE "cases" (
    "id" INTEGER,
    "title" TEXT NOT NULL,
    "client_id" INTEGER NOT NULL,
    "start_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "end_date" NUMERIC,
    "status" TEXT CHECK("status" IN ('Open', 'Resolved', 'Unresolved')) DEFAULT 'Open',
    "type" TEXT,
    "file" BLOB,
    "price" REAL,
    "received" REAL DEFAULT 0,
    PRIMARY KEY("id"),
    FOREIGN KEY("client_id") REFERENCES "clients"("id")
);

-- Represents people working for the department
CREATE TABLE "personnel" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "title" TEXT,
    "role" TEXT,
    "phone" NUMERIC,
    "email" TEXT,
    "address" TEXT,
    "payment_info" TEXT,
    PRIMARY KEY("id")
 );

-- Represents people who provided a contract to the department
CREATE TABLE "clients" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "title" TEXT,
    "phone" NUMERIC,
    "email" TEXT,
    "address" TEXT,
    "payment_info" TEXT,
    PRIMARY KEY("id")
);

-- Represents people that are of interest to a case
CREATE TABLE "people_of_interest" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "title" TEXT,
    "phone" NUMERIC,
    "email" TEXT,
    "address" TEXT,
    PRIMARY KEY("id")
);

-- Represents people and object evidence
CREATE TABLE "evidence" (
    "id" INTEGER,
    "title" TEXT NOT NULL,
    "registration_date" NUMERIC DEFAULT CURRENT_TIMESTAMP,
    "type" TEXT CHECK("type" IN ('Anecdotal', 'Hearsay', 'Testimonial', 'Direct')),
    "description" TEXT,
    "file" BLOB,
    "case_id" INTEGER NOT NULL,
    "poi_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("case_id") REFERENCES "cases"("id"),
    FOREIGN KEY("poi_id") REFERENCES "people_of_interest"("id")
);

-- Represents the assignment of personnel to cases
CREATE TABLE "assignments" (
    "case_id" INTEGER NOT NULL,
    "personnel_id" INTEGER NOT NULL,
    "payment" REAL,
    "paid" REAL DEFAULT 0,
    FOREIGN KEY("case_id") REFERENCES "cases"("id"),
    FOREIGN KEY("personnel_id") REFERENCES "personnel"("id")
);

-- Represents the relation of people of interest to cases
CREATE TABLE "relation_to_case" (
    "poi_id" INTEGER NOT NULL,
    "case_id" INTEGER NOT NULL,
    "role" TEXT,
    FOREIGN KEY("poi_id") REFERENCES "people_of_interest"("id"),
    FOREIGN KEY("case_id") REFERENCES "cases"("id")
);


-- Indexes the names of people of interest
CREATE INDEX "poi_index" ON "people_of_interest" ("first_name", "last_name");

-- Indexes the names of evidence
CREATE INDEX "evidence_index" ON "evidence" ("title");

-- Indexes the names of cases
CREATE INDEX "cases_index" ON "cases" ("title");


-- Views
-- Displays a view of incoming and outgoing payments and current balance
CREATE VIEW "payments" AS
SELECT
    "cases"."id" as "Case ID",
    "cases"."title" AS "Case",
    "price" AS "Target",
    "received" AS "Actual",
    ("price"-"received") AS "Owed by client",
    "client_id" AS "Client ID",
    ("clients"."first_name" || ' ' || "clients"."last_name") AS "Client",
    "payment" AS "Detective Pay Target",
    "paid" AS "Detective Pay Actual",
    ("payment"-"paid") AS "Owed to detective",
    "assignments"."personnel_id" AS "Detective ID",
    ("personnel"."first_name" || ' ' || "personnel"."last_name") AS "Detective"
FROM "cases"
JOIN "assignments" ON "assignments"."case_id" = "cases"."id"
JOIN "clients" ON "clients"."id" = "cases"."client_id"
JOIN "personnel" ON "personnel"."id" = "assignments"."personnel_id"
ORDER BY "start_date", "end_date", "cases"."id";

-- Displays a view of personnel without a current assignment
CREATE VIEW "Unassigned Detectives" AS
SELECT
    "first_name" AS "First Name",
    "last_name" AS "Last Name",
    "id" AS "Detective ID"
FROM "personnel"
EXCEPT
SELECT
    "personnel"."first_name",
    "personnel"."last_name",
    "personnel"."id"
FROM "assignments"
JOIN "cases" ON "assignments"."case_id" = "cases"."id"
JOIN "personnel" ON "personnel"."id" = "assignments"."personnel_id"
WHERE "cases"."status" = 'Open';
