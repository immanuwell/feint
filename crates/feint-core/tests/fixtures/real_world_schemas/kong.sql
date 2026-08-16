--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: batch_delete_expired_rows(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.batch_delete_expired_rows() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          EXECUTE FORMAT('WITH rows AS (SELECT ctid FROM %s WHERE %s < CURRENT_TIMESTAMP AT TIME ZONE ''UTC'' ORDER BY %s LIMIT 2 FOR UPDATE SKIP LOCKED) DELETE FROM %s WHERE ctid IN (TABLE rows)', TG_TABLE_NAME, TG_ARGV[0], TG_ARGV[0], TG_TABLE_NAME);
          RETURN NULL;
        END;
      $$;


--
-- Name: sync_tags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_tags() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF (TG_OP = 'TRUNCATE') THEN
            DELETE FROM tags WHERE entity_name = TG_TABLE_NAME;
            RETURN NULL;
          ELSIF (TG_OP = 'DELETE') THEN
            DELETE FROM tags WHERE entity_id = OLD.id;
            RETURN OLD;
          ELSE

          -- Triggered by INSERT/UPDATE
          -- Do an upsert on the tags table
          -- So we don't need to migrate pre 1.1 entities
          INSERT INTO tags VALUES (NEW.id, TG_TABLE_NAME, NEW.tags)
          ON CONFLICT (entity_id) DO UPDATE
                  SET tags=EXCLUDED.tags;
          END IF;
          RETURN NEW;
        END;
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acls (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    consumer_id uuid,
    "group" text,
    cache_key text,
    tags text[],
    ws_id uuid
);


--
-- Name: acme_storage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acme_storage (
    id uuid NOT NULL,
    key text,
    value text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


--
-- Name: basicauth_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.basicauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    consumer_id uuid,
    username text,
    password text,
    tags text[],
    ws_id uuid
);


--
-- Name: ca_certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ca_certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    cert text NOT NULL,
    tags text[],
    cert_digest text NOT NULL,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text)
);


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    cert text,
    key text,
    tags text[],
    ws_id uuid,
    cert_alt text,
    key_alt text,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text)
);


--
-- Name: cluster_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cluster_events (
    id uuid NOT NULL,
    node_id uuid NOT NULL,
    at timestamp with time zone NOT NULL,
    nbf timestamp with time zone,
    expire_at timestamp with time zone NOT NULL,
    channel text,
    data text
);


--
-- Name: clustering_data_planes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clustering_data_planes (
    id uuid NOT NULL,
    hostname text NOT NULL,
    ip text NOT NULL,
    last_seen timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    config_hash text NOT NULL,
    ttl timestamp with time zone,
    version text,
    sync_status text DEFAULT 'unknown'::text NOT NULL,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    labels jsonb,
    cert_details jsonb,
    rpc_capabilities text[]
);


--
-- Name: clustering_rpc_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clustering_rpc_requests (
    id bigint NOT NULL,
    node_id uuid NOT NULL,
    reply_to uuid NOT NULL,
    ttl timestamp with time zone NOT NULL,
    payload json NOT NULL
);


--
-- Name: clustering_rpc_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clustering_rpc_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clustering_rpc_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clustering_rpc_requests_id_seq OWNED BY public.clustering_rpc_requests.id;


--
-- Name: clustering_sync_delta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clustering_sync_delta (
    version integer NOT NULL,
    type text NOT NULL,
    pk json NOT NULL,
    ws_id uuid NOT NULL,
    entity json
);


--
-- Name: clustering_sync_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clustering_sync_version (
    version integer NOT NULL
);


--
-- Name: clustering_sync_version_version_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clustering_sync_version_version_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clustering_sync_version_version_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clustering_sync_version_version_seq OWNED BY public.clustering_sync_version.version;


--
-- Name: consumers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consumers (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    username text,
    custom_id text,
    tags text[],
    ws_id uuid,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text)
);


--
-- Name: filter_chains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filter_chains (
    id uuid NOT NULL,
    name text,
    enabled boolean DEFAULT true,
    route_id uuid,
    service_id uuid,
    ws_id uuid,
    cache_key text,
    filters jsonb[],
    tags text[],
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: hmacauth_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hmacauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    consumer_id uuid,
    username text,
    secret text,
    tags text[],
    ws_id uuid
);


