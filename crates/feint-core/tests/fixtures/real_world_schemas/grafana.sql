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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alert; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert (
    id integer NOT NULL,
    version bigint NOT NULL,
    dashboard_id bigint NOT NULL,
    panel_id bigint NOT NULL,
    org_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    message text NOT NULL,
    state character varying(190) NOT NULL,
    settings text NOT NULL,
    frequency bigint NOT NULL,
    handler bigint NOT NULL,
    severity text NOT NULL,
    silenced boolean NOT NULL,
    execution_error text NOT NULL,
    eval_data text,
    eval_date timestamp without time zone,
    new_state_date timestamp without time zone NOT NULL,
    state_changes integer NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    "for" bigint
);


--
-- Name: alert_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_configuration (
    id integer NOT NULL,
    alertmanager_configuration text NOT NULL,
    configuration_version character varying(3) NOT NULL,
    created_at integer NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    org_id bigint DEFAULT 0 NOT NULL,
    configuration_hash character varying(32) DEFAULT 'not-yet-calculated'::character varying NOT NULL
);


--
-- Name: alert_configuration_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_configuration_history (
    id integer NOT NULL,
    org_id bigint DEFAULT 0 NOT NULL,
    alertmanager_configuration text NOT NULL,
    configuration_hash character varying(32) DEFAULT 'not-yet-calculated'::character varying NOT NULL,
    configuration_version character varying(3) NOT NULL,
    created_at integer NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    last_applied integer DEFAULT 0 NOT NULL
);


--
-- Name: alert_configuration_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_configuration_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_configuration_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_configuration_history_id_seq OWNED BY public.alert_configuration_history.id;


--
-- Name: alert_configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_configuration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_configuration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_configuration_id_seq OWNED BY public.alert_configuration.id;


--
-- Name: alert_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_id_seq OWNED BY public.alert.id;


