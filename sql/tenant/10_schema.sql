DROP TABLE IF EXISTS competition;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS player_score;

CREATE TABLE competition (
  id VARCHAR(255) NOT NULL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  title TEXT NOT NULL,
  finished_at BIGINT NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

CREATE TABLE player (
  id VARCHAR(255) NOT NULL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  display_name TEXT NOT NULL,
  is_disqualified BOOLEAN NOT NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

CREATE TABLE player_score (
  id VARCHAR(255) NOT NULL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  player_id VARCHAR(255) NOT NULL,
  competition_id VARCHAR(255) NOT NULL,
  score BIGINT NOT NULL,
  row_num BIGINT NOT NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

CREATE INDEX idx_id ON competition(id)
CREATE INDEX idx_tenant_id_created_at ON competition(tenant_id, created_at DESC)
CREATE INDEX idx_id ON player(id)
CREATE INDEX idx_tenant_id_created_at ON player(tenant_id, created_at DESC)
CREATE INDEX idx_tenant_id_competition_id ON player_score(tenant_id, competition_id)
CREATE INDEX idx_tenant_id_row_num ON player_score(tenant_id, row_num DESC)
CREATE INDEX idx_competition_id_row_num ON player_score(competition_id, row_num DESC)