--
-- Name: jwt_secrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jwt_secrets (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    consumer_id uuid,
    key text,
    secret text,
    algorithm text,
    rsa_public_key text,
    tags text[],
    ws_id uuid
);


--
-- Name: key_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.key_sets (
    id uuid NOT NULL,
    name text,
    tags text[],
    ws_id uuid,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: keyauth_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.keyauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    consumer_id uuid,
    key text,
    tags text[],
    ttl timestamp with time zone,
    ws_id uuid
);


--
-- Name: keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.keys (
    id uuid NOT NULL,
    set_id uuid,
    name text,
    cache_key text,
    ws_id uuid,
    kid text,
    jwk text,
    pem jsonb,
    tags text[],
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locks (
    key text NOT NULL,
    owner text,
    ttl timestamp with time zone
);


--
-- Name: oauth2_authorization_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth2_authorization_codes (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    credential_id uuid,
    service_id uuid,
    code text,
    authenticated_userid text,
    scope text,
    ttl timestamp with time zone,
    challenge text,
    challenge_method text,
    ws_id uuid,
    plugin_id uuid
);


--
-- Name: oauth2_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth2_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    name text,
    consumer_id uuid,
    client_id text,
    client_secret text,
    redirect_uris text[],
    tags text[],
    client_type text,
    hash_secret boolean,
    ws_id uuid
);


--
-- Name: oauth2_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth2_tokens (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    credential_id uuid,
    service_id uuid,
    access_token text,
    refresh_token text,
    token_type text,
    expires_in integer,
    authenticated_userid text,
    scope text,
    ttl timestamp with time zone,
    ws_id uuid
);


--
-- Name: parameters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parameters (
    key text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: plugins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plugins (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    name text NOT NULL,
    consumer_id uuid,
    service_id uuid,
    route_id uuid,
    config jsonb NOT NULL,
    enabled boolean NOT NULL,
    cache_key text,
    protocols text[],
    tags text[],
    ws_id uuid,
    instance_name text,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text)
);


--
-- Name: ratelimiting_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer,
    ttl timestamp with time zone
);


--
-- Name: response_ratelimiting_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer
);


--
-- Name: routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routes (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name text,
    service_id uuid,
    protocols text[],
    methods text[],
    hosts text[],
    paths text[],
    snis text[],
    sources jsonb[],
    destinations jsonb[],
    regex_priority bigint,
    strip_path boolean,
    preserve_host boolean,
    tags text[],
    https_redirect_status_code integer,
    headers jsonb,
    path_handling text DEFAULT 'v0'::text,
    ws_id uuid,
    request_buffering boolean,
    response_buffering boolean,
    expression text,
    priority bigint
);


--
-- Name: schema_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_meta (
    key text NOT NULL,
    subsystem text NOT NULL,
    last_executed text,
    executed text[],
    pending text[]
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name text,
    retries bigint,
    protocol text,
    host text,
    port bigint,
    path text,
    connect_timeout bigint,
    write_timeout bigint,
    read_timeout bigint,
    tags text[],
    client_certificate_id uuid,
    tls_verify boolean,
    tls_verify_depth smallint,
    ca_certificates uuid[],
    ws_id uuid,
    enabled boolean DEFAULT true
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id uuid NOT NULL,
    session_id text,
    expires integer,
    data text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


--
-- Name: sm_vaults; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sm_vaults (
    id uuid NOT NULL,
    ws_id uuid,
    prefix text,
    name text NOT NULL,
    description text,
    config jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    updated_at timestamp with time zone,
    tags text[]
);


--
-- Name: snis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.snis (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    name text NOT NULL,
    certificate_id uuid,
    tags text[],
    ws_id uuid,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text)
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    entity_id uuid NOT NULL,
    entity_name text,
    tags text[]
);


