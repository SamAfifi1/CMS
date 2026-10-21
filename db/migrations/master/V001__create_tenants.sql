-- Master database: registry of tenants
CREATE TABLE tenants (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name              VARCHAR(100) NOT NULL UNIQUE,
    connection_string TEXT         NOT NULL,
    is_active         BOOLEAN      DEFAULT true,
    created_at        TIMESTAMP    DEFAULT NOW()
);
