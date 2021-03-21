create database www;

CREATE TABLE www.nginx_access_log_consumer (
    `agent` String,
    `code` UInt16,
    `http_x_forwarded_for` String,
    `method` String,
    `path` String,
    `referer` String,
    `remote` String,
    `server` String,
    `size` UInt64,
    `user` String
) ENGINE = Kafka SETTINGS kafka_broker_list = 'kafka-broker:9092',
kafka_topic_list = 'nginx_access',
kafka_group_name = 'nginx_access.clickhouse',
kafka_format = 'JSONEachRow',
kafka_num_consumers = 1;

CREATE TABLE www.nginx_access (
    `access_time` DateTime,
    `agent` String,
    `code` UInt16,
    `http_x_forwarded_for` String,
    `method` String,
    `path` String,
    `referer` String,
    `remote` String,
    `server` String,
    `size` UInt64,
    `user` String
) ENGINE = MergeTree()
ORDER BY
    (access_time, host) 
PARTITION BY toDate(access_time);

CREATE MATERIALIZED VIEW www.nginx_access_log TO www.nginx_access AS
SELECT
    *,
    _timestamp as access_time
FROM
    www.nginx_access_log_consumer;
