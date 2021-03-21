create database www;

CREATE TABLE www.nginx_access_log_consumer (
    `remote` String,
    `server` String,
    `user` String,
    `method` String,
    `path` String,
    `code` UInt16,
    `size` UInt64,
    `referer` String,
    `agent` String,
    `http_x_forwarded_for` String,
    `country` LowCardinality(String),
    `country_name` LowCardinality(String),
    `country_code` LowCardinality(String),
    `province` String,
    `province_name` String,
    `province_code` String,
    `city` String,
    `city_name` String,
    `postal` String
) ENGINE = Kafka SETTINGS kafka_broker_list = 'kafka-broker:9092',
kafka_topic_list = 'nginx_access',
kafka_group_name = 'nginx_access.clickhouse',
kafka_format = 'JSONEachRow',
kafka_num_consumers = 1;

CREATE TABLE www.nginx_access (
    `access_time` DateTime,
    `remote` String,
    `server` String,
    `user` String,
    `method` String,
    `path` String,
    `code` UInt16,
    `size` UInt64,
    `referer` String,
    `agent` String,
    `http_x_forwarded_for` String,
    `country` LowCardinality(String),
    `country_name` LowCardinality(String),
    `country_code` LowCardinality(String),
    `province` String,
    `province_name` String,
    `province_code` String,
    `city` String,
    `city_name` String,
    `postal` String
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
