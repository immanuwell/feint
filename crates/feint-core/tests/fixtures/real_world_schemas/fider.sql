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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: map_language_to_tsvector(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.map_language_to_tsvector(config_name text) RETURNS regconfig
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN CASE config_name
        WHEN 'arabic' THEN 'arabic'::regconfig
        WHEN 'dutch' THEN 'dutch'::regconfig
        WHEN 'english' THEN 'english'::regconfig
        WHEN 'french' THEN 'french'::regconfig
        WHEN 'german' THEN 'german'::regconfig
        WHEN 'italian' THEN 'italian'::regconfig
        WHEN 'portuguese' THEN 'portuguese'::regconfig
        WHEN 'russian' THEN 'russian'::regconfig
        WHEN 'spanish' THEN 'spanish'::regconfig
        WHEN 'swedish' THEN 'swedish'::regconfig
        WHEN 'turkish' THEN 'turkish'::regconfig
        -- Unsupported languages fall back to 'simple':
        -- Chinese, Czech, Greek, Japanese, Korean, Persian, Polish, Sinhala, Slovak
        ELSE 'simple'::regconfig
    END;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    post_id integer NOT NULL,
    comment_id integer,
    user_id integer NOT NULL,
    attachment_bkey character varying(512) NOT NULL
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blobs (
    id integer NOT NULL,
    key character varying(512) NOT NULL,
    tenant_id integer,
    size bigint NOT NULL,
    content_type character varying(200) NOT NULL,
    file bytea NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blobs_id_seq OWNED BY public.blobs.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    content text,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    tenant_id integer NOT NULL,
    edited_at timestamp with time zone,
    edited_by_id integer,
    deleted_at timestamp with time zone,
    deleted_by_id integer,
    is_approved boolean NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: email_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_verifications (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    email character varying(200) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    key character varying(64) NOT NULL,
    verified_at timestamp with time zone,
    name character varying(200),
    expires_at timestamp with time zone NOT NULL,
    kind smallint NOT NULL,
    user_id integer,
    code character varying(6),
    attempts smallint DEFAULT 0 NOT NULL
);


--
-- Name: email_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_verifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_verifications_id_seq OWNED BY public.email_verifications.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    client_ip inet,
    name character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logs (
    id integer NOT NULL,
    tag character varying(50) NOT NULL,
    level character varying(50) NOT NULL,
    text text NOT NULL,
    properties jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;


--
-- Name: mention_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mention_notifications (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    user_id integer NOT NULL,
    comment_id integer,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    post_id integer,
    CONSTRAINT mention_notifications_comment_or_post_check CHECK (((comment_id IS NOT NULL) OR (post_id IS NOT NULL)))
);


--
-- Name: mention_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mention_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mention_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mention_notifications_id_seq OWNED BY public.mention_notifications.id;


--
-- Name: migrations_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations_history (
    version bigint NOT NULL,
    filename character varying(100),
    date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying(400) NOT NULL,
    link character varying(2048),
    read boolean NOT NULL,
    post_id integer NOT NULL,
    author_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oauth_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_providers (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    provider character varying(30) NOT NULL,
    display_name character varying(50) NOT NULL,
    status integer NOT NULL,
    client_id character varying(100) NOT NULL,
    client_secret character varying(500) NOT NULL,
    authorize_url character varying(300) NOT NULL,
    token_url character varying(300) NOT NULL,
    profile_url character varying(300) NOT NULL,
    scope character varying(100) NOT NULL,
    json_user_id_path character varying(100) NOT NULL,
    json_user_name_path character varying(100) NOT NULL,
    json_user_email_path character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    logo_bkey character varying(512) NOT NULL,
    is_trusted boolean DEFAULT false,
    json_user_roles_path text,
    allowed_roles text
);


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_providers_id_seq OWNED BY public.oauth_providers.id;


--
-- Name: post_subscribers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_subscribers (
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    status smallint NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: post_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_tags (
    tag_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    created_by_id integer NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_votes (
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    description text,
    tenant_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    user_id integer,
    number integer NOT NULL,
    status integer NOT NULL,
    slug character varying(100) NOT NULL,
    response text,
    response_user_id integer,
    response_date timestamp with time zone,
    original_id integer,
    language text,
    is_approved boolean NOT NULL,
    search tsvector GENERATED ALWAYS AS (
CASE
    WHEN (language <> 'simple'::text) THEN (((setweight(to_tsvector(public.map_language_to_tsvector(language), (title)::text), 'A'::"char") || setweight(to_tsvector(public.map_language_to_tsvector(language), description), 'B'::"char")) || setweight(to_tsvector('simple'::regconfig, (title)::text), 'C'::"char")) || setweight(to_tsvector('simple'::regconfig, description), 'D'::"char"))
    ELSE (setweight(to_tsvector('simple'::regconfig, (title)::text), 'A'::"char") || setweight(to_tsvector('simple'::regconfig, description), 'B'::"char"))
END) STORED
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reactions (
    id integer NOT NULL,
    emoji character varying(8) NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    created_on timestamp with time zone NOT NULL
);


--
-- Name: reactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reactions_id_seq OWNED BY public.reactions.id;


--
-- Name: system_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_settings (
    key character varying(100) NOT NULL,
    value text NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    name character varying(30) NOT NULL,
    slug character varying(30) NOT NULL,
    color character varying(6) NOT NULL,
    is_public boolean NOT NULL,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: tenant_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_providers (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    provider character varying(40) NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tenant_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenant_providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenant_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenant_providers_id_seq OWNED BY public.tenant_providers.id;


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id integer NOT NULL,
    name character varying(60) NOT NULL,
    subdomain character varying(40) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    cname character varying(100),
    invitation character varying(100),
    welcome_message text,
    status integer NOT NULL,
    is_private boolean NOT NULL,
    custom_css text NOT NULL,
    logo_bkey character varying(512) NOT NULL,
    locale character varying(10) NOT NULL,
    is_email_auth_allowed boolean NOT NULL,
    is_feed_enabled boolean NOT NULL,
    prevent_indexing boolean DEFAULT true NOT NULL,
    allowed_schemes text DEFAULT ''::text NOT NULL,
    is_moderation_enabled boolean NOT NULL,
    is_pro boolean DEFAULT false NOT NULL,
    welcome_header text DEFAULT ''::text,
    scheduled_deletion_at timestamp with time zone,
    deletion_requested_by integer,
    deletion_cancel_key character varying(64),
    description_template text DEFAULT ''::text NOT NULL
);


--
-- Name: tenants_billing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_billing (
    tenant_id integer NOT NULL,
    paddle_subscription_id character varying(255),
    stripe_customer_id character varying(255),
    stripe_subscription_id character varying(255),
    license_key text
);


--
-- Name: tenants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenants_id_seq OWNED BY public.tenants.id;


--
-- Name: user_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_providers (
    user_id integer NOT NULL,
    provider character varying(40) NOT NULL,
    provider_uid character varying(100) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_settings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    key character varying(100) NOT NULL,
    value character varying(100),
    tenant_id integer NOT NULL
);


--
-- Name: user_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_settings_id_seq OWNED BY public.user_settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100),
    email character varying(200) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    tenant_id integer,
    role integer NOT NULL,
    status integer NOT NULL,
    api_key character varying(64),
    api_key_date timestamp with time zone,
    avatar_type smallint NOT NULL,
    avatar_bkey character varying(512) NOT NULL,
    email_supressed_at timestamp with time zone,
    is_trusted boolean DEFAULT false NOT NULL,
    security_stamp character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: webhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhooks (
    id integer NOT NULL,
    name character varying(60) NOT NULL,
    type smallint NOT NULL,
    status smallint NOT NULL,
    url text NOT NULL,
    content text,
    http_method character varying(50) NOT NULL,
    http_headers jsonb,
    tenant_id integer NOT NULL
);


--
-- Name: webhooks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhooks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhooks_id_seq OWNED BY public.webhooks.id;


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blobs ALTER COLUMN id SET DEFAULT nextval('public.blobs_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: email_verifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verifications ALTER COLUMN id SET DEFAULT nextval('public.email_verifications_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);


--
-- Name: mention_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention_notifications ALTER COLUMN id SET DEFAULT nextval('public.mention_notifications_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oauth_providers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_providers ALTER COLUMN id SET DEFAULT nextval('public.oauth_providers_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: reactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions ALTER COLUMN id SET DEFAULT nextval('public.reactions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: tenant_providers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_providers ALTER COLUMN id SET DEFAULT nextval('public.tenant_providers_id_seq'::regclass);


--
-- Name: tenants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants ALTER COLUMN id SET DEFAULT nextval('public.tenants_id_seq'::regclass);


--
-- Name: user_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings ALTER COLUMN id SET DEFAULT nextval('public.user_settings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: webhooks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks ALTER COLUMN id SET DEFAULT nextval('public.webhooks_id_seq'::regclass);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: blobs blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blobs
    ADD CONSTRAINT blobs_pkey PRIMARY KEY (id);


--
-- Name: blobs blobs_tenant_id_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blobs
    ADD CONSTRAINT blobs_tenant_id_key_key UNIQUE (tenant_id, key);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: email_verifications email_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: mention_notifications mention_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention_notifications
    ADD CONSTRAINT mention_notifications_pkey PRIMARY KEY (id);


--
-- Name: migrations_history migrations_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations_history
    ADD CONSTRAINT migrations_history_pkey PRIMARY KEY (version);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_providers oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: post_subscribers post_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_subscribers
    ADD CONSTRAINT post_subscribers_pkey PRIMARY KEY (user_id, post_id);


--
-- Name: post_tags post_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_tags
    ADD CONSTRAINT post_tags_pkey PRIMARY KEY (tag_id, post_id);


--
-- Name: post_votes post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (user_id, post_id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: reactions reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_pkey PRIMARY KEY (id);


--
-- Name: system_settings system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (key);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tenant_providers tenant_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_providers
    ADD CONSTRAINT tenant_providers_pkey PRIMARY KEY (id);


--
-- Name: tenant_providers tenant_providers_tenant_id_provider_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_providers
    ADD CONSTRAINT tenant_providers_tenant_id_provider_key UNIQUE (tenant_id, provider);


--
-- Name: tenants_billing tenants_billing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_billing
    ADD CONSTRAINT tenants_billing_pkey PRIMARY KEY (tenant_id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: reactions unique_reaction; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT unique_reaction UNIQUE (comment_id, user_id, emoji);


--
-- Name: user_providers user_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_providers
    ADD CONSTRAINT user_providers_pkey PRIMARY KEY (user_id, provider);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: blobs_unique_global_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX blobs_unique_global_key ON public.blobs USING btree (key, tenant_id) WHERE (tenant_id IS NOT NULL);


--
-- Name: blobs_unique_tenant_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX blobs_unique_tenant_key ON public.blobs USING btree (key) WHERE (tenant_id IS NULL);


--
-- Name: comments_post_id_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_post_id_fkey ON public.comments USING btree (tenant_id, post_id);


--
-- Name: email_verifications_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX email_verifications_key_idx ON public.email_verifications USING btree (tenant_id, key);


--
-- Name: idx_mention_notifications_tenant_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mention_notifications_tenant_user ON public.mention_notifications USING btree (tenant_id, user_id);


--
-- Name: idx_posts_search_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_search_gin ON public.posts USING gin (search);


--
-- Name: idx_tenant_providers_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tenant_providers_tenant_id ON public.tenant_providers USING btree (tenant_id);


--
-- Name: idx_users_trust; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_trust ON public.users USING btree (tenant_id, is_trusted) WHERE (is_trusted = true);


--
-- Name: oauth_provider_uq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX oauth_provider_uq ON public.oauth_providers USING btree (provider);


--
-- Name: post_id_tenant_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX post_id_tenant_id_key ON public.posts USING btree (tenant_id, id);


--
-- Name: post_number_tenant_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX post_number_tenant_key ON public.posts USING btree (tenant_id, number);


--
-- Name: post_slug_tenant_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX post_slug_tenant_key ON public.posts USING btree (tenant_id, slug) WHERE (status <> 6);


--
-- Name: post_subscribers_post_id_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX post_subscribers_post_id_fkey ON public.post_subscribers USING btree (tenant_id, post_id);


--
-- Name: post_tags_post_id_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX post_tags_post_id_fkey ON public.post_tags USING btree (tenant_id, post_id);


--
-- Name: post_user_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX post_user_key ON public.posts USING btree (user_id);


--
-- Name: post_votes_post_id_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX post_votes_post_id_fkey ON public.post_votes USING btree (tenant_id, post_id);


--
-- Name: tag_id_tenant_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tag_id_tenant_id_key ON public.tags USING btree (tenant_id, id);


--
-- Name: tag_slug_tenant_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tag_slug_tenant_key ON public.tags USING btree (tenant_id, slug);


--
-- Name: tenant_cname_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tenant_cname_unique_idx ON public.tenants USING btree (cname) WHERE ((cname)::text <> ''::text);


--
-- Name: tenant_id_provider_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tenant_id_provider_key ON public.oauth_providers USING btree (tenant_id, provider);


--
-- Name: tenant_subdomain_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tenant_subdomain_unique_idx ON public.tenants USING btree (subdomain);


--
-- Name: user_email_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_email_unique_idx ON public.users USING btree (tenant_id, email) WHERE ((email)::text <> ''::text);


--
-- Name: user_id_tenant_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_id_tenant_id_key ON public.users USING btree (tenant_id, id);


--
-- Name: user_provider_unique_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_provider_unique_idx ON public.user_providers USING btree (user_id, provider);


--
-- Name: user_settings_uq_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_settings_uq_key ON public.user_settings USING btree (user_id, key);


--
-- Name: users_api_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_api_key ON public.users USING btree (tenant_id, api_key);


--
-- Name: attachments attachments_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: attachments attachments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: attachments attachments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: attachments attachments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: blobs blobs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blobs
    ADD CONSTRAINT blobs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: comments comments_deleted_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_deleted_by_id_fkey FOREIGN KEY (deleted_by_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: comments comments_edited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_edited_by_id_fkey FOREIGN KEY (edited_by_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id, tenant_id) REFERENCES public.posts(id, tenant_id);


--
-- Name: comments comments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: email_verifications email_verifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: email_verifications email_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_user_id_fkey FOREIGN KEY (user_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: events events_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: mention_notifications mention_notifications_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention_notifications
    ADD CONSTRAINT mention_notifications_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: mention_notifications mention_notifications_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention_notifications
    ADD CONSTRAINT mention_notifications_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: mention_notifications mention_notifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention_notifications
    ADD CONSTRAINT mention_notifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: mention_notifications mention_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mention_notifications
    ADD CONSTRAINT mention_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_author_id_fkey FOREIGN KEY (author_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: notifications notifications_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_post_id_fkey FOREIGN KEY (post_id, tenant_id) REFERENCES public.posts(id, tenant_id);


--
-- Name: notifications notifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: oauth_providers oauth_providers_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_providers
    ADD CONSTRAINT oauth_providers_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: post_subscribers post_subscribers_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_subscribers
    ADD CONSTRAINT post_subscribers_post_id_fkey FOREIGN KEY (post_id, tenant_id) REFERENCES public.posts(id, tenant_id);


--
-- Name: post_subscribers post_subscribers_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_subscribers
    ADD CONSTRAINT post_subscribers_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: post_subscribers post_subscribers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_subscribers
    ADD CONSTRAINT post_subscribers_user_id_fkey FOREIGN KEY (user_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: post_tags post_tags_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_tags
    ADD CONSTRAINT post_tags_created_by_id_fkey FOREIGN KEY (created_by_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: post_tags post_tags_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_tags
    ADD CONSTRAINT post_tags_post_id_fkey FOREIGN KEY (post_id, tenant_id) REFERENCES public.posts(id, tenant_id);


--
-- Name: post_tags post_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_tags
    ADD CONSTRAINT post_tags_tag_id_fkey FOREIGN KEY (tag_id, tenant_id) REFERENCES public.tags(id, tenant_id);


--
-- Name: post_tags post_tags_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_tags
    ADD CONSTRAINT post_tags_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: post_votes post_votes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT post_votes_post_id_fkey FOREIGN KEY (post_id, tenant_id) REFERENCES public.posts(id, tenant_id);


--
-- Name: post_votes post_votes_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT post_votes_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: post_votes post_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT post_votes_user_id_fkey FOREIGN KEY (user_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: posts posts_original_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_original_id_fkey FOREIGN KEY (original_id) REFERENCES public.posts(id);


--
-- Name: posts posts_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: posts posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: reactions reactions_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: reactions reactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tags tags_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: tenant_providers tenant_providers_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_providers
    ADD CONSTRAINT tenant_providers_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;


--
-- Name: tenants_billing tenants_billing_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_billing
    ADD CONSTRAINT tenants_billing_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_providers user_providers_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_providers
    ADD CONSTRAINT user_providers_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_providers user_providers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_providers
    ADD CONSTRAINT user_providers_user_id_fkey FOREIGN KEY (user_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: user_settings user_settings_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: user_settings user_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id, tenant_id) REFERENCES public.users(id, tenant_id);


--
-- Name: users users_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- Name: webhooks webhooks_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhooks
    ADD CONSTRAINT webhooks_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);


--
-- PostgreSQL database dump complete
--


