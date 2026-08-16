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
-- Name: api_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_clients (
    id character varying(32) NOT NULL,
    name character varying(32) NOT NULL,
    secret character varying(32) NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.applications (
    id uuid NOT NULL,
    user_id character varying(32) DEFAULT ''::character varying NOT NULL,
    password text DEFAULT ''::text NOT NULL,
    version character varying(16) DEFAULT ''::character varying NOT NULL,
    platform integer NOT NULL,
    ip inet,
    type integer NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    last_access_time bigint DEFAULT '0'::bigint
);


--
-- Name: backup_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backup_items (
    id integer NOT NULL,
    type integer NOT NULL,
    key text NOT NULL,
    user_id character varying(32) DEFAULT ''::character varying NOT NULL,
    content bytea NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: backup_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.backup_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: backup_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.backup_items_id_seq OWNED BY public.backup_items.id;


--
-- Name: changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.changes (
    counter integer NOT NULL,
    id character varying(32) NOT NULL,
    item_type integer NOT NULL,
    item_id character varying(32) NOT NULL,
    item_name text DEFAULT ''::text NOT NULL,
    type integer NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    previous_item text DEFAULT ''::text NOT NULL,
    user_id character varying(32) DEFAULT ''::character varying NOT NULL
);


--
-- Name: changes_2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.changes_2 (
    counter bigint NOT NULL,
    id character varying(32) NOT NULL,
    item_id character varying(32) NOT NULL,
    user_id character varying(32) DEFAULT ''::character varying NOT NULL,
    item_name text DEFAULT ''::text NOT NULL,
    previous_share_id character varying(32) DEFAULT ''::character varying NOT NULL,
    item_type integer NOT NULL,
    type integer NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: changes_2_counter_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.changes_2_counter_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changes_2_counter_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.changes_2_counter_seq OWNED BY public.changes_2.counter;


--
-- Name: changes_counter_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.changes_counter_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: changes_counter_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.changes_counter_seq OWNED BY public.changes.counter;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id integer NOT NULL,
    recipient_name text DEFAULT ''::text NOT NULL,
    recipient_email text DEFAULT ''::text NOT NULL,
    recipient_id character varying(32) DEFAULT ''::character varying NOT NULL,
    sender_id integer NOT NULL,
    subject character varying(128) NOT NULL,
    body text NOT NULL,
    sent_time bigint DEFAULT '0'::bigint NOT NULL,
    sent_success integer DEFAULT 0 NOT NULL,
    error text DEFAULT ''::text NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    key text DEFAULT ''::text NOT NULL
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id uuid NOT NULL,
    counter integer NOT NULL,
    type integer NOT NULL,
    name character varying(32) DEFAULT ''::character varying NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: events_counter_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_counter_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_counter_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_counter_seq OWNED BY public.events.counter;


--
-- Name: files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.files (
    id character varying(32) NOT NULL,
    owner_id character varying(32) NOT NULL,
    name text NOT NULL,
    content bytea DEFAULT '\x'::bytea NOT NULL,
    mime_type character varying(128) DEFAULT 'application/octet-stream'::character varying NOT NULL,
    size integer DEFAULT 0 NOT NULL,
    is_directory integer DEFAULT 0 NOT NULL,
    is_root integer DEFAULT 0 NOT NULL,
    parent_id character varying(32) DEFAULT ''::character varying NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    source_file_id character varying(32) DEFAULT ''::character varying NOT NULL,
    content_type integer DEFAULT 1 NOT NULL,
    content_id character varying(32) DEFAULT ''::character varying NOT NULL
);


--
-- Name: item_resources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_resources (
    id integer NOT NULL,
    item_id character varying(32) NOT NULL,
    resource_id character varying(32) NOT NULL
);


--
-- Name: item_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.item_resources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.item_resources_id_seq OWNED BY public.item_resources.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id character varying(32) NOT NULL,
    name text NOT NULL,
    mime_type character varying(128) DEFAULT 'application/octet-stream'::character varying NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    content bytea DEFAULT '\x'::bytea NOT NULL,
    content_size integer DEFAULT 0 NOT NULL,
    jop_id character varying(32) DEFAULT ''::character varying NOT NULL,
    jop_parent_id character varying(32) DEFAULT ''::character varying NOT NULL,
    jop_share_id character varying(32) DEFAULT ''::character varying NOT NULL,
    jop_type integer DEFAULT 0 NOT NULL,
    jop_encryption_applied integer DEFAULT 0 NOT NULL,
    jop_updated_time bigint DEFAULT '0'::bigint NOT NULL,
    owner_id character varying(32) NOT NULL,
    content_storage_id integer NOT NULL
);


--
-- Name: key_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.key_values (
    id integer NOT NULL,
    key text NOT NULL,
    type integer NOT NULL,
    value text NOT NULL
);


--
-- Name: key_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.key_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.key_values_id_seq OWNED BY public.key_values.id;


--
-- Name: knex_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knex_migrations (
    id integer NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


--
-- Name: knex_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knex_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knex_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knex_migrations_id_seq OWNED BY public.knex_migrations.id;


--
-- Name: knex_migrations_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knex_migrations_lock (
    index integer NOT NULL,
    is_locked integer
);


--
-- Name: knex_migrations_lock_index_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knex_migrations_lock_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knex_migrations_lock_index_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knex_migrations_lock_index_seq OWNED BY public.knex_migrations_lock.index;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id character varying(32) NOT NULL,
    owner_id character varying(32) NOT NULL,
    level integer NOT NULL,
    key text NOT NULL,
    message text NOT NULL,
    read integer DEFAULT 0 NOT NULL,
    "canBeDismissed" integer DEFAULT 1 NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: recovery_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recovery_codes (
    id uuid NOT NULL,
    user_id character varying(32) DEFAULT ''::character varying NOT NULL,
    code character varying(16) DEFAULT ''::character varying NOT NULL,
    is_used smallint DEFAULT '1'::smallint NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(32) NOT NULL,
    user_id character varying(32) NOT NULL,
    auth_code character varying(32) DEFAULT ''::character varying NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    application_id uuid
);


--
-- Name: share_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.share_users (
    id character varying(32) NOT NULL,
    share_id character varying(32) NOT NULL,
    user_id character varying(32) NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    master_key text DEFAULT ''::text NOT NULL
);


--
-- Name: shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shares (
    id character varying(32) NOT NULL,
    owner_id character varying(32) NOT NULL,
    item_id character varying(32) NOT NULL,
    type integer NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    folder_id character varying(32) DEFAULT ''::character varying NOT NULL,
    note_id character varying(32) DEFAULT ''::character varying NOT NULL,
    master_key_id character varying(32) DEFAULT ''::character varying NOT NULL,
    recursive smallint DEFAULT '0'::smallint
);


--
-- Name: storages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storages (
    id integer NOT NULL,
    connection_string text NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: storages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.storages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: storages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.storages_id_seq OWNED BY public.storages.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    user_id character varying(32) NOT NULL,
    stripe_user_id character varying(64) NOT NULL,
    stripe_subscription_id character varying(64) NOT NULL,
    last_payment_time bigint NOT NULL,
    last_payment_failed_time bigint DEFAULT '0'::bigint NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    is_deleted smallint DEFAULT '0'::smallint
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: task_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_states (
    id integer NOT NULL,
    task_id integer NOT NULL,
    running smallint DEFAULT '0'::smallint NOT NULL,
    enabled smallint DEFAULT '1'::smallint NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: task_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.task_states_id_seq OWNED BY public.task_states.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    id integer NOT NULL,
    value character varying(32) NOT NULL,
    user_id character varying(32) DEFAULT ''::character varying NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: user_deletions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_deletions (
    id integer NOT NULL,
    user_id character varying(32) NOT NULL,
    process_data smallint DEFAULT '0'::smallint NOT NULL,
    process_account smallint DEFAULT '0'::smallint NOT NULL,
    scheduled_time bigint NOT NULL,
    start_time bigint DEFAULT '0'::bigint NOT NULL,
    end_time bigint DEFAULT '0'::bigint NOT NULL,
    success integer DEFAULT 0 NOT NULL,
    error text DEFAULT ''::text NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: user_deletions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_deletions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_deletions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_deletions_id_seq OWNED BY public.user_deletions.id;


--
-- Name: user_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_flags (
    id integer NOT NULL,
    user_id character varying(32) NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: user_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_flags_id_seq OWNED BY public.user_flags.id;


--
-- Name: user_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_items (
    id integer NOT NULL,
    user_id character varying(32) NOT NULL,
    item_id character varying(32) NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL
);


--
-- Name: user_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_items_id_seq OWNED BY public.user_items.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying(32) NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    full_name text DEFAULT ''::text NOT NULL,
    is_admin integer DEFAULT 0 NOT NULL,
    updated_time bigint NOT NULL,
    created_time bigint NOT NULL,
    email_confirmed integer DEFAULT 0 NOT NULL,
    must_set_password integer DEFAULT 0 NOT NULL,
    account_type integer DEFAULT 0 NOT NULL,
    can_upload integer DEFAULT 1 NOT NULL,
    max_item_size integer,
    can_share_folder smallint,
    can_share_note smallint,
    max_total_item_size bigint,
    total_item_size bigint DEFAULT '0'::bigint NOT NULL,
    enabled smallint DEFAULT '1'::smallint,
    disabled_time bigint DEFAULT '0'::bigint NOT NULL,
    can_receive_folder smallint,
    totp_secret character varying(255) DEFAULT ''::character varying NOT NULL,
    is_external integer DEFAULT 0 NOT NULL,
    sso_auth_code character varying(255) DEFAULT ''::character varying NOT NULL,
    sso_auth_code_expire_at bigint DEFAULT '0'::bigint NOT NULL
);


--
-- Name: backup_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backup_items ALTER COLUMN id SET DEFAULT nextval('public.backup_items_id_seq'::regclass);


--
-- Name: changes counter; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes ALTER COLUMN counter SET DEFAULT nextval('public.changes_counter_seq'::regclass);


--
-- Name: changes_2 counter; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes_2 ALTER COLUMN counter SET DEFAULT nextval('public.changes_2_counter_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- Name: events counter; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN counter SET DEFAULT nextval('public.events_counter_seq'::regclass);


--
-- Name: item_resources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_resources ALTER COLUMN id SET DEFAULT nextval('public.item_resources_id_seq'::regclass);


--
-- Name: key_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_values ALTER COLUMN id SET DEFAULT nextval('public.key_values_id_seq'::regclass);


--
-- Name: knex_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations ALTER COLUMN id SET DEFAULT nextval('public.knex_migrations_id_seq'::regclass);


--
-- Name: knex_migrations_lock index; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations_lock ALTER COLUMN index SET DEFAULT nextval('public.knex_migrations_lock_index_seq'::regclass);


--
-- Name: storages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages ALTER COLUMN id SET DEFAULT nextval('public.storages_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: task_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_states ALTER COLUMN id SET DEFAULT nextval('public.task_states_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: user_deletions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_deletions ALTER COLUMN id SET DEFAULT nextval('public.user_deletions_id_seq'::regclass);


--
-- Name: user_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_flags ALTER COLUMN id SET DEFAULT nextval('public.user_flags_id_seq'::regclass);


--
-- Name: user_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_items ALTER COLUMN id SET DEFAULT nextval('public.user_items_id_seq'::regclass);


--
-- Name: api_clients api_clients_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_clients
    ADD CONSTRAINT api_clients_id_unique UNIQUE (id);


--
-- Name: api_clients api_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_clients
    ADD CONSTRAINT api_clients_pkey PRIMARY KEY (id);


--
-- Name: applications applications_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_id_unique UNIQUE (id);


--
-- Name: backup_items backup_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backup_items
    ADD CONSTRAINT backup_items_pkey PRIMARY KEY (id);


--
-- Name: changes_2 changes_2_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes_2
    ADD CONSTRAINT changes_2_id_unique UNIQUE (id);


--
-- Name: changes_2 changes_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes_2
    ADD CONSTRAINT changes_2_pkey PRIMARY KEY (counter);


--
-- Name: changes_2 changes_2_user_id_counter_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes_2
    ADD CONSTRAINT changes_2_user_id_counter_unique UNIQUE (user_id, counter);


--
-- Name: changes changes_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes
    ADD CONSTRAINT changes_id_unique UNIQUE (id);


--
-- Name: changes changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.changes
    ADD CONSTRAINT changes_pkey PRIMARY KEY (counter);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: events events_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_id_unique UNIQUE (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (counter);


--
-- Name: files files_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_id_unique UNIQUE (id);


--
-- Name: files files_parent_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_parent_id_name_unique UNIQUE (parent_id, name);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: item_resources item_resources_item_id_resource_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_resources
    ADD CONSTRAINT item_resources_item_id_resource_id_unique UNIQUE (item_id, resource_id);


--
-- Name: item_resources item_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_resources
    ADD CONSTRAINT item_resources_pkey PRIMARY KEY (id);


--
-- Name: items items_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_unique UNIQUE (id);


--
-- Name: items items_name_owner_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_name_owner_id_unique UNIQUE (name, owner_id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: key_values key_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_values
    ADD CONSTRAINT key_values_pkey PRIMARY KEY (id);


--
-- Name: knex_migrations_lock knex_migrations_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations_lock
    ADD CONSTRAINT knex_migrations_lock_pkey PRIMARY KEY (index);


--
-- Name: knex_migrations knex_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations
    ADD CONSTRAINT knex_migrations_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_id_unique UNIQUE (id);


--
-- Name: notifications notifications_owner_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_owner_id_key_unique UNIQUE (owner_id, key);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: recovery_codes recovery_codes_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recovery_codes
    ADD CONSTRAINT recovery_codes_id_unique UNIQUE (id);


--
-- Name: sessions sessions_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_id_unique UNIQUE (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: share_users share_users_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_users
    ADD CONSTRAINT share_users_id_unique UNIQUE (id);


--
-- Name: share_users share_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_users
    ADD CONSTRAINT share_users_pkey PRIMARY KEY (id);


--
-- Name: share_users share_users_share_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.share_users
    ADD CONSTRAINT share_users_share_id_user_id_unique UNIQUE (share_id, user_id);


--
-- Name: shares shares_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_id_unique UNIQUE (id);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: storages storages_connection_string_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages
    ADD CONSTRAINT storages_connection_string_unique UNIQUE (connection_string);


--
-- Name: storages storages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storages
    ADD CONSTRAINT storages_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: task_states task_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_states
    ADD CONSTRAINT task_states_pkey PRIMARY KEY (id);


--
-- Name: task_states task_states_task_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_states
    ADD CONSTRAINT task_states_task_id_unique UNIQUE (task_id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: user_deletions user_deletions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_deletions
    ADD CONSTRAINT user_deletions_pkey PRIMARY KEY (id);


--
-- Name: user_deletions user_deletions_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_deletions
    ADD CONSTRAINT user_deletions_user_id_unique UNIQUE (user_id);


--
-- Name: user_flags user_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_flags
    ADD CONSTRAINT user_flags_pkey PRIMARY KEY (id);


--
-- Name: user_flags user_flags_user_id_type_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_flags
    ADD CONSTRAINT user_flags_user_id_type_unique UNIQUE (user_id, type);


--
-- Name: user_items user_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_items
    ADD CONSTRAINT user_items_pkey PRIMARY KEY (id);


--
-- Name: user_items user_items_user_id_item_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_items
    ADD CONSTRAINT user_items_user_id_item_id_unique UNIQUE (user_id, item_id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_id_unique UNIQUE (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: applications_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX applications_user_id_index ON public.applications USING btree (user_id);


--
-- Name: changes_2_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX changes_2_item_id_index ON public.changes_2 USING btree (item_id);


--
-- Name: changes_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX changes_id_index ON public.changes USING btree (id);


--
-- Name: changes_item_id_counter_type2_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX changes_item_id_counter_type2_index ON public.changes USING btree (item_id, counter) WHERE (type = 2);


--
-- Name: changes_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX changes_item_id_index ON public.changes USING btree (item_id);


--
-- Name: changes_user_id_counter_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX changes_user_id_counter_index ON public.changes USING btree (user_id, counter);


--
-- Name: changes_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX changes_user_id_index ON public.changes USING btree (user_id);


--
-- Name: emails_sent_success_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX emails_sent_success_index ON public.emails USING btree (sent_success);


--
-- Name: emails_sent_time_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX emails_sent_time_index ON public.emails USING btree (sent_time);


--
-- Name: events_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_name_index ON public.events USING btree (name);


--
-- Name: events_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_type_index ON public.events USING btree (type);


--
-- Name: files_owner_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX files_owner_id_index ON public.files USING btree (owner_id);


--
-- Name: files_parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX files_parent_id_index ON public.files USING btree (parent_id);


--
-- Name: files_source_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX files_source_file_id_index ON public.files USING btree (source_file_id);


--
-- Name: item_resources_item_id_resource_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX item_resources_item_id_resource_id_index ON public.item_resources USING btree (item_id, resource_id);


--
-- Name: items_content_storage_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX items_content_storage_id_index ON public.items USING btree (content_storage_id);


--
-- Name: items_jop_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX items_jop_id_index ON public.items USING btree (jop_id);


--
-- Name: items_jop_parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX items_jop_parent_id_index ON public.items USING btree (jop_parent_id);


--
-- Name: items_jop_share_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX items_jop_share_id_index ON public.items USING btree (jop_share_id);


--
-- Name: items_jop_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX items_jop_type_index ON public.items USING btree (jop_type);


--
-- Name: items_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX items_name_index ON public.items USING btree (name);


--
-- Name: key_values_key_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX key_values_key_index ON public.key_values USING btree (key);


--
-- Name: sessions_application_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_application_id_index ON public.sessions USING btree (application_id);


--
-- Name: shares_folder_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shares_folder_id_index ON public.shares USING btree (folder_id);


--
-- Name: shares_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shares_item_id_index ON public.shares USING btree (item_id);


--
-- Name: shares_note_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shares_note_id_index ON public.shares USING btree (note_id);


--
-- Name: tokens_value_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tokens_value_user_id_index ON public.tokens USING btree (value, user_id);


--
-- Name: user_items_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_items_item_id_index ON public.user_items USING btree (item_id);


--
-- Name: user_items_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_items_user_id_index ON public.user_items USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_email_index ON public.users USING btree (email);


--
-- PostgreSQL database dump complete
--


