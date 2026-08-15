--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

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
-- Name: entry_sorting_direction; Type: TYPE; Schema: public; Owner: miniflux
--

CREATE TYPE public.entry_sorting_direction AS ENUM (
    'asc',
    'desc'
);



--
-- Name: entry_sorting_order; Type: TYPE; Schema: public; Owner: miniflux
--

CREATE TYPE public.entry_sorting_order AS ENUM (
    'published_at',
    'created_at'
);



--
-- Name: entry_status; Type: TYPE; Schema: public; Owner: miniflux
--

CREATE TYPE public.entry_status AS ENUM (
    'unread',
    'read',
    'removed'
);



--
-- Name: linktaco_link_visibility; Type: TYPE; Schema: public; Owner: miniflux
--

CREATE TYPE public.linktaco_link_visibility AS ENUM (
    'PUBLIC',
    'PRIVATE'
);



--
-- Name: webapp_display_mode; Type: TYPE; Schema: public; Owner: miniflux
--

CREATE TYPE public.webapp_display_mode AS ENUM (
    'fullscreen',
    'standalone',
    'minimal-ui',
    'browser'
);



SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acme_cache; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.acme_cache (
    key character varying(400) NOT NULL,
    data bytea NOT NULL,
    updated_at timestamp with time zone NOT NULL
);



--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.api_keys (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token text NOT NULL,
    description text NOT NULL,
    last_used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);



--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: miniflux
--

CREATE SEQUENCE public.api_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: miniflux
--

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title text NOT NULL,
    hide_globally boolean DEFAULT false NOT NULL
);



--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: miniflux
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: miniflux
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: enclosures; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.enclosures (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    entry_id bigint NOT NULL,
    url text NOT NULL,
    size bigint DEFAULT 0,
    mime_type text DEFAULT ''::text,
    media_progression integer DEFAULT 0
);



--
-- Name: enclosures_id_seq; Type: SEQUENCE; Schema: public; Owner: miniflux
--

CREATE SEQUENCE public.enclosures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: enclosures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: miniflux
--

ALTER SEQUENCE public.enclosures_id_seq OWNED BY public.enclosures.id;


--
-- Name: entries; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.entries (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    feed_id bigint NOT NULL,
    hash text NOT NULL,
    published_at timestamp with time zone NOT NULL,
    title text NOT NULL,
    url text NOT NULL,
    author text,
    content text,
    status public.entry_status DEFAULT 'unread'::public.entry_status,
    starred boolean DEFAULT false,
    comments_url text DEFAULT ''::text,
    document_vectors tsvector,
    changed_at timestamp with time zone NOT NULL,
    share_code text DEFAULT ''::text NOT NULL,
    reading_time integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tags text[] DEFAULT '{}'::text[],
    language text DEFAULT ''::text NOT NULL
);



--
-- Name: entries_id_seq; Type: SEQUENCE; Schema: public; Owner: miniflux
--

CREATE SEQUENCE public.entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: miniflux
--

ALTER SEQUENCE public.entries_id_seq OWNED BY public.entries.id;


--
-- Name: entry_tombstones; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.entry_tombstones (
    feed_id bigint NOT NULL,
    hash text NOT NULL,
    deleted_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT entry_tombstones_hash_check CHECK ((hash <> ''::text))
);



--
-- Name: feed_icons; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.feed_icons (
    feed_id bigint NOT NULL,
    icon_id bigint NOT NULL
);



--
-- Name: feeds; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.feeds (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    title text NOT NULL,
    feed_url text NOT NULL,
    site_url text NOT NULL,
    checked_at timestamp with time zone DEFAULT now(),
    etag_header text DEFAULT ''::text,
    last_modified_header text DEFAULT ''::text,
    parsing_error_msg text DEFAULT ''::text,
    parsing_error_count integer DEFAULT 0,
    scraper_rules text DEFAULT ''::text,
    rewrite_rules text DEFAULT ''::text,
    crawler boolean DEFAULT false,
    username text DEFAULT ''::text,
    password text DEFAULT ''::text,
    user_agent text DEFAULT ''::text,
    disabled boolean DEFAULT false,
    next_check_at timestamp with time zone DEFAULT now(),
    ignore_http_cache boolean DEFAULT false,
    fetch_via_proxy boolean DEFAULT false,
    blocklist_rules text DEFAULT ''::text NOT NULL,
    keeplist_rules text DEFAULT ''::text NOT NULL,
    allow_self_signed_certificates boolean DEFAULT false NOT NULL,
    cookie text DEFAULT ''::text,
    hide_globally boolean DEFAULT false NOT NULL,
    url_rewrite_rules text DEFAULT ''::text NOT NULL,
    no_media_player boolean DEFAULT false,
    apprise_service_urls text DEFAULT ''::text,
    disable_http2 boolean DEFAULT false,
    description text DEFAULT ''::text,
    ntfy_enabled boolean DEFAULT false,
    ntfy_priority integer DEFAULT 3,
    webhook_url text DEFAULT ''::text,
    pushover_enabled boolean DEFAULT false,
    pushover_priority integer DEFAULT 0,
    ntfy_topic text DEFAULT ''::text,
    proxy_url text DEFAULT ''::text,
    block_filter_entry_rules text DEFAULT ''::text NOT NULL,
    keep_filter_entry_rules text DEFAULT ''::text NOT NULL,
    ignore_entry_updates boolean DEFAULT false,
    language text DEFAULT ''::text NOT NULL
);