--
-- Name: alert_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_image (
    id integer NOT NULL,
    token character varying(190) NOT NULL,
    path character varying(190) NOT NULL,
    url character varying(2048) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: alert_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_image_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_image_id_seq OWNED BY public.alert_image.id;


--
-- Name: alert_instance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_instance (
    rule_org_id bigint NOT NULL,
    rule_uid character varying(40) DEFAULT 0 NOT NULL,
    labels text NOT NULL,
    labels_hash character varying(190) NOT NULL,
    current_state character varying(190) NOT NULL,
    current_state_since bigint NOT NULL,
    last_eval_time bigint NOT NULL,
    current_state_end bigint DEFAULT 0 NOT NULL,
    current_reason character varying(190),
    result_fingerprint character varying(16),
    resolved_at bigint,
    last_sent_at bigint,
    fired_at bigint,
    annotations text,
    evaluation_duration_ns bigint,
    last_error character varying(1000),
    last_result text
);


--
-- Name: alert_notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_notification (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    name character varying(190) NOT NULL,
    type character varying(255) NOT NULL,
    settings text NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    frequency bigint,
    send_reminder boolean DEFAULT false,
    disable_resolve_message boolean DEFAULT false NOT NULL,
    uid character varying(40),
    secure_settings text
);


--
-- Name: alert_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_notification_id_seq OWNED BY public.alert_notification.id;


--
-- Name: alert_notification_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_notification_state (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    alert_id bigint NOT NULL,
    notifier_id bigint NOT NULL,
    state character varying(50) NOT NULL,
    version bigint NOT NULL,
    updated_at bigint NOT NULL,
    alert_rule_state_updated_version bigint NOT NULL
);


--
-- Name: alert_notification_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_notification_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_notification_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_notification_state_id_seq OWNED BY public.alert_notification_state.id;


--
-- Name: alert_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_rule (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    title character varying(190) NOT NULL,
    condition character varying(190) NOT NULL,
    data text NOT NULL,
    updated timestamp without time zone NOT NULL,
    interval_seconds bigint DEFAULT 60 NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    uid character varying(40) DEFAULT 0 NOT NULL,
    namespace_uid character varying(40) NOT NULL COLLATE pg_catalog."C",
    rule_group character varying(190) NOT NULL COLLATE pg_catalog."C",
    no_data_state character varying(15) DEFAULT 'NoData'::character varying NOT NULL,
    exec_err_state character varying(15) DEFAULT 'Alerting'::character varying NOT NULL,
    "for" bigint DEFAULT 0 NOT NULL,
    annotations text,
    labels text,
    dashboard_uid character varying(40),
    panel_id bigint,
    rule_group_idx bigint DEFAULT 1 NOT NULL,
    is_paused boolean DEFAULT false NOT NULL,
    notification_settings text,
    record text,
    metadata text,
    updated_by character varying(190),
    guid character varying(36) DEFAULT ''::character varying NOT NULL,
    keep_firing_for bigint DEFAULT 0 NOT NULL,
    missing_series_evals_to_resolve smallint,
    folder_fullpath character varying(512),
    alert_routing_policy character varying(40)
);


--
-- Name: alert_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_rule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_rule_id_seq OWNED BY public.alert_rule.id;


--
-- Name: alert_rule_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_rule_state (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    rule_uid character varying(40) NOT NULL,
    data bytea NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: alert_rule_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_rule_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_rule_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_rule_state_id_seq OWNED BY public.alert_rule_state.id;


--
-- Name: alert_rule_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_rule_tag (
    id integer NOT NULL,
    alert_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


--
-- Name: alert_rule_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_rule_tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_rule_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_rule_tag_id_seq OWNED BY public.alert_rule_tag.id;


--
-- Name: alert_rule_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_rule_version (
    id integer NOT NULL,
    rule_org_id bigint NOT NULL,
    rule_uid character varying(40) DEFAULT 0 NOT NULL,
    rule_namespace_uid character varying(40) NOT NULL,
    rule_group character varying(190) NOT NULL,
    parent_version integer NOT NULL,
    restored_from integer NOT NULL,
    version integer NOT NULL,
    created timestamp without time zone NOT NULL,
    title character varying(190) NOT NULL,
    condition character varying(190) NOT NULL,
    data text NOT NULL,
    interval_seconds bigint NOT NULL,
    no_data_state character varying(15) DEFAULT 'NoData'::character varying NOT NULL,
    exec_err_state character varying(15) DEFAULT 'Alerting'::character varying NOT NULL,
    "for" bigint DEFAULT 0 NOT NULL,
    annotations text,
    labels text,
    rule_group_idx bigint DEFAULT 1 NOT NULL,
    is_paused boolean DEFAULT false NOT NULL,
    message text,
    notification_settings text,
    record text,
    metadata text,
    created_by character varying(190),
    rule_guid character varying(36) DEFAULT ''::character varying NOT NULL,
    keep_firing_for bigint DEFAULT 0 NOT NULL,
    missing_series_evals_to_resolve smallint,
    alert_routing_policy character varying(40)
);


--
-- Name: alert_rule_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_rule_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_rule_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_rule_version_id_seq OWNED BY public.alert_rule_version.id;


--
-- Name: annotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.annotation (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    alert_id bigint,
    user_id bigint,
    dashboard_id bigint,
    panel_id bigint,
    category_id bigint,
    type character varying(25) NOT NULL,
    title text NOT NULL,
    text text NOT NULL,
    metric character varying(255),
    prev_state character varying(40) NOT NULL,
    new_state character varying(40) NOT NULL,
    data text NOT NULL,
    epoch bigint NOT NULL,
    region_id bigint DEFAULT 0,
    tags character varying(4096),
    created bigint DEFAULT 0,
    updated bigint DEFAULT 0,
    epoch_end bigint DEFAULT 0 NOT NULL,
    dashboard_uid character varying(40)
);


--
-- Name: annotation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.annotation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.annotation_id_seq OWNED BY public.annotation.id;


--
-- Name: annotation_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.annotation_tag (
    id integer NOT NULL,
    annotation_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


--
-- Name: annotation_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.annotation_tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotation_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.annotation_tag_id_seq OWNED BY public.annotation_tag.id;


--
-- Name: anon_device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anon_device (
    id integer NOT NULL,
    client_ip character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    device_id character varying(127) NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_agent character varying(255) NOT NULL
);


--
-- Name: anon_device_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anon_device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anon_device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anon_device_id_seq OWNED BY public.anon_device.id;


--
-- Name: api_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_key (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    name character varying(190) NOT NULL,
    key character varying(190) NOT NULL,
    role character varying(255) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    expires bigint,
    service_account_id bigint,
    last_used_at timestamp without time zone,
    is_revoked boolean DEFAULT false
);


--
-- Name: api_key_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_key_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_key_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_key_id_seq1 OWNED BY public.api_key.id;


--
-- Name: builtin_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builtin_role (
    id integer NOT NULL,
    role character varying(190) NOT NULL,
    role_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    org_id bigint DEFAULT 0 NOT NULL
);


--
-- Name: builtin_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.builtin_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: builtin_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.builtin_role_id_seq OWNED BY public.builtin_role.id;


--
-- Name: cache_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_data (
    cache_key character varying(168) NOT NULL,
    data bytea NOT NULL,
    expires integer NOT NULL,
    created_at integer NOT NULL
);


--
-- Name: cloud_migration_resource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cloud_migration_resource (
    id integer NOT NULL,
    uid character varying(40) NOT NULL,
    resource_type character varying(40) NOT NULL,
    resource_uid character varying(255) NOT NULL,
    status character varying(20) NOT NULL,
    error_string text,
    snapshot_uid character varying(40) NOT NULL,
    name text,
    parent_name text,
    error_code text
);


--
-- Name: cloud_migration_resource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cloud_migration_resource_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cloud_migration_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cloud_migration_resource_id_seq OWNED BY public.cloud_migration_resource.id;


--
-- Name: cloud_migration_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cloud_migration_session (
    id integer NOT NULL,
    uid character varying(40),
    auth_token text,
    slug text NOT NULL,
    stack_id bigint NOT NULL,
    region_slug text NOT NULL,
    cluster_slug text NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    org_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: cloud_migration_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cloud_migration_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cloud_migration_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cloud_migration_session_id_seq OWNED BY public.cloud_migration_session.id;


--
-- Name: cloud_migration_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cloud_migration_snapshot (
    id integer NOT NULL,
    uid character varying(40),
    session_uid character varying(40),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    finished timestamp without time zone,
    upload_url text,
    status text NOT NULL,
    local_directory text,
    gms_snapshot_uid text,
    encryption_key text,
    error_string text,
    resource_storage_type character varying(255),
    encryption_algo character varying(255),
    metadata bytea,
    public_key bytea
);


--
-- Name: cloud_migration_snapshot_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cloud_migration_snapshot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cloud_migration_snapshot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cloud_migration_snapshot_id_seq OWNED BY public.cloud_migration_snapshot.id;


--
-- Name: cloud_migration_snapshot_partition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cloud_migration_snapshot_partition (
    snapshot_uid character varying(40) NOT NULL,
    partition_number integer NOT NULL,
    resource_type character varying(255) NOT NULL,
    data bytea NOT NULL
);


--
-- Name: correlation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.correlation (
    uid character varying(40) NOT NULL,
    org_id bigint DEFAULT 0 NOT NULL,
    source_uid character varying(40) NOT NULL,
    target_uid character varying(40),
    label text NOT NULL,
    description text NOT NULL,
    config text,
    provisioned boolean DEFAULT false NOT NULL,
    type character varying(40) DEFAULT 'query'::character varying NOT NULL
);


--
-- Name: dashboard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard (
    id integer NOT NULL,
    version integer NOT NULL,
    slug character varying(189) NOT NULL,
    title character varying(189) NOT NULL,
    data text NOT NULL,
    org_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    updated_by integer,
    created_by integer,
    gnet_id bigint,
    plugin_id character varying(189),
    folder_id bigint DEFAULT 0 NOT NULL,
    is_folder boolean DEFAULT false NOT NULL,
    has_acl boolean DEFAULT false NOT NULL,
    uid character varying(40),
    is_public boolean DEFAULT false NOT NULL,
    deleted timestamp without time zone,
    api_version character varying(16),
    folder_uid character varying(40)
);


--
-- Name: dashboard_acl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_acl (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    dashboard_id bigint NOT NULL,
    user_id bigint,
    team_id bigint,
    permission smallint DEFAULT 4 NOT NULL,
    role character varying(20),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: dashboard_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dashboard_acl_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dashboard_acl_id_seq OWNED BY public.dashboard_acl.id;


--
-- Name: dashboard_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dashboard_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dashboard_id_seq1 OWNED BY public.dashboard.id;


--
-- Name: dashboard_provisioning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_provisioning (
    id integer NOT NULL,
    dashboard_id bigint,
    name character varying(150) NOT NULL,
    external_id text NOT NULL,
    updated integer DEFAULT 0 NOT NULL,
    check_sum character varying(32)
);


--
-- Name: dashboard_provisioning_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dashboard_provisioning_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_provisioning_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dashboard_provisioning_id_seq1 OWNED BY public.dashboard_provisioning.id;


--
-- Name: dashboard_public; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_public (
    uid character varying(40) NOT NULL,
    dashboard_uid character varying(40) NOT NULL,
    org_id bigint NOT NULL,
    time_settings text,
    template_variables text,
    access_token character varying(32) NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_enabled boolean DEFAULT false NOT NULL,
    annotations_enabled boolean DEFAULT false NOT NULL,
    time_selection_enabled boolean DEFAULT false NOT NULL,
    share character varying(64) DEFAULT 'public'::character varying NOT NULL
);


--
-- Name: dashboard_snapshot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_snapshot (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    key character varying(190) NOT NULL,
    delete_key character varying(190) NOT NULL,
    org_id bigint NOT NULL,
    user_id bigint NOT NULL,
    external boolean NOT NULL,
    external_url character varying(255) NOT NULL,
    dashboard text NOT NULL,
    expires timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    external_delete_url character varying(255),
    dashboard_encrypted bytea
);


--
-- Name: dashboard_snapshot_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dashboard_snapshot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_snapshot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dashboard_snapshot_id_seq OWNED BY public.dashboard_snapshot.id;


--
-- Name: dashboard_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_tag (
    id integer NOT NULL,
    dashboard_id bigint NOT NULL,
    term character varying(50) NOT NULL,
    dashboard_uid character varying(40),
    org_id bigint DEFAULT 1
);


--
-- Name: dashboard_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dashboard_tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dashboard_tag_id_seq OWNED BY public.dashboard_tag.id;


--
-- Name: dashboard_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_version (
    id integer NOT NULL,
    dashboard_id bigint NOT NULL,
    parent_version integer NOT NULL,
    restored_from integer NOT NULL,
    version integer NOT NULL,
    created timestamp without time zone NOT NULL,
    created_by bigint NOT NULL,
    message text NOT NULL,
    data text NOT NULL,
    api_version character varying(16)
);


--
-- Name: dashboard_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dashboard_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dashboard_version_id_seq OWNED BY public.dashboard_version.id;


--
-- Name: data_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_keys (
    name character varying(100) NOT NULL,
    active boolean NOT NULL,
    scope character varying(30) NOT NULL,
    provider character varying(50) NOT NULL,
    encrypted_data bytea NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    label character varying(100) DEFAULT ''::character varying NOT NULL
);


--
-- Name: data_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_source (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    version integer NOT NULL,
    type character varying(255) NOT NULL,
    name character varying(190) NOT NULL,
    access character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    password character varying(255),
    "user" character varying(255),
    database character varying(255),
    basic_auth boolean NOT NULL,
    basic_auth_user character varying(255),
    basic_auth_password character varying(255),
    is_default boolean NOT NULL,
    json_data text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    with_credentials boolean DEFAULT false NOT NULL,
    secure_json_data text,
    read_only boolean,
    uid character varying(40) DEFAULT 0 NOT NULL,
    is_prunable boolean DEFAULT false,
    api_version character varying(20)
);


--
-- Name: data_source_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.data_source_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_source_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.data_source_id_seq1 OWNED BY public.data_source.id;


--
-- Name: entity_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_event (
    id integer NOT NULL,
    entity_id character varying(1024) NOT NULL,
    event_type character varying(8) NOT NULL,
    created bigint NOT NULL
);


--
-- Name: entity_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_event_id_seq OWNED BY public.entity_event.id;


--
-- Name: file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file (
    path character varying(1024) NOT NULL COLLATE pg_catalog."C",
    path_hash character varying(64) NOT NULL,
    parent_folder_path_hash character varying(64) NOT NULL,
    contents bytea NOT NULL,
    etag character varying(32) NOT NULL,
    cache_control character varying(128) NOT NULL,
    content_disposition character varying(128) NOT NULL,
    updated timestamp without time zone NOT NULL,
    created timestamp without time zone NOT NULL,
    size bigint NOT NULL,
    mime_type character varying(255) NOT NULL
);


--
-- Name: file_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_meta (
    path_hash character varying(64) NOT NULL,
    key character varying(191) NOT NULL,
    value character varying(1024) NOT NULL
);


--
-- Name: folder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folder (
    id integer NOT NULL,
    uid character varying(40) NOT NULL,
    org_id bigint NOT NULL,
    title character varying(189) NOT NULL,
    description character varying(255),
    parent_uid character varying(40),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: folder_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.folder_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: folder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.folder_id_seq OWNED BY public.folder.id;


--
-- Name: kv_store; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kv_store (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    namespace character varying(190) NOT NULL,
    key character varying(190) NOT NULL,
    value text NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: kv_store_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kv_store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kv_store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kv_store_id_seq OWNED BY public.kv_store.id;


--
-- Name: library_element; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_element (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    folder_id bigint NOT NULL,
    uid character varying(40) NOT NULL,
    name character varying(150) NOT NULL,
    kind bigint NOT NULL,
    type character varying(40) NOT NULL,
    description character varying(2048) NOT NULL,
    model text NOT NULL,
    created timestamp without time zone NOT NULL,
    created_by bigint NOT NULL,
    updated timestamp without time zone NOT NULL,
    updated_by bigint NOT NULL,
    version bigint NOT NULL,
    folder_uid character varying(40)
);


--
-- Name: library_element_connection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_element_connection (
    id integer NOT NULL,
    element_id bigint NOT NULL,
    kind bigint NOT NULL,
    connection_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    created_by bigint NOT NULL
);


--
-- Name: library_element_connection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.library_element_connection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: library_element_connection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.library_element_connection_id_seq OWNED BY public.library_element_connection.id;


--
-- Name: library_element_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.library_element_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: library_element_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.library_element_id_seq OWNED BY public.library_element.id;


--
-- Name: login_attempt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_attempt (
    id integer NOT NULL,
    username character varying(190) NOT NULL,
    ip_address character varying(50) NOT NULL,
    created bigint DEFAULT 0 NOT NULL
);


--
-- Name: login_attempt_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.login_attempt_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: login_attempt_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.login_attempt_id_seq1 OWNED BY public.login_attempt.id;


--
-- Name: migration_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migration_log (
    id integer NOT NULL,
    migration_id character varying(255) NOT NULL,
    sql text NOT NULL,
    success boolean NOT NULL,
    error text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


--
-- Name: migration_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migration_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migration_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migration_log_id_seq OWNED BY public.migration_log.id;


--
-- Name: ngalert_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ngalert_configuration (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    alertmanagers text,
    created_at integer NOT NULL,
    updated_at integer NOT NULL,
    send_alerts_to smallint DEFAULT 0 NOT NULL,
    external_alertmanager_uid character varying(40)
);


--
-- Name: ngalert_configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ngalert_configuration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ngalert_configuration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ngalert_configuration_id_seq OWNED BY public.ngalert_configuration.id;


--
-- Name: org; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org (
    id integer NOT NULL,
    version integer NOT NULL,
    name character varying(190) NOT NULL,
    address1 character varying(255),
    address2 character varying(255),
    city character varying(255),
    state character varying(255),
    zip_code character varying(50),
    country character varying(255),
    billing_email character varying(255),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: org_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.org_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.org_id_seq OWNED BY public.org.id;


--
-- Name: org_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org_user (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role character varying(20) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: org_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.org_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: org_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.org_user_id_seq OWNED BY public.org_user.id;


--
-- Name: pending_tenant_deletions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pending_tenant_deletions (
    key_path character varying(2048) NOT NULL COLLATE pg_catalog."C",
    value text NOT NULL
);


--
-- Name: permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission (
    id integer NOT NULL,
    role_id bigint NOT NULL,
    action character varying(190) NOT NULL,
    scope character varying(190) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    kind character varying(80) DEFAULT ''::character varying NOT NULL,
    attribute character varying(40) DEFAULT ''::character varying NOT NULL,
    identifier character varying(40) DEFAULT ''::character varying NOT NULL,
    datasource_type character varying(255)
);


--
-- Name: permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permission_id_seq OWNED BY public.permission.id;


--
-- Name: plugin_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plugin_setting (
    id integer NOT NULL,
    org_id bigint DEFAULT 1 NOT NULL,
    plugin_id character varying(190) NOT NULL,
    enabled boolean NOT NULL,
    pinned boolean NOT NULL,
    json_data text,
    secure_json_data text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    plugin_version character varying(50)
);


--
-- Name: plugin_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plugin_setting_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plugin_setting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plugin_setting_id_seq OWNED BY public.plugin_setting.id;


--
-- Name: preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preferences (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    user_id bigint NOT NULL,
    version integer NOT NULL,
    home_dashboard_id bigint NOT NULL,
    timezone character varying(50) NOT NULL,
    theme character varying(20) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    team_id bigint,
    week_start character varying(10),
    json_data text,
    home_dashboard_uid character varying(40)
);


--
-- Name: preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.preferences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.preferences_id_seq OWNED BY public.preferences.id;


--
-- Name: provenance_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provenance_type (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    record_key character varying(190) NOT NULL,
    record_type character varying(190) NOT NULL,
    provenance character varying(190) NOT NULL
);


--
-- Name: provenance_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.provenance_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provenance_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.provenance_type_id_seq OWNED BY public.provenance_type.id;


--
-- Name: query_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.query_history (
    id integer NOT NULL,
    uid character varying(40) NOT NULL,
    org_id bigint NOT NULL,
    datasource_uid character varying(40) NOT NULL,
    created_by bigint NOT NULL,
    created_at integer NOT NULL,
    comment text NOT NULL,
    queries text NOT NULL
);


--
-- Name: query_history_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.query_history_details (
    id integer NOT NULL,
    query_history_item_uid character varying(40) NOT NULL,
    datasource_uid character varying(40) NOT NULL
);


--
-- Name: query_history_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.query_history_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: query_history_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.query_history_details_id_seq OWNED BY public.query_history_details.id;


--
-- Name: query_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.query_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: query_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.query_history_id_seq OWNED BY public.query_history.id;


--
-- Name: query_history_star; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.query_history_star (
    id integer NOT NULL,
    query_uid character varying(40) NOT NULL,
    user_id bigint NOT NULL,
    org_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: query_history_star_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.query_history_star_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: query_history_star_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.query_history_star_id_seq OWNED BY public.query_history_star.id;


--
-- Name: quota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quota (
    id integer NOT NULL,
    org_id bigint,
    user_id bigint,
    target character varying(190) NOT NULL,
    "limit" bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: quota_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quota_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quota_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quota_id_seq OWNED BY public.quota.id;


--
-- Name: resource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource (
    guid character varying(36) NOT NULL,
    resource_version bigint,
    "group" character varying(190) NOT NULL,
    resource character varying(190) NOT NULL,
    namespace character varying(63) NOT NULL,
    name character varying(253) NOT NULL,
    value text,
    action integer NOT NULL,
    label_set character varying(64),
    previous_resource_version bigint,
    folder character varying(253) DEFAULT ''::character varying NOT NULL
);


--
-- Name: resource_blob; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_blob (
    uuid uuid NOT NULL,
    created timestamp without time zone NOT NULL,
    "group" character varying(190) NOT NULL,
    resource character varying(190) NOT NULL,
    namespace character varying(63) NOT NULL,
    name character varying(253) NOT NULL,
    value bytea NOT NULL,
    hash character varying(64) NOT NULL,
    content_type character varying(255) NOT NULL
);


--
-- Name: resource_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_events (
    key_path character varying(2048) NOT NULL COLLATE pg_catalog."C",
    value text NOT NULL
);


--
-- Name: resource_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_history (
    guid character varying(36) NOT NULL,
    resource_version bigint,
    "group" character varying(190) NOT NULL,
    resource character varying(190) NOT NULL,
    namespace character varying(63) NOT NULL,
    name character varying(253) NOT NULL,
    value text,
    action integer NOT NULL,
    label_set character varying(64),
    previous_resource_version bigint,
    folder character varying(253) DEFAULT ''::character varying NOT NULL,
    generation bigint DEFAULT 0 NOT NULL,
    key_path character varying(2048) DEFAULT ''::character varying NOT NULL COLLATE pg_catalog."C"
);


--
-- Name: resource_last_import_time; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_last_import_time (
    "group" character varying(190) NOT NULL,
    resource character varying(190) NOT NULL,
    namespace character varying(63) NOT NULL,
    last_import_time timestamp without time zone NOT NULL
);


--
-- Name: resource_migration_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_migration_log (
    id integer NOT NULL,
    migration_id character varying(255) NOT NULL,
    sql text NOT NULL,
    success boolean NOT NULL,
    error text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


--
-- Name: resource_migration_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_migration_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_migration_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_migration_log_id_seq OWNED BY public.resource_migration_log.id;


--
-- Name: resource_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_version (
    "group" character varying(190) NOT NULL,
    resource character varying(190) NOT NULL,
    resource_version bigint NOT NULL
);


--
-- Name: role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role (
    id integer NOT NULL,
    name character varying(190) NOT NULL,
    description text,
    version bigint NOT NULL,
    org_id bigint NOT NULL,
    uid character varying(40) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    display_name character varying(190),
    group_name character varying(190),
    hidden boolean DEFAULT false NOT NULL
);


--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- Name: secret_data_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret_data_key (
    uid character varying(100) NOT NULL,
    namespace character varying(253) NOT NULL,
    label character varying(100) NOT NULL,
    active boolean NOT NULL,
    provider character varying(50) NOT NULL,
    encrypted_data bytea NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: secret_encrypted_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret_encrypted_value (
    namespace character varying(253) NOT NULL,
    name character varying(253) NOT NULL,
    version bigint NOT NULL,
    encrypted_data bytea NOT NULL,
    created bigint NOT NULL,
    updated bigint NOT NULL,
    data_key_id character varying(100) DEFAULT ''::character varying NOT NULL
);


--
-- Name: secret_keeper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret_keeper (
    guid character varying(36) NOT NULL,
    name character varying(253) NOT NULL,
    namespace character varying(253) NOT NULL,
    annotations text,
    labels text,
    created bigint NOT NULL,
    created_by text NOT NULL,
    updated bigint NOT NULL,
    updated_by text NOT NULL,
    description character varying(253) NOT NULL,
    type text NOT NULL,
    payload text,
    active boolean DEFAULT false NOT NULL
);


--
-- Name: secret_migration_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret_migration_log (
    id integer NOT NULL,
    migration_id character varying(255) NOT NULL,
    sql text NOT NULL,
    success boolean NOT NULL,
    error text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


--
-- Name: secret_migration_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.secret_migration_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: secret_migration_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.secret_migration_log_id_seq OWNED BY public.secret_migration_log.id;


--
-- Name: secret_secure_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secret_secure_value (
    guid character varying(36) NOT NULL,
    name character varying(253) NOT NULL,
    namespace character varying(253) NOT NULL,
    annotations text,
    labels text,
    created bigint NOT NULL,
    created_by text NOT NULL,
    updated bigint NOT NULL,
    updated_by text NOT NULL,
    external_id text NOT NULL,
    active boolean NOT NULL,
    version bigint NOT NULL,
    description character varying(253) NOT NULL,
    keeper character varying(253),
    decrypters text,
    ref character varying(1024),
    owner_reference_api_group character varying(253),
    owner_reference_api_version character varying(253),
    owner_reference_kind character varying(253),
    owner_reference_name character varying(253),
    lease_token character varying(36),
    lease_created bigint DEFAULT 0 NOT NULL
);


--
-- Name: secrets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.secrets (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    namespace character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    value text,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


--
-- Name: secrets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.secrets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: secrets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.secrets_id_seq OWNED BY public.secrets.id;


--
-- Name: seed_assignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seed_assignment (
    builtin_role character varying(190) NOT NULL,
    role_name character varying(190),
    action character varying(190),
    scope character varying(190),
    id integer NOT NULL,
    origin character varying(190)
);


--
-- Name: seed_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seed_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seed_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seed_assignment_id_seq OWNED BY public.seed_assignment.id;


--
-- Name: server_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.server_lock (
    id integer NOT NULL,
    operation_uid character varying(100) NOT NULL,
    version bigint NOT NULL,
    last_execution bigint NOT NULL
);


--
-- Name: server_lock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.server_lock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: server_lock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.server_lock_id_seq OWNED BY public.server_lock.id;


--
-- Name: session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session (
    key character(16) NOT NULL,
    data bytea NOT NULL,
    expiry integer NOT NULL
);


--
-- Name: short_url; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.short_url (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    uid character varying(40) NOT NULL,
    path text NOT NULL,
    created_by bigint NOT NULL,
    created_at integer NOT NULL,
    last_seen_at integer
);


--
-- Name: short_url_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.short_url_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: short_url_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.short_url_id_seq OWNED BY public.short_url.id;


--
-- Name: signing_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.signing_key (
    id integer NOT NULL,
    key_id character varying(255) NOT NULL,
    private_key text NOT NULL,
    added_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    alg character varying(255) NOT NULL
);


--
-- Name: signing_key_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.signing_key_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: signing_key_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.signing_key_id_seq OWNED BY public.signing_key.id;


--
-- Name: sso_setting; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sso_setting (
    id character varying(40) NOT NULL,
    provider character varying(255) NOT NULL,
    settings text NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: star; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.star (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    dashboard_id bigint NOT NULL,
    dashboard_uid character varying(40),
    org_id bigint DEFAULT 1,
    updated timestamp without time zone
);


--
-- Name: star_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.star_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: star_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.star_id_seq OWNED BY public.star.id;


--
-- Name: tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    value character varying(100) NOT NULL
);


--
-- Name: tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_id_seq OWNED BY public.tag.id;


--
-- Name: team; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team (
    id integer NOT NULL,
    name character varying(190) NOT NULL,
    org_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    uid character varying(40),
    external_uid character varying(256),
    is_provisioned boolean,
    email character varying(190)
);


--
-- Name: team_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_id_seq OWNED BY public.team.id;


--
-- Name: team_member; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_member (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    team_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    external boolean,
    permission smallint,
    uid character varying(40)
);


--
-- Name: team_member_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_member_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_member_id_seq OWNED BY public.team_member.id;


--
-- Name: team_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_role (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    team_id bigint NOT NULL,
    role_id bigint NOT NULL,
    created timestamp without time zone NOT NULL
);


--
-- Name: team_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_role_id_seq OWNED BY public.team_role.id;


--
-- Name: temp_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temp_user (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    version integer NOT NULL,
    email character varying(190) NOT NULL,
    name character varying(255),
    role character varying(20),
    code character varying(190) NOT NULL,
    status character varying(20) NOT NULL,
    invited_by_user_id bigint,
    email_sent boolean NOT NULL,
    email_sent_on timestamp without time zone,
    remote_addr character varying(255),
    created integer DEFAULT 0 NOT NULL,
    updated integer DEFAULT 0 NOT NULL
);


--
-- Name: temp_user_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.temp_user_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: temp_user_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.temp_user_id_seq1 OWNED BY public.temp_user.id;


--
-- Name: test_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_data (
    id integer NOT NULL,
    metric1 character varying(20),
    metric2 character varying(150),
    value_big_int bigint,
    value_double double precision,
    value_float real,
    value_int integer,
    time_epoch bigint NOT NULL,
    time_date_time timestamp without time zone NOT NULL,
    time_time_stamp timestamp without time zone NOT NULL
);


--
-- Name: test_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_data_id_seq OWNED BY public.test_data.id;


--
-- Name: unifiedstorage_migration_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unifiedstorage_migration_log (
    id integer NOT NULL,
    migration_id character varying(255) NOT NULL,
    sql text NOT NULL,
    success boolean NOT NULL,
    error text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


--
-- Name: unifiedstorage_migration_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unifiedstorage_migration_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unifiedstorage_migration_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unifiedstorage_migration_log_id_seq OWNED BY public.unifiedstorage_migration_log.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    version integer NOT NULL,
    login character varying(190) NOT NULL,
    email character varying(190) NOT NULL,
    name character varying(255),
    password character varying(255),
    salt character varying(50),
    rands character varying(50),
    company character varying(255),
    org_id bigint NOT NULL,
    is_admin boolean NOT NULL,
    email_verified boolean,
    theme character varying(255),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    help_flags1 bigint DEFAULT 0 NOT NULL,
    last_seen_at timestamp without time zone,
    is_disabled boolean DEFAULT false NOT NULL,
    is_service_account boolean DEFAULT false,
    uid character varying(190),
    is_provisioned boolean DEFAULT false NOT NULL
);


--
-- Name: user_auth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_auth (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    auth_module character varying(190) NOT NULL,
    auth_id character varying(190) NOT NULL,
    created timestamp without time zone NOT NULL,
    o_auth_access_token text,
    o_auth_refresh_token text,
    o_auth_token_type text,
    o_auth_expiry timestamp without time zone,
    o_auth_id_token text,
    external_uid text,
    user_uid character varying(190)
);


--
-- Name: user_auth_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_auth_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_auth_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_auth_id_seq OWNED BY public.user_auth.id;


--
-- Name: user_auth_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_auth_token (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    auth_token character varying(100) NOT NULL,
    prev_auth_token character varying(100) NOT NULL,
    user_agent character varying(255) NOT NULL,
    client_ip character varying(255) NOT NULL,
    auth_token_seen boolean NOT NULL,
    seen_at integer,
    rotated_at integer NOT NULL,
    created_at integer NOT NULL,
    updated_at integer NOT NULL,
    revoked_at integer,
    external_session_id bigint
);


--
-- Name: user_auth_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_auth_token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_auth_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_auth_token_id_seq OWNED BY public.user_auth_token.id;


--
-- Name: user_external_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_external_session (
    id integer NOT NULL,
    user_auth_id bigint NOT NULL,
    user_id bigint NOT NULL,
    auth_module character varying(190) NOT NULL,
    access_token text,
    id_token text,
    refresh_token text,
    session_id character varying(1024),
    session_id_hash character(44),
    name_id character varying(1024),
    name_id_hash character(44),
    expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: user_external_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_external_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_external_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_external_session_id_seq OWNED BY public.user_external_session.id;


--
-- Name: user_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_id_seq1 OWNED BY public."user".id;


--
-- Name: user_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_role (
    id integer NOT NULL,
    org_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    created timestamp without time zone NOT NULL,
    group_mapping_uid character varying(40) DEFAULT ''::character varying
);


--
-- Name: user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_role_id_seq OWNED BY public.user_role.id;


--
-- Name: alert id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert ALTER COLUMN id SET DEFAULT nextval('public.alert_id_seq'::regclass);


--
-- Name: alert_configuration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_configuration ALTER COLUMN id SET DEFAULT nextval('public.alert_configuration_id_seq'::regclass);


--
-- Name: alert_configuration_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_configuration_history ALTER COLUMN id SET DEFAULT nextval('public.alert_configuration_history_id_seq'::regclass);


--
-- Name: alert_image id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_image ALTER COLUMN id SET DEFAULT nextval('public.alert_image_id_seq'::regclass);


--
-- Name: alert_notification id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_notification ALTER COLUMN id SET DEFAULT nextval('public.alert_notification_id_seq'::regclass);


--
-- Name: alert_notification_state id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_notification_state ALTER COLUMN id SET DEFAULT nextval('public.alert_notification_state_id_seq'::regclass);


--
-- Name: alert_rule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule ALTER COLUMN id SET DEFAULT nextval('public.alert_rule_id_seq'::regclass);


--
-- Name: alert_rule_state id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule_state ALTER COLUMN id SET DEFAULT nextval('public.alert_rule_state_id_seq'::regclass);


--
-- Name: alert_rule_tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule_tag ALTER COLUMN id SET DEFAULT nextval('public.alert_rule_tag_id_seq'::regclass);


--
-- Name: alert_rule_version id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule_version ALTER COLUMN id SET DEFAULT nextval('public.alert_rule_version_id_seq'::regclass);


--
-- Name: annotation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.annotation ALTER COLUMN id SET DEFAULT nextval('public.annotation_id_seq'::regclass);


--
-- Name: annotation_tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.annotation_tag ALTER COLUMN id SET DEFAULT nextval('public.annotation_tag_id_seq'::regclass);


--
-- Name: anon_device id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anon_device ALTER COLUMN id SET DEFAULT nextval('public.anon_device_id_seq'::regclass);


--
-- Name: api_key id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_key ALTER COLUMN id SET DEFAULT nextval('public.api_key_id_seq1'::regclass);


--
-- Name: builtin_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builtin_role ALTER COLUMN id SET DEFAULT nextval('public.builtin_role_id_seq'::regclass);


--
-- Name: cloud_migration_resource id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_migration_resource ALTER COLUMN id SET DEFAULT nextval('public.cloud_migration_resource_id_seq'::regclass);


--
-- Name: cloud_migration_session id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_migration_session ALTER COLUMN id SET DEFAULT nextval('public.cloud_migration_session_id_seq'::regclass);


--
-- Name: cloud_migration_snapshot id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_migration_snapshot ALTER COLUMN id SET DEFAULT nextval('public.cloud_migration_snapshot_id_seq'::regclass);


--
-- Name: dashboard id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard ALTER COLUMN id SET DEFAULT nextval('public.dashboard_id_seq1'::regclass);


--
-- Name: dashboard_acl id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_acl ALTER COLUMN id SET DEFAULT nextval('public.dashboard_acl_id_seq'::regclass);


--
-- Name: dashboard_provisioning id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_provisioning ALTER COLUMN id SET DEFAULT nextval('public.dashboard_provisioning_id_seq1'::regclass);


--
-- Name: dashboard_snapshot id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_snapshot ALTER COLUMN id SET DEFAULT nextval('public.dashboard_snapshot_id_seq'::regclass);


--
-- Name: dashboard_tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_tag ALTER COLUMN id SET DEFAULT nextval('public.dashboard_tag_id_seq'::regclass);


--
-- Name: dashboard_version id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_version ALTER COLUMN id SET DEFAULT nextval('public.dashboard_version_id_seq'::regclass);


--
-- Name: data_source id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_source ALTER COLUMN id SET DEFAULT nextval('public.data_source_id_seq1'::regclass);


--
-- Name: entity_event id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_event ALTER COLUMN id SET DEFAULT nextval('public.entity_event_id_seq'::regclass);


--
-- Name: folder id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folder ALTER COLUMN id SET DEFAULT nextval('public.folder_id_seq'::regclass);


--
-- Name: kv_store id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kv_store ALTER COLUMN id SET DEFAULT nextval('public.kv_store_id_seq'::regclass);


--
-- Name: library_element id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_element ALTER COLUMN id SET DEFAULT nextval('public.library_element_id_seq'::regclass);


--
-- Name: library_element_connection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_element_connection ALTER COLUMN id SET DEFAULT nextval('public.library_element_connection_id_seq'::regclass);


--
-- Name: login_attempt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_attempt ALTER COLUMN id SET DEFAULT nextval('public.login_attempt_id_seq1'::regclass);


--
-- Name: migration_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migration_log ALTER COLUMN id SET DEFAULT nextval('public.migration_log_id_seq'::regclass);


--
-- Name: ngalert_configuration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngalert_configuration ALTER COLUMN id SET DEFAULT nextval('public.ngalert_configuration_id_seq'::regclass);


--
-- Name: org id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org ALTER COLUMN id SET DEFAULT nextval('public.org_id_seq'::regclass);


--
-- Name: org_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_user ALTER COLUMN id SET DEFAULT nextval('public.org_user_id_seq'::regclass);


--
-- Name: permission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission ALTER COLUMN id SET DEFAULT nextval('public.permission_id_seq'::regclass);


--
-- Name: plugin_setting id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugin_setting ALTER COLUMN id SET DEFAULT nextval('public.plugin_setting_id_seq'::regclass);


--
-- Name: preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences ALTER COLUMN id SET DEFAULT nextval('public.preferences_id_seq'::regclass);


--
-- Name: provenance_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provenance_type ALTER COLUMN id SET DEFAULT nextval('public.provenance_type_id_seq'::regclass);


--
-- Name: query_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_history ALTER COLUMN id SET DEFAULT nextval('public.query_history_id_seq'::regclass);


--
-- Name: query_history_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_history_details ALTER COLUMN id SET DEFAULT nextval('public.query_history_details_id_seq'::regclass);


--
-- Name: query_history_star id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_history_star ALTER COLUMN id SET DEFAULT nextval('public.query_history_star_id_seq'::regclass);


--
-- Name: quota id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quota ALTER COLUMN id SET DEFAULT nextval('public.quota_id_seq'::regclass);


--
-- Name: resource_migration_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_migration_log ALTER COLUMN id SET DEFAULT nextval('public.resource_migration_log_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- Name: secret_migration_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_migration_log ALTER COLUMN id SET DEFAULT nextval('public.secret_migration_log_id_seq'::regclass);


--
-- Name: secrets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets ALTER COLUMN id SET DEFAULT nextval('public.secrets_id_seq'::regclass);


--
-- Name: seed_assignment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seed_assignment ALTER COLUMN id SET DEFAULT nextval('public.seed_assignment_id_seq'::regclass);


--
-- Name: server_lock id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.server_lock ALTER COLUMN id SET DEFAULT nextval('public.server_lock_id_seq'::regclass);


--
-- Name: short_url id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.short_url ALTER COLUMN id SET DEFAULT nextval('public.short_url_id_seq'::regclass);


--
-- Name: signing_key id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signing_key ALTER COLUMN id SET DEFAULT nextval('public.signing_key_id_seq'::regclass);


--
-- Name: star id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.star ALTER COLUMN id SET DEFAULT nextval('public.star_id_seq'::regclass);


--
-- Name: tag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag ALTER COLUMN id SET DEFAULT nextval('public.tag_id_seq'::regclass);


--
-- Name: team id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team ALTER COLUMN id SET DEFAULT nextval('public.team_id_seq'::regclass);


--
-- Name: team_member id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member ALTER COLUMN id SET DEFAULT nextval('public.team_member_id_seq'::regclass);


--
-- Name: team_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_role ALTER COLUMN id SET DEFAULT nextval('public.team_role_id_seq'::regclass);


--
-- Name: temp_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temp_user ALTER COLUMN id SET DEFAULT nextval('public.temp_user_id_seq1'::regclass);


--
-- Name: test_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_data ALTER COLUMN id SET DEFAULT nextval('public.test_data_id_seq'::regclass);


--
-- Name: unifiedstorage_migration_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unifiedstorage_migration_log ALTER COLUMN id SET DEFAULT nextval('public.unifiedstorage_migration_log_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq1'::regclass);


--
-- Name: user_auth id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auth ALTER COLUMN id SET DEFAULT nextval('public.user_auth_id_seq'::regclass);


--
-- Name: user_auth_token id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auth_token ALTER COLUMN id SET DEFAULT nextval('public.user_auth_token_id_seq'::regclass);


--
-- Name: user_external_session id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_external_session ALTER COLUMN id SET DEFAULT nextval('public.user_external_session_id_seq'::regclass);


--
-- Name: user_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role ALTER COLUMN id SET DEFAULT nextval('public.user_role_id_seq'::regclass);


--
-- Name: alert_configuration_history alert_configuration_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_configuration_history
    ADD CONSTRAINT alert_configuration_history_pkey PRIMARY KEY (id);


--
-- Name: alert_configuration alert_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_configuration
    ADD CONSTRAINT alert_configuration_pkey PRIMARY KEY (id);


--
-- Name: alert_image alert_image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_image
    ADD CONSTRAINT alert_image_pkey PRIMARY KEY (id);


--
-- Name: alert_instance alert_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_instance
    ADD CONSTRAINT alert_instance_pkey PRIMARY KEY (rule_org_id, rule_uid, labels_hash);


--
-- Name: alert_notification alert_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_notification
    ADD CONSTRAINT alert_notification_pkey PRIMARY KEY (id);


--
-- Name: alert_notification_state alert_notification_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_notification_state
    ADD CONSTRAINT alert_notification_state_pkey PRIMARY KEY (id);


--
-- Name: alert alert_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert
    ADD CONSTRAINT alert_pkey PRIMARY KEY (id);


--
-- Name: alert_rule alert_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule
    ADD CONSTRAINT alert_rule_pkey PRIMARY KEY (id);


--
-- Name: alert_rule_state alert_rule_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule_state
    ADD CONSTRAINT alert_rule_state_pkey PRIMARY KEY (id);


--
-- Name: alert_rule_tag alert_rule_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule_tag
    ADD CONSTRAINT alert_rule_tag_pkey PRIMARY KEY (id);


--
-- Name: alert_rule_version alert_rule_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule_version
    ADD CONSTRAINT alert_rule_version_pkey PRIMARY KEY (id);


--
-- Name: annotation annotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.annotation
    ADD CONSTRAINT annotation_pkey PRIMARY KEY (id);


--
-- Name: annotation_tag annotation_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.annotation_tag
    ADD CONSTRAINT annotation_tag_pkey PRIMARY KEY (id);


--
-- Name: anon_device anon_device_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anon_device
    ADD CONSTRAINT anon_device_pkey PRIMARY KEY (id);


--
-- Name: api_key api_key_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey1 PRIMARY KEY (id);


--
-- Name: builtin_role builtin_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builtin_role
    ADD CONSTRAINT builtin_role_pkey PRIMARY KEY (id);


--
-- Name: cache_data cache_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_data
    ADD CONSTRAINT cache_data_pkey PRIMARY KEY (cache_key);


--
-- Name: cloud_migration_resource cloud_migration_resource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_migration_resource
    ADD CONSTRAINT cloud_migration_resource_pkey PRIMARY KEY (id);


--
-- Name: cloud_migration_session cloud_migration_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_migration_session
    ADD CONSTRAINT cloud_migration_session_pkey PRIMARY KEY (id);


--
-- Name: cloud_migration_snapshot_partition cloud_migration_snapshot_partition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_migration_snapshot_partition
    ADD CONSTRAINT cloud_migration_snapshot_partition_pkey PRIMARY KEY (snapshot_uid, resource_type, partition_number);


--
-- Name: cloud_migration_snapshot cloud_migration_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloud_migration_snapshot
    ADD CONSTRAINT cloud_migration_snapshot_pkey PRIMARY KEY (id);


--
-- Name: correlation correlation_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.correlation
    ADD CONSTRAINT correlation_pkey1 PRIMARY KEY (uid, org_id, source_uid);


--
-- Name: dashboard_acl dashboard_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_acl
    ADD CONSTRAINT dashboard_acl_pkey PRIMARY KEY (id);


--
-- Name: dashboard dashboard_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT dashboard_pkey1 PRIMARY KEY (id);


--
-- Name: dashboard_provisioning dashboard_provisioning_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_provisioning
    ADD CONSTRAINT dashboard_provisioning_pkey1 PRIMARY KEY (id);


--
-- Name: dashboard_public dashboard_public_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_public
    ADD CONSTRAINT dashboard_public_config_pkey PRIMARY KEY (uid);


--
-- Name: dashboard_snapshot dashboard_snapshot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_snapshot
    ADD CONSTRAINT dashboard_snapshot_pkey PRIMARY KEY (id);


--
-- Name: dashboard_tag dashboard_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_tag
    ADD CONSTRAINT dashboard_tag_pkey PRIMARY KEY (id);


--
-- Name: dashboard_version dashboard_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_version
    ADD CONSTRAINT dashboard_version_pkey PRIMARY KEY (id);


--
-- Name: data_keys data_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_keys
    ADD CONSTRAINT data_keys_pkey PRIMARY KEY (name);


--
-- Name: data_source data_source_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_source
    ADD CONSTRAINT data_source_pkey1 PRIMARY KEY (id);


--
-- Name: entity_event entity_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_event
    ADD CONSTRAINT entity_event_pkey PRIMARY KEY (id);


--
-- Name: file_meta file_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_meta
    ADD CONSTRAINT file_meta_pkey PRIMARY KEY (path_hash, key);


--
-- Name: file file_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file
    ADD CONSTRAINT file_pkey PRIMARY KEY (path_hash);


--
-- Name: folder folder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT folder_pkey PRIMARY KEY (id);


--
-- Name: kv_store kv_store_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kv_store
    ADD CONSTRAINT kv_store_pkey PRIMARY KEY (id);


--
-- Name: library_element_connection library_element_connection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_element_connection
    ADD CONSTRAINT library_element_connection_pkey PRIMARY KEY (id);


--
-- Name: library_element library_element_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_element
    ADD CONSTRAINT library_element_pkey PRIMARY KEY (id);


--
-- Name: login_attempt login_attempt_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_attempt
    ADD CONSTRAINT login_attempt_pkey1 PRIMARY KEY (id);


--
-- Name: migration_log migration_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migration_log
    ADD CONSTRAINT migration_log_pkey PRIMARY KEY (id);


--
-- Name: ngalert_configuration ngalert_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ngalert_configuration
    ADD CONSTRAINT ngalert_configuration_pkey PRIMARY KEY (id);


--
-- Name: org org_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org
    ADD CONSTRAINT org_pkey PRIMARY KEY (id);


--
-- Name: org_user org_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_user
    ADD CONSTRAINT org_user_pkey PRIMARY KEY (id);


--
-- Name: pending_tenant_deletions pending_tenant_deletions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_tenant_deletions
    ADD CONSTRAINT pending_tenant_deletions_pkey PRIMARY KEY (key_path);


--
-- Name: permission permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission
    ADD CONSTRAINT permission_pkey PRIMARY KEY (id);


--
-- Name: plugin_setting plugin_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plugin_setting
    ADD CONSTRAINT plugin_setting_pkey PRIMARY KEY (id);


--
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (id);


--
-- Name: provenance_type provenance_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provenance_type
    ADD CONSTRAINT provenance_type_pkey PRIMARY KEY (id);


--
-- Name: query_history_details query_history_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_history_details
    ADD CONSTRAINT query_history_details_pkey PRIMARY KEY (id);


--
-- Name: query_history query_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_history
    ADD CONSTRAINT query_history_pkey PRIMARY KEY (id);


--
-- Name: query_history_star query_history_star_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.query_history_star
    ADD CONSTRAINT query_history_star_pkey PRIMARY KEY (id);


--
-- Name: quota quota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quota
    ADD CONSTRAINT quota_pkey PRIMARY KEY (id);


--
-- Name: resource_blob resource_blob_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_blob
    ADD CONSTRAINT resource_blob_pkey PRIMARY KEY (uuid);


--
-- Name: resource_events resource_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_events
    ADD CONSTRAINT resource_events_pkey PRIMARY KEY (key_path);


--
-- Name: resource_history resource_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_history
    ADD CONSTRAINT resource_history_pkey PRIMARY KEY (guid);


--
-- Name: resource_last_import_time resource_last_import_time_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_last_import_time
    ADD CONSTRAINT resource_last_import_time_pkey PRIMARY KEY ("group", resource, namespace);


--
-- Name: resource_migration_log resource_migration_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_migration_log
    ADD CONSTRAINT resource_migration_log_pkey PRIMARY KEY (id);


--
-- Name: resource resource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_pkey PRIMARY KEY (guid);


--
-- Name: resource_version resource_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_version
    ADD CONSTRAINT resource_version_pkey PRIMARY KEY ("group", resource);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: secret_data_key secret_data_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_data_key
    ADD CONSTRAINT secret_data_key_pkey PRIMARY KEY (uid);


--
-- Name: secret_encrypted_value secret_encrypted_value_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_encrypted_value
    ADD CONSTRAINT secret_encrypted_value_pkey PRIMARY KEY (namespace, name, version);


--
-- Name: secret_keeper secret_keeper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_keeper
    ADD CONSTRAINT secret_keeper_pkey PRIMARY KEY (guid);


--
-- Name: secret_migration_log secret_migration_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_migration_log
    ADD CONSTRAINT secret_migration_log_pkey PRIMARY KEY (id);


--
-- Name: secret_secure_value secret_secure_value_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secret_secure_value
    ADD CONSTRAINT secret_secure_value_pkey PRIMARY KEY (guid);


--
-- Name: secrets secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.secrets
    ADD CONSTRAINT secrets_pkey PRIMARY KEY (id);


--
-- Name: seed_assignment seed_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seed_assignment
    ADD CONSTRAINT seed_assignment_pkey PRIMARY KEY (id);


--
-- Name: server_lock server_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.server_lock
    ADD CONSTRAINT server_lock_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (key);


--
-- Name: short_url short_url_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.short_url
    ADD CONSTRAINT short_url_pkey PRIMARY KEY (id);


--
-- Name: signing_key signing_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signing_key
    ADD CONSTRAINT signing_key_pkey PRIMARY KEY (id);


--
-- Name: sso_setting sso_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sso_setting
    ADD CONSTRAINT sso_setting_pkey PRIMARY KEY (id);


--
-- Name: star star_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.star
    ADD CONSTRAINT star_pkey PRIMARY KEY (id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: team_member team_member_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_member
    ADD CONSTRAINT team_member_pkey PRIMARY KEY (id);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- Name: team_role team_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_role
    ADD CONSTRAINT team_role_pkey PRIMARY KEY (id);


--
-- Name: temp_user temp_user_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temp_user
    ADD CONSTRAINT temp_user_pkey1 PRIMARY KEY (id);


--
-- Name: test_data test_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_data
    ADD CONSTRAINT test_data_pkey PRIMARY KEY (id);


--
-- Name: unifiedstorage_migration_log unifiedstorage_migration_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unifiedstorage_migration_log
    ADD CONSTRAINT unifiedstorage_migration_log_pkey PRIMARY KEY (id);


--
-- Name: user_auth user_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auth
    ADD CONSTRAINT user_auth_pkey PRIMARY KEY (id);


--
-- Name: user_auth_token user_auth_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auth_token
    ADD CONSTRAINT user_auth_token_pkey PRIMARY KEY (id);


--
-- Name: user_external_session user_external_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_external_session
    ADD CONSTRAINT user_external_session_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey1 PRIMARY KEY (id);


--
-- Name: user_role user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (id);


--
-- Name: IDX_alert_dashboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_dashboard_id" ON public.alert USING btree (dashboard_id);


--
-- Name: IDX_alert_instance_rule_org_id_current_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_instance_rule_org_id_current_state" ON public.alert_instance USING btree (rule_org_id, current_state);


--
-- Name: IDX_alert_instance_rule_org_id_rule_uid_current_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_instance_rule_org_id_rule_uid_current_state" ON public.alert_instance USING btree (rule_org_id, rule_uid, current_state);


--
-- Name: IDX_alert_notification_state_alert_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_notification_state_alert_id" ON public.alert_notification_state USING btree (alert_id);


--
-- Name: IDX_alert_org_id_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_org_id_id" ON public.alert USING btree (org_id, id);


--
-- Name: IDX_alert_rule_org_id_dashboard_uid_panel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_rule_org_id_dashboard_uid_panel_id" ON public.alert_rule USING btree (org_id, dashboard_uid, panel_id);


--
-- Name: IDX_alert_rule_org_id_folder_fullpath; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_rule_org_id_folder_fullpath" ON public.alert_rule USING btree (org_id, folder_fullpath);


--
-- Name: IDX_alert_rule_org_id_namespace_uid_rule_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_rule_org_id_namespace_uid_rule_group" ON public.alert_rule USING btree (org_id, namespace_uid, rule_group);


--
-- Name: IDX_alert_rule_org_id_namespace_uid_rule_group_rule_group_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_rule_org_id_namespace_uid_rule_group_rule_group_idx" ON public.alert_rule USING btree (org_id, namespace_uid, rule_group, rule_group_idx);


--
-- Name: IDX_alert_rule_tag_alert_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_rule_tag_alert_id" ON public.alert_rule_tag USING btree (alert_id);


--
-- Name: IDX_alert_rule_version_rule_org_id_rule_namespace_uid_rule_grou; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_rule_version_rule_org_id_rule_namespace_uid_rule_grou" ON public.alert_rule_version USING btree (rule_org_id, rule_namespace_uid, rule_group);


--
-- Name: IDX_alert_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_alert_state" ON public.alert USING btree (state);


--
-- Name: IDX_annotation_alert_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_annotation_alert_id" ON public.annotation USING btree (alert_id);


--
-- Name: IDX_annotation_org_id_alert_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_annotation_org_id_alert_id" ON public.annotation USING btree (org_id, alert_id);


--
-- Name: IDX_annotation_org_id_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_annotation_org_id_created" ON public.annotation USING btree (org_id, created);


--
-- Name: IDX_annotation_org_id_dashboard_id_epoch_end_epoch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_annotation_org_id_dashboard_id_epoch_end_epoch" ON public.annotation USING btree (org_id, dashboard_id, epoch_end, epoch);


--
-- Name: IDX_annotation_org_id_epoch_end_epoch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_annotation_org_id_epoch_end_epoch" ON public.annotation USING btree (org_id, epoch_end, epoch);


--
-- Name: IDX_annotation_org_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_annotation_org_id_type" ON public.annotation USING btree (org_id, type);


--
-- Name: IDX_annotation_org_id_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_annotation_org_id_updated" ON public.annotation USING btree (org_id, updated);


--
-- Name: IDX_anon_device_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_anon_device_updated_at" ON public.anon_device USING btree (updated_at);


--
-- Name: IDX_api_key_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_org_id" ON public.api_key USING btree (org_id);


--
-- Name: IDX_builtin_role_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_builtin_role_org_id" ON public.builtin_role USING btree (org_id);


--
-- Name: IDX_builtin_role_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_builtin_role_role" ON public.builtin_role USING btree (role);


--
-- Name: IDX_builtin_role_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_builtin_role_role_id" ON public.builtin_role USING btree (role_id);


--
-- Name: IDX_correlation_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_correlation_org_id" ON public.correlation USING btree (org_id);


--
-- Name: IDX_correlation_source_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_correlation_source_uid" ON public.correlation USING btree (source_uid);


--
-- Name: IDX_correlation_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_correlation_uid" ON public.correlation USING btree (uid);


--
-- Name: IDX_dashboard_acl_dashboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_acl_dashboard_id" ON public.dashboard_acl USING btree (dashboard_id);


--
-- Name: IDX_dashboard_acl_org_id_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_acl_org_id_role" ON public.dashboard_acl USING btree (org_id, role);


--
-- Name: IDX_dashboard_acl_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_acl_permission" ON public.dashboard_acl USING btree (permission);


--
-- Name: IDX_dashboard_acl_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_acl_team_id" ON public.dashboard_acl USING btree (team_id);


--
-- Name: IDX_dashboard_acl_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_acl_user_id" ON public.dashboard_acl USING btree (user_id);


--
-- Name: IDX_dashboard_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_deleted" ON public.dashboard USING btree (deleted);


--
-- Name: IDX_dashboard_gnet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_gnet_id" ON public.dashboard USING btree (gnet_id);


--
-- Name: IDX_dashboard_is_folder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_is_folder" ON public.dashboard USING btree (is_folder);


--
-- Name: IDX_dashboard_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_org_id" ON public.dashboard USING btree (org_id);


--
-- Name: IDX_dashboard_org_id_folder_id_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_org_id_folder_id_title" ON public.dashboard USING btree (org_id, folder_id, title);


--
-- Name: IDX_dashboard_org_id_plugin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_org_id_plugin_id" ON public.dashboard USING btree (org_id, plugin_id);


--
-- Name: IDX_dashboard_provisioning_dashboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_provisioning_dashboard_id" ON public.dashboard_provisioning USING btree (dashboard_id);


--
-- Name: IDX_dashboard_provisioning_dashboard_id_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_provisioning_dashboard_id_name" ON public.dashboard_provisioning USING btree (dashboard_id, name);


--
-- Name: IDX_dashboard_public_config_org_id_dashboard_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_public_config_org_id_dashboard_uid" ON public.dashboard_public USING btree (org_id, dashboard_uid);


--
-- Name: IDX_dashboard_snapshot_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_snapshot_user_id" ON public.dashboard_snapshot USING btree (user_id);


--
-- Name: IDX_dashboard_tag_dashboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_tag_dashboard_id" ON public.dashboard_tag USING btree (dashboard_id);


--
-- Name: IDX_dashboard_tag_dashboard_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_tag_dashboard_uid" ON public.dashboard_tag USING btree (dashboard_uid);


--
-- Name: IDX_dashboard_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_title" ON public.dashboard USING btree (title);


--
-- Name: IDX_dashboard_version_dashboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_dashboard_version_dashboard_id" ON public.dashboard_version USING btree (dashboard_id);


--
-- Name: IDX_data_source_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_data_source_org_id" ON public.data_source USING btree (org_id);


--
-- Name: IDX_data_source_org_id_is_default; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_data_source_org_id_is_default" ON public.data_source USING btree (org_id, is_default);


--
-- Name: IDX_file_parent_folder_path_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_file_parent_folder_path_hash" ON public.file USING btree (parent_folder_path_hash);


--
-- Name: IDX_folder_org_id_parent_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_folder_org_id_parent_uid" ON public.folder USING btree (org_id, parent_uid);


--
-- Name: IDX_login_attempt_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_login_attempt_username" ON public.login_attempt USING btree (username);


--
-- Name: IDX_org_user_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_org_user_org_id" ON public.org_user USING btree (org_id);


--
-- Name: IDX_org_user_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_org_user_user_id" ON public.org_user USING btree (user_id);


--
-- Name: IDX_permission_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_permission_identifier" ON public.permission USING btree (identifier);


--
-- Name: IDX_permission_role_id_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_permission_role_id_action" ON public.permission USING btree (role_id, action);


--
-- Name: IDX_permission_role_id_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_permission_role_id_scope" ON public.permission USING btree (role_id, scope);


--
-- Name: IDX_preferences_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_preferences_org_id" ON public.preferences USING btree (org_id);


--
-- Name: IDX_preferences_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_preferences_user_id" ON public.preferences USING btree (user_id);


--
-- Name: IDX_query_history_org_id_created_by_datasource_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_query_history_org_id_created_by_datasource_uid" ON public.query_history USING btree (org_id, created_by, datasource_uid);


--
-- Name: IDX_resource_blob_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_blob_created" ON public.resource_blob USING btree (created);


--
-- Name: IDX_resource_group_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_group_resource" ON public.resource USING btree ("group", resource);


--
-- Name: IDX_resource_history_group_resource_resource_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_history_group_resource_resource_version" ON public.resource_history USING btree ("group", resource, resource_version);


--
-- Name: IDX_resource_history_key_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_history_key_path" ON public.resource_history USING btree (key_path);


--
-- Name: IDX_resource_history_namespace_group_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_history_namespace_group_name" ON public.resource_blob USING btree (namespace, "group", resource, name);


--
-- Name: IDX_resource_history_namespace_group_resource_action_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_history_namespace_group_resource_action_version" ON public.resource_history USING btree (namespace, "group", resource, action, resource_version);


--
-- Name: IDX_resource_history_namespace_group_resource_name_generation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_history_namespace_group_resource_name_generation" ON public.resource_history USING btree (namespace, "group", resource, name, generation);


--
-- Name: IDX_resource_history_resource_action_version_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_history_resource_action_version_name" ON public.resource_history USING btree ("group", resource, action, resource_version, name);


--
-- Name: IDX_resource_history_resource_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_resource_history_resource_version" ON public.resource_history USING btree (resource_version);


--
-- Name: IDX_role_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_role_org_id" ON public.role USING btree (org_id);


--
-- Name: IDX_secret_data_key_namespace_label_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_secret_data_key_namespace_label_active" ON public.secret_data_key USING btree (namespace, label, active);


--
-- Name: IDX_secret_encrypted_value_data_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_secret_encrypted_value_data_key_id" ON public.secret_encrypted_value USING btree (data_key_id);


--
-- Name: IDX_secret_keeper_namespace_name_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_secret_keeper_namespace_name_active" ON public.secret_keeper USING btree (namespace, name, active);


--
-- Name: IDX_secret_secure_value_lease_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_secret_secure_value_lease_created" ON public.secret_secure_value USING btree (lease_created);


--
-- Name: IDX_secret_secure_value_lease_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_secret_secure_value_lease_token" ON public.secret_secure_value USING btree (lease_token);


--
-- Name: IDX_secret_secure_value_namespace_active_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_secret_secure_value_namespace_active_updated" ON public.secret_secure_value USING btree (namespace, active, updated);


--
-- Name: IDX_team_member_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_member_org_id" ON public.team_member USING btree (org_id);


--
-- Name: IDX_team_member_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_member_team_id" ON public.team_member USING btree (team_id);


--
-- Name: IDX_team_member_user_id_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_member_user_id_org_id" ON public.team_member USING btree (user_id, org_id);


--
-- Name: IDX_team_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_org_id" ON public.team USING btree (org_id);


--
-- Name: IDX_team_role_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_role_org_id" ON public.team_role USING btree (org_id);


--
-- Name: IDX_team_role_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_team_role_team_id" ON public.team_role USING btree (team_id);


--
-- Name: IDX_temp_user_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_temp_user_code" ON public.temp_user USING btree (code);


--
-- Name: IDX_temp_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_temp_user_email" ON public.temp_user USING btree (email);


--
-- Name: IDX_temp_user_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_temp_user_org_id" ON public.temp_user USING btree (org_id);


--
-- Name: IDX_temp_user_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_temp_user_status" ON public.temp_user USING btree (status);


--
-- Name: IDX_user_auth_auth_module_auth_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_auth_auth_module_auth_id" ON public.user_auth USING btree (auth_module, auth_id);


--
-- Name: IDX_user_auth_token_revoked_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_auth_token_revoked_at" ON public.user_auth_token USING btree (revoked_at);


--
-- Name: IDX_user_auth_token_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_auth_token_user_id" ON public.user_auth_token USING btree (user_id);


--
-- Name: IDX_user_auth_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_auth_user_id" ON public.user_auth USING btree (user_id);


--
-- Name: IDX_user_is_service_account_last_seen_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_is_service_account_last_seen_at" ON public."user" USING btree (is_service_account, last_seen_at);


--
-- Name: IDX_user_login_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_login_email" ON public."user" USING btree (login, email);


--
-- Name: IDX_user_role_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_role_org_id" ON public.user_role USING btree (org_id);


--
-- Name: IDX_user_role_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_role_user_id" ON public.user_role USING btree (user_id);


--
-- Name: UQE_alert_configuration_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_configuration_org_id" ON public.alert_configuration USING btree (org_id);


--
-- Name: UQE_alert_image_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_image_token" ON public.alert_image USING btree (token);


--
-- Name: UQE_alert_notification_org_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_notification_org_id_uid" ON public.alert_notification USING btree (org_id, uid);


--
-- Name: UQE_alert_notification_state_org_id_alert_id_notifier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_notification_state_org_id_alert_id_notifier_id" ON public.alert_notification_state USING btree (org_id, alert_id, notifier_id);


--
-- Name: UQE_alert_rule_guid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_rule_guid" ON public.alert_rule USING btree (guid);


--
-- Name: UQE_alert_rule_org_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_rule_org_id_uid" ON public.alert_rule USING btree (org_id, uid);


--
-- Name: UQE_alert_rule_state_org_id_rule_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_rule_state_org_id_rule_uid" ON public.alert_rule_state USING btree (org_id, rule_uid);


--
-- Name: UQE_alert_rule_tag_alert_id_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_rule_tag_alert_id_tag_id" ON public.alert_rule_tag USING btree (alert_id, tag_id);


--
-- Name: UQE_alert_rule_version_rule_guid_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_rule_version_rule_guid_version" ON public.alert_rule_version USING btree (rule_guid, version);


--
-- Name: UQE_alert_rule_version_rule_org_id_rule_uid_rule_guid_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_alert_rule_version_rule_org_id_rule_uid_rule_guid_version" ON public.alert_rule_version USING btree (rule_org_id, rule_uid, rule_guid, version);


--
-- Name: UQE_annotation_tag_annotation_id_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_annotation_tag_annotation_id_tag_id" ON public.annotation_tag USING btree (annotation_id, tag_id);


--
-- Name: UQE_anon_device_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_anon_device_device_id" ON public.anon_device USING btree (device_id);


--
-- Name: UQE_api_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_api_key_key" ON public.api_key USING btree (key);


--
-- Name: UQE_api_key_org_id_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_api_key_org_id_name" ON public.api_key USING btree (org_id, name);


--
-- Name: UQE_builtin_role_org_id_role_id_role; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_builtin_role_org_id_role_id_role" ON public.builtin_role USING btree (org_id, role_id, role);


--
-- Name: UQE_cache_data_cache_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_cache_data_cache_key" ON public.cache_data USING btree (cache_key);


--
-- Name: UQE_cloud_migration_session_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_cloud_migration_session_uid" ON public.cloud_migration_session USING btree (uid);


--
-- Name: UQE_cloud_migration_snapshot_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_cloud_migration_snapshot_uid" ON public.cloud_migration_snapshot USING btree (uid);


--
-- Name: UQE_dashboard_acl_dashboard_id_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_dashboard_acl_dashboard_id_team_id" ON public.dashboard_acl USING btree (dashboard_id, team_id);


--
-- Name: UQE_dashboard_acl_dashboard_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_dashboard_acl_dashboard_id_user_id" ON public.dashboard_acl USING btree (dashboard_id, user_id);


--
-- Name: UQE_dashboard_org_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_dashboard_org_id_uid" ON public.dashboard USING btree (org_id, uid);


--
-- Name: UQE_dashboard_public_config_access_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_dashboard_public_config_access_token" ON public.dashboard_public USING btree (access_token);


--
-- Name: UQE_dashboard_public_config_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_dashboard_public_config_uid" ON public.dashboard_public USING btree (uid);


--
-- Name: UQE_dashboard_snapshot_delete_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_dashboard_snapshot_delete_key" ON public.dashboard_snapshot USING btree (delete_key);


--
-- Name: UQE_dashboard_snapshot_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_dashboard_snapshot_key" ON public.dashboard_snapshot USING btree (key);


--
-- Name: UQE_dashboard_version_dashboard_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_dashboard_version_dashboard_id_version" ON public.dashboard_version USING btree (dashboard_id, version);


--
-- Name: UQE_data_source_org_id_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_data_source_org_id_name" ON public.data_source USING btree (org_id, name);


--
-- Name: UQE_data_source_org_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_data_source_org_id_uid" ON public.data_source USING btree (org_id, uid);


--
-- Name: UQE_folder_org_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_folder_org_id_uid" ON public.folder USING btree (org_id, uid);


--
-- Name: UQE_kv_store_org_id_namespace_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_kv_store_org_id_namespace_key" ON public.kv_store USING btree (org_id, namespace, key);


--
-- Name: UQE_library_element_connection_element_id_kind_connection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_library_element_connection_element_id_kind_connection_id" ON public.library_element_connection USING btree (element_id, kind, connection_id);


--
-- Name: UQE_library_element_org_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_library_element_org_id_uid" ON public.library_element USING btree (org_id, uid);


--
-- Name: UQE_ngalert_configuration_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_ngalert_configuration_org_id" ON public.ngalert_configuration USING btree (org_id);


--
-- Name: UQE_org_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_org_name" ON public.org USING btree (name);


--
-- Name: UQE_org_user_org_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_org_user_org_id_user_id" ON public.org_user USING btree (org_id, user_id);


--
-- Name: UQE_permission_action_scope_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_permission_action_scope_role_id" ON public.permission USING btree (action, scope, role_id);


--
-- Name: UQE_plugin_setting_org_id_plugin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_plugin_setting_org_id_plugin_id" ON public.plugin_setting USING btree (org_id, plugin_id);


--
-- Name: UQE_provenance_type_record_type_record_key_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_provenance_type_record_type_record_key_org_id" ON public.provenance_type USING btree (record_type, record_key, org_id);


--
-- Name: UQE_query_history_star_user_id_query_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_query_history_star_user_id_query_uid" ON public.query_history_star USING btree (user_id, query_uid);


--
-- Name: UQE_quota_org_id_user_id_target; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_quota_org_id_user_id_target" ON public.quota USING btree (org_id, user_id, target);


--
-- Name: UQE_resource_history_namespace_group_name_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_resource_history_namespace_group_name_version" ON public.resource_history USING btree (namespace, "group", resource, name, resource_version);


--
-- Name: UQE_resource_last_import_time_last_import_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UQE_resource_last_import_time_last_import_time" ON public.resource_last_import_time USING btree (last_import_time);


--
-- Name: UQE_resource_namespace_group_resource_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_resource_namespace_group_resource_name" ON public.resource USING btree (namespace, "group", resource, name);


--
-- Name: UQE_role_org_id_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_role_org_id_name" ON public.role USING btree (org_id, name);


--
-- Name: UQE_role_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_role_uid" ON public.role USING btree (uid);


--
-- Name: UQE_secret_keeper_namespace_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_secret_keeper_namespace_name" ON public.secret_keeper USING btree (namespace, name);


--
-- Name: UQE_secret_secure_value_namespace_name_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_secret_secure_value_namespace_name_version" ON public.secret_secure_value USING btree (namespace, name, version);


--
-- Name: UQE_secret_secure_value_namespace_name_version_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_secret_secure_value_namespace_name_version_active" ON public.secret_secure_value USING btree (namespace, name, version, active);


--
-- Name: UQE_seed_assignment_builtin_role_action_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_seed_assignment_builtin_role_action_scope" ON public.seed_assignment USING btree (builtin_role, action, scope);


--
-- Name: UQE_seed_assignment_builtin_role_role_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_seed_assignment_builtin_role_role_name" ON public.seed_assignment USING btree (builtin_role, role_name);


--
-- Name: UQE_server_lock_operation_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_server_lock_operation_uid" ON public.server_lock USING btree (operation_uid);


--
-- Name: UQE_short_url_org_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_short_url_org_id_uid" ON public.short_url USING btree (org_id, uid);


--
-- Name: UQE_signing_key_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_signing_key_key_id" ON public.signing_key USING btree (key_id);


--
-- Name: UQE_star_user_id_dashboard_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_star_user_id_dashboard_id" ON public.star USING btree (user_id, dashboard_id);


--
-- Name: UQE_star_user_id_dashboard_uid_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_star_user_id_dashboard_uid_org_id" ON public.star USING btree (user_id, dashboard_uid, org_id);


--
-- Name: UQE_tag_key_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_tag_key_value" ON public.tag USING btree (key, value);


--
-- Name: UQE_team_member_org_id_team_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_team_member_org_id_team_id_user_id" ON public.team_member USING btree (org_id, team_id, user_id);


--
-- Name: UQE_team_member_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_team_member_uid" ON public.team_member USING btree (uid);


--
-- Name: UQE_team_org_id_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_team_org_id_name" ON public.team USING btree (org_id, name);


--
-- Name: UQE_team_org_id_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_team_org_id_uid" ON public.team USING btree (org_id, uid);


--
-- Name: UQE_team_role_org_id_team_id_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_team_role_org_id_team_id_role_id" ON public.team_role USING btree (org_id, team_id, role_id);


--
-- Name: UQE_user_auth_token_auth_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_user_auth_token_auth_token" ON public.user_auth_token USING btree (auth_token);


--
-- Name: UQE_user_auth_token_prev_auth_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_user_auth_token_prev_auth_token" ON public.user_auth_token USING btree (prev_auth_token);


--
-- Name: UQE_user_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_user_email" ON public."user" USING btree (email);


--
-- Name: UQE_user_login; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_user_login" ON public."user" USING btree (login);


--
-- Name: UQE_user_role_org_id_user_id_role_id_group_mapping_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_user_role_org_id_user_id_role_id_group_mapping_uid" ON public.user_role USING btree (org_id, user_id, role_id, group_mapping_uid);


--
-- Name: UQE_user_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UQE_user_uid" ON public."user" USING btree (uid);


--
-- PostgreSQL database dump complete
--


