-- Registers the tenants in cms_master (run against cms_master)
INSERT INTO tenants (id, name, connection_string) VALUES
('11111111-1111-1111-1111-111111111111', 'BluePeak Banking',       'Host=localhost;Database=cms_tenant_bluepeak;Username=postgres;Password=password'),
('22222222-2222-2222-2222-222222222222', 'Nexora Telecom',         'Host=localhost;Database=cms_tenant_nexora;Username=postgres;Password=password'),
('33333333-3333-3333-3333-333333333333', 'Evergreen Retail Group', 'Host=localhost;Database=cms_tenant_evergreen;Username=postgres;Password=password'),
('44444444-4444-4444-4444-444444444444', 'BrightPath Insurance',   'Host=localhost;Database=cms_tenant_brightpath;Username=postgres;Password=password')
ON CONFLICT (id) DO NOTHING;