--
-- Name: feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: miniflux
--

CREATE SEQUENCE public.feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: miniflux
--

ALTER SEQUENCE public.feeds_id_seq OWNED BY public.feeds.id;


--
-- Name: icons; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.icons (
    id bigint NOT NULL,
    hash text NOT NULL,
    mime_type text NOT NULL,
    content bytea NOT NULL,
    external_id text DEFAULT ''::text
);



--
-- Name: icons_id_seq; Type: SEQUENCE; Schema: public; Owner: miniflux
--

CREATE SEQUENCE public.icons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: icons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: miniflux
--

ALTER SEQUENCE public.icons_id_seq OWNED BY public.icons.id;


--
-- Name: integrations; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.integrations (
    user_id integer NOT NULL,
    pinboard_enabled boolean DEFAULT false,
    pinboard_token text DEFAULT ''::text,
    pinboard_tags text DEFAULT 'miniflux'::text,
    pinboard_mark_as_unread boolean DEFAULT false,
    instapaper_enabled boolean DEFAULT false,
    instapaper_username text DEFAULT ''::text,
    instapaper_password text DEFAULT ''::text,
    fever_enabled boolean DEFAULT false,
    fever_username text DEFAULT ''::text,
    fever_token text DEFAULT ''::text,
    wallabag_enabled boolean DEFAULT false,
    wallabag_url text DEFAULT ''::text,
    wallabag_client_id text DEFAULT ''::text,
    wallabag_client_secret text DEFAULT ''::text,
    wallabag_username text DEFAULT ''::text,
    wallabag_password text DEFAULT ''::text,
    nunux_keeper_enabled boolean DEFAULT false,
    nunux_keeper_url text DEFAULT ''::text,
    nunux_keeper_api_key text DEFAULT ''::text,
    telegram_bot_enabled boolean DEFAULT false,
    telegram_bot_token text DEFAULT ''::text,
    telegram_bot_chat_id text DEFAULT ''::text,
    googlereader_enabled boolean DEFAULT false,
    googlereader_username text DEFAULT ''::text,
    googlereader_password text DEFAULT ''::text,
    espial_enabled boolean DEFAULT false,
    espial_url text DEFAULT ''::text,
    espial_api_key text DEFAULT ''::text,
    espial_tags text DEFAULT 'miniflux'::text,
    linkding_enabled boolean DEFAULT false,
    linkding_url text DEFAULT ''::text,
    linkding_api_key text DEFAULT ''::text,
    wallabag_only_url boolean DEFAULT false,
    matrix_bot_enabled boolean DEFAULT false,
    matrix_bot_user text DEFAULT ''::text,
    matrix_bot_password text DEFAULT ''::text,
    matrix_bot_url text DEFAULT ''::text,
    matrix_bot_chat_id text DEFAULT ''::text,
    linkding_tags text DEFAULT ''::text,
    linkding_mark_as_unread boolean DEFAULT false,
    notion_enabled boolean DEFAULT false,
    notion_token text DEFAULT ''::text,
    notion_page_id text DEFAULT ''::text,
    readwise_enabled boolean DEFAULT false,
    readwise_api_key text DEFAULT ''::text,
    apprise_enabled boolean DEFAULT false,
    apprise_url text DEFAULT ''::text,
    apprise_services_url text DEFAULT ''::text,
    shiori_enabled boolean DEFAULT false,
    shiori_url text DEFAULT ''::text,
    shiori_username text DEFAULT ''::text,
    shiori_password text DEFAULT ''::text,
    shaarli_enabled boolean DEFAULT false,
    shaarli_url text DEFAULT ''::text,
    shaarli_api_secret text DEFAULT ''::text,
    webhook_enabled boolean DEFAULT false,
    webhook_url text DEFAULT ''::text,
    webhook_secret text DEFAULT ''::text,
    telegram_bot_topic_id integer,
    telegram_bot_disable_web_page_preview boolean DEFAULT false,
    telegram_bot_disable_notification boolean DEFAULT false,
    telegram_bot_disable_buttons boolean DEFAULT false,
    rssbridge_enabled boolean DEFAULT false,
    rssbridge_url text DEFAULT ''::text,
    omnivore_enabled boolean DEFAULT false,
    omnivore_api_key text DEFAULT ''::text,
    omnivore_url text DEFAULT ''::text,
    linkace_enabled boolean DEFAULT false,
    linkace_url text DEFAULT ''::text,
    linkace_api_key text DEFAULT ''::text,
    linkace_tags text DEFAULT ''::text,
    linkace_is_private boolean DEFAULT true,
    linkace_check_disabled boolean DEFAULT true,
    linkwarden_enabled boolean DEFAULT false,
    linkwarden_url text DEFAULT ''::text,
    linkwarden_api_key text DEFAULT ''::text,
    readeck_enabled boolean DEFAULT false,
    readeck_only_url boolean DEFAULT false,
    readeck_url text DEFAULT ''::text,
    readeck_api_key text DEFAULT ''::text,
    readeck_labels text DEFAULT ''::text,
    raindrop_enabled boolean DEFAULT false,
    raindrop_token text DEFAULT ''::text,
    raindrop_collection_id text DEFAULT ''::text,
    raindrop_tags text DEFAULT ''::text,
    betula_url text DEFAULT ''::text,
    betula_token text DEFAULT ''::text,
    betula_enabled boolean DEFAULT false,
    ntfy_enabled boolean DEFAULT false,
    ntfy_url text DEFAULT ''::text,
    ntfy_topic text DEFAULT ''::text,
    ntfy_api_token text DEFAULT ''::text,
    ntfy_username text DEFAULT ''::text,
    ntfy_password text DEFAULT ''::text,
    ntfy_icon_url text DEFAULT ''::text,
    cubox_enabled boolean DEFAULT false,
    cubox_api_link text DEFAULT ''::text,
    discord_enabled boolean DEFAULT false,
    discord_webhook_link text DEFAULT ''::text,
    ntfy_internal_links boolean DEFAULT false,
    slack_enabled boolean DEFAULT false,
    slack_webhook_link text DEFAULT ''::text,
    pushover_enabled boolean DEFAULT false,
    pushover_user text DEFAULT ''::text,
    pushover_token text DEFAULT ''::text,
    pushover_device text DEFAULT ''::text,
    pushover_prefix text DEFAULT ''::text,
    rssbridge_token text DEFAULT ''::text,
    karakeep_enabled boolean DEFAULT false,
    karakeep_api_key text DEFAULT ''::text,
    karakeep_url text DEFAULT ''::text,
    linktaco_enabled boolean DEFAULT false,
    linktaco_api_token text DEFAULT ''::text,
    linktaco_org_slug text DEFAULT ''::text,
    linktaco_tags text DEFAULT ''::text,
    linktaco_visibility public.linktaco_link_visibility DEFAULT 'PUBLIC'::public.linktaco_link_visibility,
    wallabag_tags text DEFAULT ''::text,
    archiveorg_enabled boolean DEFAULT false,
    karakeep_tags text DEFAULT ''::text,
    linkwarden_collection_id integer,
    readeck_push_enabled boolean DEFAULT false
);