--
-- Name: targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.targets (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(3) AT TIME ZONE 'UTC'::text),
    upstream_id uuid,
    target text NOT NULL,
    weight integer NOT NULL,
    tags text[],
    ws_id uuid,
    cache_key text,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(3) AT TIME ZONE 'UTC'::text)
);


--
-- Name: upstreams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upstreams (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(3) AT TIME ZONE 'UTC'::text),
    name text,
    hash_on text,
    hash_fallback text,
    hash_on_header text,
    hash_fallback_header text,
    hash_on_cookie text,
    hash_on_cookie_path text,
    slots integer NOT NULL,
    healthchecks jsonb,
    tags text[],
    algorithm text,
    host_header text,
    client_certificate_id uuid,
    ws_id uuid,
    hash_on_query_arg text,
    hash_fallback_query_arg text,
    hash_on_uri_capture text,
    hash_fallback_uri_capture text,
    use_srv_name boolean DEFAULT false,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text)
);


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspaces (
    id uuid NOT NULL,
    name text,
    comment text,
    created_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text),
    meta jsonb,
    config jsonb,
    updated_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'::text)
);


--
-- Name: clustering_rpc_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clustering_rpc_requests ALTER COLUMN id SET DEFAULT nextval('public.clustering_rpc_requests_id_seq'::regclass);


--
-- Name: clustering_sync_version version; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clustering_sync_version ALTER COLUMN version SET DEFAULT nextval('public.clustering_sync_version_version_seq'::regclass);


--
-- Name: acls acls_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_cache_key_key UNIQUE (cache_key);


--
-- Name: acls acls_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: acls acls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_pkey PRIMARY KEY (id);


--
-- Name: acme_storage acme_storage_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acme_storage
    ADD CONSTRAINT acme_storage_key_key UNIQUE (key);


--
-- Name: acme_storage acme_storage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acme_storage
    ADD CONSTRAINT acme_storage_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials basicauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: basicauth_credentials basicauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials basicauth_credentials_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: ca_certificates ca_certificates_cert_digest_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ca_certificates
    ADD CONSTRAINT ca_certificates_cert_digest_key UNIQUE (cert_digest);


--
-- Name: ca_certificates ca_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ca_certificates
    ADD CONSTRAINT ca_certificates_pkey PRIMARY KEY (id);


--
-- Name: certificates certificates_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: cluster_events cluster_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cluster_events
    ADD CONSTRAINT cluster_events_pkey PRIMARY KEY (id);


--
-- Name: clustering_data_planes clustering_data_planes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clustering_data_planes
    ADD CONSTRAINT clustering_data_planes_pkey PRIMARY KEY (id);


--
-- Name: clustering_rpc_requests clustering_rpc_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clustering_rpc_requests
    ADD CONSTRAINT clustering_rpc_requests_pkey PRIMARY KEY (id);


--
-- Name: clustering_sync_version clustering_sync_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clustering_sync_version
    ADD CONSTRAINT clustering_sync_version_pkey PRIMARY KEY (version);


--
-- Name: consumers consumers_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: consumers consumers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_pkey PRIMARY KEY (id);


--
-- Name: consumers consumers_ws_id_custom_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_custom_id_unique UNIQUE (ws_id, custom_id);


--
-- Name: consumers consumers_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: filter_chains filter_chains_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_cache_key_key UNIQUE (cache_key);


--
-- Name: filter_chains filter_chains_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_name_key UNIQUE (name);


--
-- Name: filter_chains filter_chains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_pkey PRIMARY KEY (id);


--
-- Name: hmacauth_credentials hmacauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: hmacauth_credentials hmacauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: hmacauth_credentials hmacauth_credentials_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: jwt_secrets jwt_secrets_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: jwt_secrets jwt_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_pkey PRIMARY KEY (id);


--
-- Name: jwt_secrets jwt_secrets_ws_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_ws_id_key_unique UNIQUE (ws_id, key);


--
-- Name: key_sets key_sets_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_sets
    ADD CONSTRAINT key_sets_name_key UNIQUE (name);


--
-- Name: key_sets key_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_sets
    ADD CONSTRAINT key_sets_pkey PRIMARY KEY (id);


