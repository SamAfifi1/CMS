-- Registers the three tenants in cms_master (run against cms_master)
INSERT INTO tenants (id, name, connection_string) VALUES 
('1', 'BluePeak Banking', 'Host=localhost;Database=cms_tenant_bluepeak;Username=postgres;Password=password'), 
('2', 'Nexora Telecom', 'Host=localhost;Database=cms_tenant_nexora;Username=postgres;Password=password'), 
('3', 'Evergreen Retail Group', 'Host=localhost;Database=cms_tenant_evergreen;Username=postgres;Password=password'), 
('4', 'BrightPath Insurance', 'Host=localhost;Database=cms_tenant_brightpath;Username=postgres;Password=password'), 
 ON CONFLICT (id) DO NOTHING;