--
-- Name: schema_version; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.schema_version (
    version text NOT NULL
);



--
-- Name: users; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password text,
    is_admin boolean DEFAULT false,
    language text DEFAULT 'en_US'::text,
    timezone text DEFAULT 'UTC'::text,
    theme text DEFAULT 'light_serif'::text,
    last_login_at timestamp with time zone,
    entry_direction public.entry_sorting_direction DEFAULT 'asc'::public.entry_sorting_direction,
    keyboard_shortcuts boolean DEFAULT true,
    entries_per_page integer DEFAULT 100,
    show_reading_time boolean DEFAULT true,
    entry_swipe boolean DEFAULT true,
    stylesheet text DEFAULT ''::text NOT NULL,
    google_id text DEFAULT ''::text NOT NULL,
    openid_connect_id text DEFAULT ''::text NOT NULL,
    display_mode public.webapp_display_mode DEFAULT 'standalone'::public.webapp_display_mode,
    entry_order public.entry_sorting_order DEFAULT 'published_at'::public.entry_sorting_order,
    default_reading_speed integer DEFAULT 265,
    cjk_reading_speed integer DEFAULT 500,
    default_home_page text DEFAULT 'unread'::text,
    categories_sorting_order text DEFAULT 'unread_count'::text NOT NULL,
    gesture_nav text DEFAULT 'tap'::text,
    mark_read_on_view boolean DEFAULT true,
    media_playback_rate numeric DEFAULT 1,
    block_filter_entry_rules text DEFAULT ''::text NOT NULL,
    keep_filter_entry_rules text DEFAULT ''::text NOT NULL,
    mark_read_on_media_player_completion boolean DEFAULT false,
    custom_js text DEFAULT ''::text NOT NULL,
    external_font_hosts text DEFAULT ''::text NOT NULL,
    always_open_external_links boolean DEFAULT false,
    open_external_links_in_new_tab boolean DEFAULT true
);