--
-- Name: keyauth_credentials keyauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: keyauth_credentials keyauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: keyauth_credentials keyauth_credentials_ws_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_ws_id_key_unique UNIQUE (ws_id, key);


--
-- Name: keys keys_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_cache_key_key UNIQUE (cache_key);


--
-- Name: keys keys_kid_set_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_kid_set_id_key UNIQUE (kid, set_id);


--
-- Name: keys keys_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_name_key UNIQUE (name);


--
-- Name: keys keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_pkey PRIMARY KEY (id);


--
-- Name: locks locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locks
    ADD CONSTRAINT locks_pkey PRIMARY KEY (key);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_ws_id_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_ws_id_code_unique UNIQUE (ws_id, code);


--
-- Name: oauth2_credentials oauth2_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_credentials oauth2_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_pkey PRIMARY KEY (id);


--
-- Name: oauth2_credentials oauth2_credentials_ws_id_client_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_ws_id_client_id_unique UNIQUE (ws_id, client_id);


--
-- Name: oauth2_tokens oauth2_tokens_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_tokens oauth2_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_access_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_access_token_unique UNIQUE (ws_id, access_token);


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_refresh_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_refresh_token_unique UNIQUE (ws_id, refresh_token);


--
-- Name: parameters parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_pkey PRIMARY KEY (key);


--
-- Name: plugins plugins_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_cache_key_key UNIQUE (cache_key);


--
-- Name: plugins plugins_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: plugins plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_pkey PRIMARY KEY (id);


--
-- Name: plugins plugins_ws_id_instance_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_ws_id_instance_name_unique UNIQUE (ws_id, instance_name);


--
-- Name: ratelimiting_metrics ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ratelimiting_metrics
    ADD CONSTRAINT ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: response_ratelimiting_metrics response_ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_ratelimiting_metrics
    ADD CONSTRAINT response_ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: routes routes_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: routes routes_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: schema_meta schema_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_meta
    ADD CONSTRAINT schema_meta_pkey PRIMARY KEY (key, subsystem);


--
-- Name: services services_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: services services_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);


--
-- Name: sm_vaults sm_vaults_id_ws_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_id_ws_id_key UNIQUE (id, ws_id);


--
-- Name: sm_vaults sm_vaults_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_pkey PRIMARY KEY (id);


--
-- Name: sm_vaults sm_vaults_prefix_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_prefix_key UNIQUE (prefix);


--
-- Name: sm_vaults sm_vaults_prefix_ws_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_prefix_ws_id_key UNIQUE (prefix, ws_id);


--
-- Name: snis snis_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: snis snis_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_name_key UNIQUE (name);


--
-- Name: snis snis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (entity_id);


--
-- Name: targets targets_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_cache_key_key UNIQUE (cache_key);


--
-- Name: targets targets_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: targets targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: upstreams upstreams_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: upstreams upstreams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_pkey PRIMARY KEY (id);


--
-- Name: upstreams upstreams_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: workspaces workspaces_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_name_key UNIQUE (name);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: acls_consumer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX acls_consumer_id_idx ON public.acls USING btree (consumer_id);


--
-- Name: acls_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX acls_group_idx ON public.acls USING btree ("group");


--
-- Name: acls_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX acls_tags_idex_tags_idx ON public.acls USING gin (tags);


--
-- Name: acme_storage_ttl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX acme_storage_ttl_idx ON public.acme_storage USING btree (ttl);


--
-- Name: basicauth_consumer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX basicauth_consumer_id_idx ON public.basicauth_credentials USING btree (consumer_id);


--
-- Name: basicauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX basicauth_tags_idex_tags_idx ON public.basicauth_credentials USING gin (tags);


--
-- Name: certificates_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX certificates_tags_idx ON public.certificates USING gin (tags);


--
-- Name: cluster_events_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cluster_events_at_idx ON public.cluster_events USING btree (at);


--
-- Name: cluster_events_channel_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cluster_events_channel_idx ON public.cluster_events USING btree (channel);


--
-- Name: cluster_events_expire_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cluster_events_expire_at_idx ON public.cluster_events USING btree (expire_at);


