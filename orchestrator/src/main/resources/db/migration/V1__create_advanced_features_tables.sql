-- Sandbox Executions
CREATE TABLE IF NOT EXISTS sandbox_executions (
    execution_id VARCHAR(255) PRIMARY KEY,
    node_id VARCHAR(255),
    node_type VARCHAR(100),
    success BOOLEAN,
    inputs_json TEXT,
    outputs_json TEXT,
    reasoning_json TEXT,
    execution_time_ms BIGINT,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sandbox_node_id ON sandbox_executions(node_id);
CREATE INDEX idx_sandbox_created_at ON sandbox_executions(created_at);

-- Vector Stores
CREATE TABLE IF NOT EXISTS vector_stores (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vector Store Documents
CREATE TABLE IF NOT EXISTS vector_store_documents (
    id VARCHAR(255) PRIMARY KEY,
    store_id VARCHAR(255) NOT NULL,
    text TEXT NOT NULL,
    embedding_json TEXT,
    metadata_json TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (store_id) REFERENCES vector_stores(id) ON DELETE CASCADE
);

CREATE INDEX idx_documents_store_id ON vector_store_documents(store_id);

-- Execution Timeline Events
CREATE TABLE IF NOT EXISTS execution_timeline_events (
    id VARCHAR(255) PRIMARY KEY,
    execution_id VARCHAR(255) NOT NULL,
    node_id VARCHAR(255),
    event_type VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    data_json TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_timeline_execution_id ON execution_timeline_events(execution_id);
CREATE INDEX idx_timeline_timestamp ON execution_timeline_events(timestamp);

-- Memory Snapshots
CREATE TABLE IF NOT EXISTS memory_snapshots (
    id VARCHAR(255) PRIMARY KEY,
    execution_id VARCHAR(255) NOT NULL,
    node_id VARCHAR(255),
    timestamp TIMESTAMP NOT NULL,
    state_json TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_snapshots_execution_id ON memory_snapshots(execution_id);
CREATE INDEX idx_snapshots_node_id ON memory_snapshots(node_id);