--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: miniflux
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: miniflux
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: web_sessions; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.web_sessions (
    id text NOT NULL,
    secret_hash bytea NOT NULL,
    user_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_agent text DEFAULT ''::text NOT NULL,
    ip inet,
    state jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT web_sessions_state_check CHECK ((jsonb_typeof(state) = 'object'::text))
);



--
-- Name: webauthn_credentials; Type: TABLE; Schema: public; Owner: miniflux
--

CREATE TABLE public.webauthn_credentials (
    handle bytea NOT NULL,
    cred_id bytea NOT NULL,
    user_id integer NOT NULL,
    public_key bytea NOT NULL,
    attestation_type character varying(255) NOT NULL,
    aaguid bytea,
    sign_count bigint,
    clone_warning boolean,
    name text DEFAULT ''::text NOT NULL,
    added_on timestamp with time zone DEFAULT now(),
    last_seen_on timestamp with time zone DEFAULT now(),
    backup_eligible boolean,
    backup_state boolean DEFAULT false NOT NULL
);



--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: enclosures id; Type: DEFAULT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.enclosures ALTER COLUMN id SET DEFAULT nextval('public.enclosures_id_seq'::regclass);


--
-- Name: entries id; Type: DEFAULT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.entries ALTER COLUMN id SET DEFAULT nextval('public.entries_id_seq'::regclass);


--
-- Name: feeds id; Type: DEFAULT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.feeds ALTER COLUMN id SET DEFAULT nextval('public.feeds_id_seq'::regclass);