--
-- Name: clustering_data_planes_ttl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX clustering_data_planes_ttl_idx ON public.clustering_data_planes USING btree (ttl);


--
-- Name: clustering_rpc_requests_node_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX clustering_rpc_requests_node_id_idx ON public.clustering_rpc_requests USING btree (node_id);


--
-- Name: clustering_sync_delta_version_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX clustering_sync_delta_version_idx ON public.clustering_sync_delta USING btree (version);


--
-- Name: consumers_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consumers_tags_idx ON public.consumers USING gin (tags);


--
-- Name: consumers_username_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consumers_username_idx ON public.consumers USING btree (lower(username));


--
-- Name: filter_chains_cache_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX filter_chains_cache_key_idx ON public.filter_chains USING btree (cache_key);


--
-- Name: filter_chains_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX filter_chains_name_idx ON public.filter_chains USING btree (name);


--
-- Name: filter_chains_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX filter_chains_tags_idx ON public.filter_chains USING gin (tags);


--
-- Name: hmacauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hmacauth_credentials_consumer_id_idx ON public.hmacauth_credentials USING btree (consumer_id);


--
-- Name: hmacauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hmacauth_tags_idex_tags_idx ON public.hmacauth_credentials USING gin (tags);


--
-- Name: jwt_secrets_consumer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jwt_secrets_consumer_id_idx ON public.jwt_secrets USING btree (consumer_id);


--
-- Name: jwt_secrets_secret_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jwt_secrets_secret_idx ON public.jwt_secrets USING btree (secret);


--
-- Name: jwtsecrets_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jwtsecrets_tags_idex_tags_idx ON public.jwt_secrets USING gin (tags);


--
-- Name: key_sets_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX key_sets_tags_idx ON public.key_sets USING gin (tags);


--
-- Name: keyauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX keyauth_credentials_consumer_id_idx ON public.keyauth_credentials USING btree (consumer_id);


--
-- Name: keyauth_credentials_ttl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX keyauth_credentials_ttl_idx ON public.keyauth_credentials USING btree (ttl);


--
-- Name: keyauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX keyauth_tags_idex_tags_idx ON public.keyauth_credentials USING gin (tags);


--
-- Name: keys_fkey_key_sets; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX keys_fkey_key_sets ON public.keys USING btree (set_id);


--
-- Name: keys_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX keys_tags_idx ON public.keys USING gin (tags);


--
-- Name: locks_ttl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locks_ttl_idx ON public.locks USING btree (ttl);


--
-- Name: oauth2_authorization_codes_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_authorization_codes_authenticated_userid_idx ON public.oauth2_authorization_codes USING btree (authenticated_userid);


--
-- Name: oauth2_authorization_codes_ttl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_authorization_codes_ttl_idx ON public.oauth2_authorization_codes USING btree (ttl);


--
-- Name: oauth2_authorization_credential_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_authorization_credential_id_idx ON public.oauth2_authorization_codes USING btree (credential_id);


--
-- Name: oauth2_authorization_service_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_authorization_service_id_idx ON public.oauth2_authorization_codes USING btree (service_id);


--
-- Name: oauth2_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_credentials_consumer_id_idx ON public.oauth2_credentials USING btree (consumer_id);


--
-- Name: oauth2_credentials_secret_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_credentials_secret_idx ON public.oauth2_credentials USING btree (client_secret);


--
-- Name: oauth2_credentials_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_credentials_tags_idex_tags_idx ON public.oauth2_credentials USING gin (tags);


--
-- Name: oauth2_tokens_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_tokens_authenticated_userid_idx ON public.oauth2_tokens USING btree (authenticated_userid);


--
-- Name: oauth2_tokens_credential_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_tokens_credential_id_idx ON public.oauth2_tokens USING btree (credential_id);


--
-- Name: oauth2_tokens_service_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_tokens_service_id_idx ON public.oauth2_tokens USING btree (service_id);


--
-- Name: oauth2_tokens_ttl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oauth2_tokens_ttl_idx ON public.oauth2_tokens USING btree (ttl);


--
-- Name: plugins_consumer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plugins_consumer_id_idx ON public.plugins USING btree (consumer_id);


