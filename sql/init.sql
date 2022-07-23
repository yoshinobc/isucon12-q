DELETE FROM tenant WHERE id > 100;
DELETE FROM visit_history WHERE created_at >= '1654041600';
UPDATE id_generator SET id=2678400000 WHERE stub='a';
ALTER TABLE id_generator AUTO_INCREMENT=2678400000;
CREATE INDEX  `idx_tenant_competition` ON visit_history (`tenant_id`, `competition_id`);
CREATE INDEX  `idx_tenant_id_player_id` ON visit_history (`tenant_id`, `player_id`);
-- CREATE INDEX  `idx_competition_id_player_id` ON visit_history (`competition_id`, `player_id`);