--
-- Name: icons id; Type: DEFAULT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.icons ALTER COLUMN id SET DEFAULT nextval('public.icons_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: acme_cache acme_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.acme_cache
    ADD CONSTRAINT acme_cache_pkey PRIMARY KEY (key);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_token_key; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_token_key UNIQUE (token);


--
-- Name: api_keys api_keys_user_id_description_key; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_user_id_description_key UNIQUE (user_id, description);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_user_id_title_key; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_title_key UNIQUE (user_id, title);


--
-- Name: enclosures enclosures_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.enclosures
    ADD CONSTRAINT enclosures_pkey PRIMARY KEY (id);


--
-- Name: entries entries_feed_id_hash_key; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_feed_id_hash_key UNIQUE (feed_id, hash);


--
-- Name: entries entries_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (id);


--
-- Name: entry_tombstones entry_tombstones_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.entry_tombstones
    ADD CONSTRAINT entry_tombstones_pkey PRIMARY KEY (feed_id, hash);


--
-- Name: feed_icons feed_icons_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.feed_icons
    ADD CONSTRAINT feed_icons_pkey PRIMARY KEY (feed_id, icon_id);


--
-- Name: feeds feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.feeds
    ADD CONSTRAINT feeds_pkey PRIMARY KEY (id);


--
-- Name: feeds feeds_user_id_feed_url_key; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.feeds
    ADD CONSTRAINT feeds_user_id_feed_url_key UNIQUE (user_id, feed_url);


--
-- Name: icons icons_hash_key; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.icons
    ADD CONSTRAINT icons_hash_key UNIQUE (hash);


--
-- Name: icons icons_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.icons
    ADD CONSTRAINT icons_pkey PRIMARY KEY (id);


--
-- Name: integrations integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT integrations_pkey PRIMARY KEY (user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: web_sessions web_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.web_sessions
    ADD CONSTRAINT web_sessions_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_cred_id_key; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_cred_id_key UNIQUE (cred_id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (handle);


--
-- Name: document_vectors_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX document_vectors_idx ON public.entries USING gin (document_vectors);


--
-- Name: enclosures_entry_id_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX enclosures_entry_id_idx ON public.enclosures USING btree (entry_id);


--
-- Name: enclosures_user_entry_url_unique_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE UNIQUE INDEX enclosures_user_entry_url_unique_idx ON public.enclosures USING btree (user_id, entry_id, encode(sha256((url)::bytea), 'hex'::text));


--
-- Name: entries_feed_id_status_hash_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_feed_id_status_hash_idx ON public.entries USING btree (feed_id, status, hash);


--
-- Name: entries_id_user_status_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_id_user_status_idx ON public.entries USING btree (id, user_id, status);


--
-- Name: entries_share_code_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE UNIQUE INDEX entries_share_code_idx ON public.entries USING btree (share_code) WHERE (share_code <> ''::text);


--
-- Name: entries_user_feed_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_user_feed_idx ON public.entries USING btree (user_id, feed_id);


--
-- Name: entries_user_id_status_starred_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_user_id_status_starred_idx ON public.entries USING btree (user_id, status, starred);


--
-- Name: entries_user_status_changed_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_user_status_changed_idx ON public.entries USING btree (user_id, status, changed_at);


--
-- Name: entries_user_status_changed_published_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_user_status_changed_published_idx ON public.entries USING btree (user_id, status, changed_at, published_at);


--
-- Name: entries_user_status_created_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_user_status_created_idx ON public.entries USING btree (user_id, status, created_at);


--
-- Name: entries_user_status_feed_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_user_status_feed_idx ON public.entries USING btree (user_id, status, feed_id);


--
-- Name: entries_user_status_published_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entries_user_status_published_idx ON public.entries USING btree (user_id, status, published_at);


--
-- Name: entry_tombstones_deleted_at_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX entry_tombstones_deleted_at_idx ON public.entry_tombstones USING btree (deleted_at);


--
-- Name: feeds_feed_id_hide_globally_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX feeds_feed_id_hide_globally_idx ON public.feeds USING btree (id, hide_globally);


--
-- Name: feeds_user_category_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX feeds_user_category_idx ON public.feeds USING btree (user_id, category_id);


--
-- Name: icons_external_id_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE UNIQUE INDEX icons_external_id_idx ON public.icons USING btree (external_id) WHERE (external_id <> ''::text);


--
-- Name: users_google_id_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE UNIQUE INDEX users_google_id_idx ON public.users USING btree (google_id) WHERE (google_id <> ''::text);


--
-- Name: users_openid_connect_id_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE UNIQUE INDEX users_openid_connect_id_idx ON public.users USING btree (openid_connect_id) WHERE (openid_connect_id <> ''::text);


--
-- Name: web_sessions_created_at_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX web_sessions_created_at_idx ON public.web_sessions USING btree (created_at);


--
-- Name: web_sessions_user_id_idx; Type: INDEX; Schema: public; Owner: miniflux
--

CREATE INDEX web_sessions_user_id_idx ON public.web_sessions USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- Name: api_keys api_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: categories categories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: enclosures enclosures_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.enclosures
    ADD CONSTRAINT enclosures_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.entries(id) ON DELETE CASCADE;


--
-- Name: enclosures enclosures_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.enclosures
    ADD CONSTRAINT enclosures_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: entries entries_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_feed_id_fkey FOREIGN KEY (feed_id) REFERENCES public.feeds(id) ON DELETE CASCADE;


--
-- Name: entries entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: entry_tombstones entry_tombstones_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.entry_tombstones
    ADD CONSTRAINT entry_tombstones_feed_id_fkey FOREIGN KEY (feed_id) REFERENCES public.feeds(id) ON DELETE CASCADE;


--
-- Name: feed_icons feed_icons_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.feed_icons
    ADD CONSTRAINT feed_icons_feed_id_fkey FOREIGN KEY (feed_id) REFERENCES public.feeds(id) ON DELETE CASCADE;


--
-- Name: feed_icons feed_icons_icon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.feed_icons
    ADD CONSTRAINT feed_icons_icon_id_fkey FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON DELETE CASCADE;


--
-- Name: feeds feeds_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.feeds
    ADD CONSTRAINT feeds_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: feeds feeds_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.feeds
    ADD CONSTRAINT feeds_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: integrations integrations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT integrations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: web_sessions web_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.web_sessions
    ADD CONSTRAINT web_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: miniflux
--

ALTER TABLE ONLY public.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