--
-- Name: plugins_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plugins_name_idx ON public.plugins USING btree (name);


--
-- Name: plugins_route_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plugins_route_id_idx ON public.plugins USING btree (route_id);


--
-- Name: plugins_service_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plugins_service_id_idx ON public.plugins USING btree (service_id);


--
-- Name: plugins_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX plugins_tags_idx ON public.plugins USING gin (tags);


--
-- Name: ratelimiting_metrics_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ratelimiting_metrics_idx ON public.ratelimiting_metrics USING btree (service_id, route_id, period_date, period);


--
-- Name: ratelimiting_metrics_ttl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ratelimiting_metrics_ttl_idx ON public.ratelimiting_metrics USING btree (ttl);


--
-- Name: routes_service_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX routes_service_id_idx ON public.routes USING btree (service_id);


--
-- Name: routes_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX routes_tags_idx ON public.routes USING gin (tags);


--
-- Name: services_fkey_client_certificate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX services_fkey_client_certificate ON public.services USING btree (client_certificate_id);


--
-- Name: services_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX services_tags_idx ON public.services USING gin (tags);


--
-- Name: session_sessions_expires_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX session_sessions_expires_idx ON public.sessions USING btree (expires);


--
-- Name: sessions_ttl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_ttl_idx ON public.sessions USING btree (ttl);


--
-- Name: sm_vaults_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sm_vaults_tags_idx ON public.sm_vaults USING gin (tags);


--
-- Name: snis_certificate_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snis_certificate_id_idx ON public.snis USING btree (certificate_id);


--
-- Name: snis_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX snis_tags_idx ON public.snis USING gin (tags);


--
-- Name: tags_entity_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tags_entity_name_idx ON public.tags USING btree (entity_name);


--
-- Name: tags_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tags_tags_idx ON public.tags USING gin (tags);


--
-- Name: targets_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX targets_tags_idx ON public.targets USING gin (tags);


--
-- Name: targets_target_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX targets_target_idx ON public.targets USING btree (target);


--
-- Name: targets_upstream_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX targets_upstream_id_idx ON public.targets USING btree (upstream_id);


--
-- Name: upstreams_fkey_client_certificate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upstreams_fkey_client_certificate ON public.upstreams USING btree (client_certificate_id);


--
-- Name: upstreams_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX upstreams_tags_idx ON public.upstreams USING gin (tags);


--
-- Name: acls acls_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER acls_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.acls FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: acme_storage acme_storage_ttl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER acme_storage_ttl_trigger AFTER INSERT ON public.acme_storage FOR EACH STATEMENT EXECUTE FUNCTION public.batch_delete_expired_rows('ttl');


--
-- Name: basicauth_credentials basicauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER basicauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.basicauth_credentials FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: ca_certificates ca_certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ca_certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.ca_certificates FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: certificates certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.certificates FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: cluster_events cluster_events_ttl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cluster_events_ttl_trigger AFTER INSERT ON public.cluster_events FOR EACH STATEMENT EXECUTE FUNCTION public.batch_delete_expired_rows('expire_at');


--
-- Name: clustering_data_planes clustering_data_planes_ttl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER clustering_data_planes_ttl_trigger AFTER INSERT ON public.clustering_data_planes FOR EACH STATEMENT EXECUTE FUNCTION public.batch_delete_expired_rows('ttl');


--
-- Name: consumers consumers_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER consumers_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.consumers FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: filter_chains filter_chains_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER filter_chains_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.filter_chains FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: hmacauth_credentials hmacauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER hmacauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.hmacauth_credentials FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: jwt_secrets jwtsecrets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER jwtsecrets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.jwt_secrets FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: key_sets key_sets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER key_sets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.key_sets FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: keyauth_credentials keyauth_credentials_ttl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER keyauth_credentials_ttl_trigger AFTER INSERT ON public.keyauth_credentials FOR EACH STATEMENT EXECUTE FUNCTION public.batch_delete_expired_rows('ttl');


