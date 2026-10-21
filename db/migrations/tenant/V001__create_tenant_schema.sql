-- Tenant database schema (identical for every tenant)

CREATE TABLE consumers (
    id                 UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email              VARCHAR(255) NOT NULL UNIQUE,
    first_name         VARCHAR(100) NOT NULL,
    last_name          VARCHAR(100) NOT NULL,
    phone_number       VARCHAR(50),
    customer_reference VARCHAR(100),
    is_active          BOOLEAN      DEFAULT true,
    registered_at      TIMESTAMP    DEFAULT NOW(),
    last_contact       TIMESTAMP
);

CREATE TABLE roles (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name          VARCHAR(50) NOT NULL UNIQUE,
    access_level  INTEGER     NOT NULL,
    description   TEXT,
    is_managerial BOOLEAN     DEFAULT false,
    is_active     BOOLEAN     DEFAULT true
);

CREATE TABLE staff (
    id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id    UUID         NOT NULL REFERENCES roles(id),
    email      VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    is_active  BOOLEAN      DEFAULT true,
    created_at TIMESTAMP    DEFAULT NOW(),
    last_login TIMESTAMP
);

CREATE TABLE categories (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name              VARCHAR(100) NOT NULL UNIQUE,
    description       TEXT,
    is_active         BOOLEAN      DEFAULT true,
    sort_order        INTEGER      DEFAULT 0,
    industry_specific VARCHAR(50)
);

CREATE TABLE complaints (
    id               UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    title            VARCHAR(200) NOT NULL,
    description      TEXT,
    status           VARCHAR(50)  NOT NULL DEFAULT 'New',
    priority         VARCHAR(50)  NOT NULL DEFAULT 'Medium',
    consumer_id      UUID         NOT NULL REFERENCES consumers(id),
    category_id      UUID         NOT NULL REFERENCES categories(id),
    created_by       UUID         REFERENCES staff(id),  -- NULL when consumer self-serves
    created_at       TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP,
    resolved_at      TIMESTAMP,
    closed_at        TIMESTAMP,
    resolution_notes TEXT
);

CREATE TABLE assignments (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id    UUID        NOT NULL REFERENCES complaints(id),
    assigned_to     UUID        NOT NULL REFERENCES staff(id),
    assigned_by     UUID        NOT NULL REFERENCES staff(id),
    assignment_type VARCHAR(50) NOT NULL,
    assigned_at     TIMESTAMP   NOT NULL DEFAULT NOW(),
    notes           TEXT
);

CREATE TABLE complaint_comments (
    id                  UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id        UUID      NOT NULL REFERENCES complaints(id),
    staff_id            UUID      NOT NULL REFERENCES staff(id),
    content             TEXT      NOT NULL,
    is_internal         BOOLEAN   DEFAULT false,
    visible_to_consumer BOOLEAN   DEFAULT true,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE communication_logs (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id     UUID        NOT NULL REFERENCES complaints(id),
    consumer_id      UUID        NOT NULL REFERENCES consumers(id),
    staff_id         UUID        NOT NULL REFERENCES staff(id),
    channel          VARCHAR(50) NOT NULL,
    summary          TEXT,
    duration_seconds INTEGER,
    logged_at        TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE TABLE notifications (
    id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id   UUID         NOT NULL,  -- consumers.id or staff.id, see recipient_type
    recipient_type VARCHAR(50)  NOT NULL,
    type           VARCHAR(100) NOT NULL,
    title          VARCHAR(200) NOT NULL,
    message        TEXT         NOT NULL,
    channel        VARCHAR(50)  NOT NULL,
    is_sent        BOOLEAN      DEFAULT false,
    is_read        BOOLEAN      DEFAULT false,
    created_at     TIMESTAMP    NOT NULL DEFAULT NOW(),
    sent_at        TIMESTAMP,
    read_at        TIMESTAMP
);

CREATE TABLE reports (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    report_type  VARCHAR(100) NOT NULL,
    file_path    VARCHAR(500) NOT NULL,
    parameters   JSON,
    generated_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE report_role_access (
    report_id  UUID    NOT NULL REFERENCES reports(id),
    role_id    UUID    NOT NULL REFERENCES roles(id),
    can_view   BOOLEAN DEFAULT true,
    can_export BOOLEAN DEFAULT false
);

CREATE TABLE audit_logs (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(100) NOT NULL,
    entity_id   UUID         NOT NULL,
    action      VARCHAR(100) NOT NULL,
    staff_id    UUID         REFERENCES staff(id),      -- actor, nullable
    consumer_id UUID         REFERENCES consumers(id),  -- actor, nullable
    changes     TEXT,
    logged_at   TIMESTAMP    NOT NULL DEFAULT NOW()
);