--
-- Name: keyauth_credentials keyauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER keyauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.keyauth_credentials FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: keys keys_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER keys_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.keys FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_ttl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oauth2_authorization_codes_ttl_trigger AFTER INSERT ON public.oauth2_authorization_codes FOR EACH STATEMENT EXECUTE FUNCTION public.batch_delete_expired_rows('ttl');


--
-- Name: oauth2_credentials oauth2_credentials_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oauth2_credentials_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.oauth2_credentials FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: oauth2_tokens oauth2_tokens_ttl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oauth2_tokens_ttl_trigger AFTER INSERT ON public.oauth2_tokens FOR EACH STATEMENT EXECUTE FUNCTION public.batch_delete_expired_rows('ttl');


--
-- Name: plugins plugins_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER plugins_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.plugins FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: ratelimiting_metrics ratelimiting_metrics_ttl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ratelimiting_metrics_ttl_trigger AFTER INSERT ON public.ratelimiting_metrics FOR EACH STATEMENT EXECUTE FUNCTION public.batch_delete_expired_rows('ttl');


--
-- Name: routes routes_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER routes_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.routes FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: services services_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER services_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.services FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: sessions sessions_ttl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sessions_ttl_trigger AFTER INSERT ON public.sessions FOR EACH STATEMENT EXECUTE FUNCTION public.batch_delete_expired_rows('ttl');


--
-- Name: sm_vaults sm_vaults_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER sm_vaults_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.sm_vaults FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: snis snis_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER snis_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.snis FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: targets targets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER targets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.targets FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: upstreams upstreams_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER upstreams_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.upstreams FOR EACH ROW EXECUTE FUNCTION public.sync_tags();


--
-- Name: acls acls_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: acls acls_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: basicauth_credentials basicauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: basicauth_credentials basicauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: certificates certificates_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: clustering_sync_delta clustering_sync_delta_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clustering_sync_delta
    ADD CONSTRAINT clustering_sync_delta_version_fkey FOREIGN KEY (version) REFERENCES public.clustering_sync_version(version) ON DELETE CASCADE;


--
-- Name: consumers consumers_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: filter_chains filter_chains_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id) ON DELETE CASCADE;


--
-- Name: filter_chains filter_chains_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


--
-- Name: filter_chains filter_chains_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: hmacauth_credentials hmacauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: hmacauth_credentials hmacauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: jwt_secrets jwt_secrets_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: jwt_secrets jwt_secrets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: key_sets key_sets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_sets
    ADD CONSTRAINT key_sets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: keyauth_credentials keyauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: keyauth_credentials keyauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: keys keys_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.key_sets(id) ON DELETE CASCADE;


--
-- Name: keys keys_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_credential_id_fkey FOREIGN KEY (credential_id, ws_id) REFERENCES public.oauth2_credentials(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_plugin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_plugin_id_fkey FOREIGN KEY (plugin_id) REFERENCES public.plugins(id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes oauth2_authorization_codes_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_credentials oauth2_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_credentials oauth2_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_tokens oauth2_tokens_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_credential_id_fkey FOREIGN KEY (credential_id, ws_id) REFERENCES public.oauth2_credentials(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens oauth2_tokens_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens oauth2_tokens_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: plugins plugins_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_route_id_fkey FOREIGN KEY (route_id, ws_id) REFERENCES public.routes(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins plugins_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: routes routes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id);


--
-- Name: routes routes_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: services services_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_client_certificate_id_fkey FOREIGN KEY (client_certificate_id, ws_id) REFERENCES public.certificates(id, ws_id);


--
-- Name: services services_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: sm_vaults sm_vaults_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: snis snis_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_certificate_id_fkey FOREIGN KEY (certificate_id, ws_id) REFERENCES public.certificates(id, ws_id);


--
-- Name: snis snis_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: targets targets_upstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_upstream_id_fkey FOREIGN KEY (upstream_id, ws_id) REFERENCES public.upstreams(id, ws_id) ON DELETE CASCADE;


--
-- Name: targets targets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: upstreams upstreams_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_client_certificate_id_fkey FOREIGN KEY (client_certificate_id) REFERENCES public.certificates(id);


--
-- Name: upstreams upstreams_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- PostgreSQL database dump complete
--


